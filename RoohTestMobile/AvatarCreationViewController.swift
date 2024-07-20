import UIKit
import Combine

class AvatarCreationViewController: UIViewController {
    private var viewModel = AvatarCreationViewModel()
    
    var selectedAge: Int = 0
    var selectedWeight: Int = 0
    var selectedHeight: Int = 0

    private var collectionView: UICollectionView!
    private let agePicker: UIPickerView = createPickerView()
    private let weightPicker: UIPickerView = createPickerView()
    private let heightPicker: UIPickerView = createPickerView()
    
    private var selectedAvatarIndex: IndexPath? {
        didSet {
            if let oldValue = oldValue, oldValue != selectedAvatarIndex {
                if let oldCell = collectionView.cellForItem(at: oldValue) as? AvatarCell {
                    oldCell.highlightCell(isHighlighted: false)
                }
                if let newIndex = selectedAvatarIndex, let newCell = collectionView.cellForItem(at: newIndex) as? AvatarCell {
                    newCell.highlightCell(isHighlighted: true)
                    scrollToCenterCell(indexPath: newIndex, animated: true)
                    viewModel.selectAvatar(at: newIndex.item)
                }
            }
        }
    }
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewBackground()
        setupCollectionView()
        setupPickerContainerView()
        
        setupPickerDelegatesAndDataSources()
        setupTapGestureRecognizer()
        setupInitialSelection()
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            selectedAvatarIndex = indexPath
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc func sendButtonTapped() {}
    
    private func showAlert(title: String, message: String) {
          let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
          let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertController.addAction(okAction)
          present(alertController, animated: true, completion: nil)
      }
    
    private func setupViewBackground() {
        let colors = [
            UIColor(red: 0.05, green: 0, blue: 0.1, alpha: 1).cgColor,
            UIColor(red: 0.2, green: 0, blue: 0.15, alpha: 1).cgColor,
            UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1).cgColor
        ]
        setupGradientBackground(for: self.view, colors: colors)
    }

    private func setupGradientBackground(for view: UIView, colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupCollectionViewGradientBackground() {
        let colors = [
            UIColor(red: 0.05, green: 0, blue: 0.1, alpha: 1).cgColor,
            UIColor(red: 0.2, green: 0, blue: 0.15, alpha: 1).cgColor
        ]
        setupGradientBackground(for: collectionView, colors: colors)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: "AvatarCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .clear
        
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.3),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        setupCollectionViewGradientBackground()
    }
    
    private func setupPickerContainerView() {
        let pickerContainerView = UIView()
        pickerContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let ageLabel = createLabel(text: "Возраст")
        let weightLabel = createLabel(text: "Вес")
        let heightLabel = createLabel(text: "Рост")
        
        let ageStackView = createStackView(with: ageLabel, picker: agePicker)
        let weightStackView = createStackView(with: weightLabel, picker: weightPicker)
        let heightStackView = createStackView(with: heightLabel, picker: heightPicker)
        
        let stackView = UIStackView(arrangedSubviews: [weightStackView, heightStackView, ageStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        pickerContainerView.addSubview(stackView)
        pickerContainerView.addSubview(sendButton)
        self.view.addSubview(pickerContainerView)
        
        NSLayoutConstraint.activate([
            pickerContainerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 30),
            pickerContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            pickerContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            pickerContainerView.heightAnchor.constraint(equalToConstant: 250),
            
            stackView.topAnchor.constraint(equalTo: pickerContainerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -20),
            
            sendButton.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: -20),
            sendButton.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.textAlignment = .center
        return label
    }

    private func createStackView(with label: UILabel, picker: UIPickerView) -> UIStackView {
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spacerView.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [label, spacerView, picker])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }

    
    private static func createPickerView() -> UIPickerView {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }

    private func setupPickerDelegatesAndDataSources() {
        [weightPicker, heightPicker, agePicker].forEach {
            $0.delegate = self
            $0.dataSource = self
        }
    }

    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        collectionView.addGestureRecognizer(tapGesture)
    }

    private func setupInitialSelection() {
        DispatchQueue.main.async {
            self.selectedAvatarIndex = IndexPath(item: self.viewModel.avatars.count / 2, section: 0)
            self.collectionView.reloadData()
            self.scrollToCenterCell(indexPath: self.selectedAvatarIndex!, animated: false)
        }
    }
    
    private func configureCell(_ cell: AvatarCell, at indexPath: IndexPath) {
        cell.imageView.image = UIImage(named: viewModel.avatars[indexPath.item])
        let isHighlighted = indexPath == selectedAvatarIndex
        cell.highlightCell(isHighlighted: isHighlighted)
    }
}

extension AvatarCreationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.avatars.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as! AvatarCell
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        var totalSpacing: CGFloat = 0

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            totalSpacing = flowLayout.minimumLineSpacing * 2
        } else {
            print("Error: collectionViewLayout is not a UICollectionViewFlowLayout type")
            totalSpacing = 20
        }

        let padding: CGFloat = 10
        let cellWidth = (collectionViewWidth - totalSpacing - padding) / 3
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateAndScrollToSelectedCell()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateAndScrollToSelectedCell()
    }
    
    private func updateSelectedCell() {
        let centerPoint = self.view.convert(self.collectionView.center, to: self.collectionView)
        if let indexPath = self.collectionView.indexPathForItem(at: centerPoint) {
            selectedAvatarIndex = indexPath
        }
    }
    
    private func scrollToCenterCell(indexPath: IndexPath, animated: Bool) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }

    private func updateAndScrollToSelectedCell() {
        updateSelectedCell()
        if let indexPath = selectedAvatarIndex {
            scrollToCenterCell(indexPath: indexPath, animated: true)
        }
    }
}

extension AvatarCreationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 101
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == agePicker {
            selectedAge = row
            print("Selected age: \(row)")
        } else if pickerView == weightPicker {
            selectedWeight = row
            print("Selected weight: \(row)")
        } else if pickerView == heightPicker {
            selectedHeight = row
            print("Selected height: \(row)")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel ?? UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.text = "\(row)"
        label.backgroundColor = .clear
        return label
    }
}
