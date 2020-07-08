//
//  CreateFlatViewController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/17/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import GooglePlaces

protocol CreateFlatProtocol: class {
    func flatWasCreated()
}

class CreateFlatViewController: UIViewController{
    
    @IBOutlet fileprivate weak var additionalInfoView: UIView!
    @IBOutlet fileprivate weak var allCountOfPeopleView: UIView!
    @IBOutlet fileprivate weak var emptyPlacesView: UIView!
    @IBOutlet fileprivate weak var placeView: UIView!
    @IBOutlet fileprivate weak var dateView: UIView!
    @IBOutlet fileprivate weak var nameView: UIView!
    @IBOutlet fileprivate weak var navigationBarView: UIView!
    @IBOutlet fileprivate weak var additionalInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var textView: UITextView!
    
    @IBOutlet fileprivate weak var dateTextField: UITextField!
    @IBOutlet fileprivate weak var nameTextField: UITextField!
    @IBOutlet fileprivate weak var addressTextField: UITextField!
    @IBOutlet fileprivate weak var emptyPlacesTextfield: UITextField!
    @IBOutlet fileprivate weak var allPlacesTextField: UITextField!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var dateErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    @IBOutlet weak var emptyErrorLabel: UILabel!
    @IBOutlet weak var allPlacesErrorLabel: UILabel!
    @IBOutlet weak var additionalInfoErrorLabel: UILabel!
    @IBOutlet weak var imagesErrorLabel: UILabel!
    
    @IBOutlet weak var addFlatNavLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateAndTimeLabel: UILabel!
    @IBOutlet weak var lcoationLabel: UILabel!
    @IBOutlet weak var emptyPlacesLabel: UILabel!
    @IBOutlet weak var allPlacesLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    @IBOutlet weak var downloadImageButton: UIButton!
    @IBOutlet weak var imageDescriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: DarkGradientButton!
    
    fileprivate var arrayWithImages = [UIImage]()
    weak var delegate: CreateFlatProtocol?
    private let datePicker = UIDatePicker()
    private let pickerViewEmptyPlaces = UIPickerView()
    private let pickerViewAllPlaces = UIPickerView()
    private var currentDate: Date?
    private var place:GMSPlace? {
        didSet {
            addressTextField.text = place?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        setupView()
        setupData()
        setupPickers()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionViewHeightConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    func localize() {
        addFlatNavLabel.text = "Добавить вечеринку".localized
        nameLabel.text = "Название".localized
        dateAndTimeLabel.text = "Дата и время".localized
        lcoationLabel.text = "Местоположение".localized
        emptyPlacesLabel.text = "Свободных мест".localized
        allPlacesLabel.text = "Общее количество".localized
        additionalInfoLabel.text = "Дополнительная информация".localized
        downloadImageButton.titleLabel?.text = "Загрузить фото".localized
        imageDescriptionLabel.text = "PNG, JPG или JPEG с максимальным размером 5Mb.".localized
        cancelButton.titleLabel?.text = "Отмена".localized
        createButton.titleLabel?.text = "Создать".localized
    }
}

private extension CreateFlatViewController {
    
   private func setupCollectionView() {
        self.collectionView.collectionViewLayout = generateLayout()
        collectionView.register(UINib(nibName: FlatPhotoCollectionViewCell.identifier, bundle: nil),
        forCellWithReuseIdentifier: FlatPhotoCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    
        self.view.layoutIfNeeded()
    }

    func generateLayout() -> UICollectionViewLayout {
        let fullPhotoItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(2/3)))
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 2,
            bottom: 0,
            trailing: 2)
        let mainItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(2/3),
                heightDimension: .fractionalHeight(1.0)))
        mainItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        let pairItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(0.5)))
        pairItem.contentInsets = NSDirectionalEdgeInsets(
            top: 2,
            leading: 2,
            bottom: 2,
            trailing: 2)
        let trailingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .fractionalHeight(1.0)),
            subitem: pairItem,
            count: 2)
        // 1
        let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(5/10)),
            subitems: [mainItem, trailingGroup])
        let nestedGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)),
            subitems: [
                mainWithPairGroup,
                fullPhotoItem
            ]
        )
        let section = NSCollectionLayoutSection(group: nestedGroup)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func setupPickers() {
        dateTextField.inputView = datePicker
        datePicker.datePickerMode = .dateAndTime
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localeID!)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor(hexString: "0x394175")!
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerClose))
        doneButton.tintColor = .white
        toolbar.setItems([doneButton], animated: true)
        dateTextField.inputAccessoryView = toolbar
        
        emptyPlacesTextfield.inputView = pickerViewEmptyPlaces
        emptyPlacesTextfield.inputAccessoryView = toolbar
        pickerViewEmptyPlaces.delegate = self
        pickerViewEmptyPlaces.dataSource = self
        
        allPlacesTextField.inputView = pickerViewAllPlaces
        allPlacesTextField.inputAccessoryView = toolbar
        pickerViewAllPlaces.delegate = self
        pickerViewAllPlaces.dataSource = self
    }
    
    func updateCollectionView() {
        if arrayWithImages.count == 0 {
            self.collectionViewHeightConstraint.constant = 0
        } else {
            self.collectionViewHeightConstraint.constant = 191
        }
        
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.6) {
            self.collectionView.reloadData()
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func datePickerValueChanged() {
        currentDate = datePicker.date
        dateTextField.text = DateFormatterHelper().getStringFromDate_dd_MM_yyyy_HH_mm(date: currentDate!)
    }
    
    @objc func datePickerClose() {
        view.endEditing(true)
    }
    
    func setupData() {
        textView.delegate = self
    }
    
    func dateFiledIsValid() -> Bool {
        guard currentDate != nil else {
            dateView.layer.borderWidth = 1
            dateView.layer.borderColor = UIColor.red.cgColor
            dateErrorLabel.text = "Пожалуйста, заполните поле".localized
            dateErrorLabel.isHidden = false
            return false
        }
        dateErrorLabel.isHidden = true
        dateView.layer.borderWidth = 0
        return true
    }
    
    func nameFieldIsValid() -> Bool {
        guard let name = nameTextField.text, !name.isEmpty else {
            nameView.layer.borderWidth = 1
            nameView.layer.borderColor = UIColor.red.cgColor
            nameErrorLabel.text = "Пожалуйста, заполните поле".localized
            nameErrorLabel.isHidden = false
            return false
        }
        nameErrorLabel.isHidden = true
        nameView.layer.borderWidth = 0
        return true
    }
    
    func addressFieldIsValid() -> Bool {
        guard let address = addressTextField.text, !address.isEmpty else {
                  placeView.layer.borderWidth = 1
                  placeView.layer.borderColor = UIColor.red.cgColor
                  locationErrorLabel.text = "Пожалуйста, заполните поле".localized
                  locationErrorLabel.isHidden = false
                  return false
              }
              locationErrorLabel.isHidden = true
              placeView.layer.borderWidth = 0
        return true
    }
    
    func allPlacesIsValid() -> Bool {
        guard let allPlaces = allPlacesTextField.text, !allPlaces.isEmpty else {
            allCountOfPeopleView.layer.borderWidth = 1
            allCountOfPeopleView.layer.borderColor = UIColor.red.cgColor
            allPlacesErrorLabel.text = "Пожалуйста, заполните поле".localized
            allPlacesErrorLabel.isHidden = false
            return false
        }
        allPlacesErrorLabel.isHidden = true
        allCountOfPeopleView.layer.borderWidth = 0
        return true
    }
    
    func emptyPlacesIsValid() -> Bool {
        guard let emprtPlaces = emptyPlacesTextfield.text, !emprtPlaces.isEmpty else {
            emptyPlacesView.layer.borderWidth = 1
            emptyPlacesView.layer.borderColor = UIColor.red.cgColor
            emptyErrorLabel.text = "Пожалуйста, заполните поле".localized
            emptyErrorLabel.isHidden = false
            return false
        }
        emptyErrorLabel.isHidden = true
        emptyPlacesView.layer.borderWidth = 0
        return true
    }
    
    func additionalInfoIsValid() -> Bool {
        guard let info = textView.text, !info.isEmpty else {
                   additionalInfoView.layer.borderWidth = 1
                   additionalInfoView.layer.borderColor = UIColor.red.cgColor
            additionalInfoErrorLabel.text = "Пожалуйста, заполните поле".localized
            additionalInfoErrorLabel.isHidden = false
                   return false
        }
        additionalInfoErrorLabel.isHidden = true
               additionalInfoView.layer.borderWidth = 0
        return true
    }
    
    func imagesIsValid() -> Bool {
        guard arrayWithImages.count > 0 else {
            imagesErrorLabel.text = "Пожалуйста, добавьте картинку".localized
            imagesErrorLabel.isHidden = false
            return false
        }
        imagesErrorLabel.isHidden = true
        return true
    }
    
    func allFiledsAreValid() -> Bool{
        let nameIsValid = nameFieldIsValid()
        let dateIsValid = dateFiledIsValid()
        let addressIsValid = addressFieldIsValid()
        let emptyIsValid = emptyPlacesIsValid()
        let allIsValid = allPlacesIsValid()
        let infoIsValid = additionalInfoIsValid()
        let imageIsValid = imagesIsValid()
        return nameIsValid && dateIsValid && addressIsValid && emptyIsValid && allIsValid && infoIsValid && imageIsValid
    }

    
    func setupView() {
        navigationBarView.applyGradientV2(colours: [UIColor(hex: "0x615CBF"), UIColor(hex: "0x1C2F4B")])
        nameView.addCorner(with: 10, with: .black)
        dateView.addCorner(with: 10, with: .black)
        placeView.addCorner(with: 10, with: .black)
        emptyPlacesView.addCorner(with: 10, with: .black)
        allCountOfPeopleView.addCorner(with: 10, with: .black)
        additionalInfoView.addCorner(with: 10, with: .black)
        cancelButton.addCorner(with: 20, with: .black)
    }
    
    @IBAction func downloadImage(_ sender: Any) {
        
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = .photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    
    
    @IBAction func createFlat(_ sender: Any) {
        guard allFiledsAreValid() else { return }
        self.showLoadingIndicator()
        FireBaseHelper().createFlatWithImage(name: nameTextField.text!, address: self.addressTextField.text!, additionalInfo: textView.text, allPlacesCount: Int(allPlacesTextField.text!)!, emptyPlacesCount: Int(emptyPlacesTextfield.text!)!, date: currentDate!, id: Int(Date().timeIntervalSince1970), x: place?.coordinate.latitude ?? 0, y: place?.coordinate.longitude ?? 0, images: arrayWithImages) { (result) in
            self.hideLoadingableIndicator()
            switch result {
            case .success(): self.delegate?.flatWasCreated()
                self.close()
            case .failure( _): self.showErrorAlert(message: "Ошибка создания мероприятия".localized)
            }
        }
    }
    
    @IBAction func buttonBackPressed(_ sender: Any) {
        close()
    }
    @IBAction func buttonCancelPressed(_ sender: Any) {
        close()
    }
    
    @IBAction func emptyPlacesButtonPressen(_ sender: Any) {
        emptyPlacesTextfield.becomeFirstResponder()
    }
    
    @IBAction func allPlacedButtonPressed(_ sender: Any) {
        allPlacesTextField.becomeFirstResponder()
    }
    
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        present(autocompleteController, animated: true, completion: nil)
    }
}

extension CreateFlatViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayWithImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlatPhotoCollectionViewCell.identifier,
                                                      for: indexPath) as? FlatPhotoCollectionViewCell
        guard let photoCell = cell else {
            return UICollectionViewCell()
        }
        
        photoCell.image.image = arrayWithImages[indexPath.row]
        photoCell.setCancelButtonHidden(hidden: false)
        photoCell.delegate = self
        photoCell.imageNumber = indexPath.row
        return photoCell
    }

}

extension CreateFlatViewController: PhotoCellProtocol {
    func crossButtonWasPressed(imageNumber index: Int?) {
        guard let index = index else { return }
        arrayWithImages.remove(at: index)
        updateCollectionView()
    }
    
}

extension CreateFlatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.additionalInfoView.removeCorner()
            self.additionalInfoView.addCorner(with: 10, with: .black)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.additionalInfoView.removeCorner()
            self.additionalInfoView.addCorner(with: 10, with: .black)
        }
    }
}

extension CreateFlatViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        arrayWithImages.append(image)
        updateCollectionView()
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension CreateFlatViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        showLoadingIndicator()
        getPlaceDataByPlaceID(pPlaceID: place.placeID!)
    }
    
    func getPlaceDataByPlaceID(pPlaceID: String)
    {
        let placesClient = GMSPlacesClient.shared()
        
        placesClient.lookUpPlaceID(pPlaceID, callback: { (place, error) -> Void in
            
            self.hideLoadingableIndicator()
            self.dismiss(animated: true, completion: nil)
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                self.place = place
            } else {
                print("No place details for \(pPlaceID)")
            }
        })
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


extension CreateFlatViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewEmptyPlaces {
            emptyPlacesTextfield.text = String(row + 1)
        } else if pickerView == pickerViewAllPlaces {
            allPlacesTextField.text = String(row + 1)
        }
    }
    
}
