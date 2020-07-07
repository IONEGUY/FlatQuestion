//
//  EditProfileViewController.swift
//  FlatQuestion
//
//  Created by Андрей Олесов on 6/29/20.
//  Copyright © 2020 Андрей Олесов. All rights reserved.
//

import UIKit
import GooglePlaces

class EditProfileViewController: UIViewController {
    
    @IBOutlet fileprivate weak var addPhotoButton: UIImageView!
    @IBOutlet fileprivate weak var plusImageView: UIImageView!
    @IBOutlet fileprivate weak var underPhotoView: UIView!
    @IBOutlet fileprivate weak var label: UILabel!
    @IBOutlet fileprivate weak var cancelButton: UIButton!
    @IBOutlet fileprivate weak var navigationView: UIView!
    @IBOutlet fileprivate weak var instagramView: UIView!
    @IBOutlet fileprivate weak var VKView: UIView!
    @IBOutlet fileprivate weak var aboutView: UIView!
    @IBOutlet fileprivate weak var locationView: UIView!
    @IBOutlet fileprivate weak var dateView: UIView!
    @IBOutlet fileprivate weak var sexView: UIView!
    @IBOutlet fileprivate weak var nameView: UIView!
    @IBOutlet fileprivate weak var photoImageView: UIImageView!
    @IBOutlet weak var instLinkLaabel: UITextField!
    @IBOutlet weak var vkLinkLabel: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    @IBOutlet weak var imagesErrorLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var sexErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    @IBOutlet weak var aboutMeErrorLabel: UILabel!
    @IBOutlet weak var dateErrorLabel: UILabel!
    @IBOutlet weak var instErrorLabel: UILabel!
    @IBOutlet weak var vkErrorLabel: UILabel!
    
    
    @IBOutlet fileprivate weak var aboutmeView: UIView!
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var addressTextField: UITextField!
    @IBOutlet fileprivate weak var sexTextField: UITextField!
    @IBOutlet fileprivate weak var dateTextField: UITextField!
    fileprivate let datePicker = UIDatePicker()
    fileprivate let pickerSex = UIPickerView()
    fileprivate var currentDate: Date?
    fileprivate var place:GMSPlace? {
        didSet {
            addressTextField.text = place?.name
        }
    }
    fileprivate var photoImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupPickers()
        setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layoutIfNeeded()
    }
}

private extension EditProfileViewController {
    func setupView() {
        navigationView.applyGradientV2(colours: [UIColor(hex: "0x615CBF"), UIColor(hex: "0x1C2F4B")])
        nameView.addCorner(with: 10, with: .black)
        dateView.addCorner(with: 10, with: .black)
        locationView.addCorner(with: 10, with: .black)
        underPhotoView.addCorner(with: 10, with: .black)
        VKView.addCorner(with: 10, with: .black)
        instagramView.addCorner(with: 10, with: .black)
        sexView.addCorner(with: 10, with: .black)
        aboutView.addCorner(with: 10, with: .black)
        cancelButton.addCorner(with: 20, with: .black)
        self.view.layoutSubviews()
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
        
        sexTextField.inputView = pickerSex
        sexTextField.inputAccessoryView = toolbar
        pickerSex.delegate = self
        pickerSex.dataSource = self
        
        
    }
    
    func setupData() {
        textView.delegate = self
    }
}

private extension EditProfileViewController {
    func dateFiledIsValid() -> Bool {
        guard currentDate != nil else {
            dateView.layer.borderWidth = 1
            dateView.layer.borderColor = UIColor.red.cgColor
            dateErrorLabel.text = "Пожалуйста, заполните поле"
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
            nameErrorLabel.text = "Пожалуйста, заполните поле"
            nameErrorLabel.isHidden = false
            return false
        }
        nameErrorLabel.isHidden = true
        nameView.layer.borderWidth = 0
        return true
    }
    
    func addressFieldIsValid() -> Bool {
        guard let address = addressTextField.text, !address.isEmpty else {
                  locationView.layer.borderWidth = 1
                  locationView.layer.borderColor = UIColor.red.cgColor
                  locationErrorLabel.text = "Пожалуйста, заполните поле"
                  locationErrorLabel.isHidden = false
                  return false
              }
              locationErrorLabel.isHidden = true
              locationView.layer.borderWidth = 0
        return true
    }
    
    func sexTextFieldIsValid() -> Bool {
        guard let sex = sexTextField.text, !sex.isEmpty else {
                  sexView.layer.borderWidth = 1
                  sexView.layer.borderColor = UIColor.red.cgColor
                  sexErrorLabel.text = "Пожалуйста, заполните поле"
                  sexErrorLabel.isHidden = false
                  return false
              }
              sexErrorLabel.isHidden = true
              sexView.layer.borderWidth = 0
        return true
    }
    
    func vkTextFieldIsValid() -> Bool {
        guard let vk = vkLinkLabel.text, !vk.isEmpty else {
                  VKView.layer.borderWidth = 1
                  VKView.layer.borderColor = UIColor.red.cgColor
                  vkErrorLabel.text = "Пожалуйста, заполните поле"
                  vkErrorLabel.isHidden = false
                  return false
              }
              vkErrorLabel.isHidden = true
              VKView.layer.borderWidth = 0
        return true
    }
    
    func instTextFieldIsValid() -> Bool {
        guard let inst = instLinkLaabel.text, !inst.isEmpty else {
                  instagramView.layer.borderWidth = 1
                  instagramView.layer.borderColor = UIColor.red.cgColor
                  instErrorLabel.text = "Пожалуйста, заполните поле"
                  instErrorLabel.isHidden = false
                  return false
              }
              instErrorLabel.isHidden = true
              instagramView.layer.borderWidth = 0
        return true
    }
    

    
    func aboutMeIsValid() -> Bool {
        guard let info = textView.text, !info.isEmpty else {
                   aboutmeView.layer.borderWidth = 1
                   aboutmeView.layer.borderColor = UIColor.red.cgColor
            aboutMeErrorLabel.text = "Пожалуйста, заполните поле"
            aboutMeErrorLabel.isHidden = false
                   return false
        }
        aboutMeErrorLabel.isHidden = true
               aboutmeView.layer.borderWidth = 0
        return true
    }
    
    func imageIsValid() -> Bool {
        guard photoImage != nil else {
            imagesErrorLabel.text = "Пожалуйста, добавьте картинку"
            imagesErrorLabel.isHidden = false
            underPhotoView.layer.borderWidth = 1
            underPhotoView.layer.borderColor = UIColor.red.cgColor
            return false
        }
        imagesErrorLabel.isHidden = true
        underPhotoView.layer.borderWidth = 0
        return true
    }
    
    func allFiledsAreValid() -> Bool{
        let nameIsValid = nameFieldIsValid()
        let dateIsValid = dateFiledIsValid()
        let addressIsValid = addressFieldIsValid()
        let imagesIsValid = imageIsValid()
        let sexIsValid = sexTextFieldIsValid()
        let infoAboutMeIsValid = aboutMeIsValid()
        let instIsValid = instTextFieldIsValid()
        let vkIsValid = vkTextFieldIsValid()
        
        return vkIsValid && instIsValid && infoAboutMeIsValid && sexIsValid && imagesIsValid && addressIsValid && dateIsValid && nameIsValid
    }
    
    @IBAction func createProfile(_ sender: Any) {
        guard allFiledsAreValid() else { return }
        let user = UserSettings.appUser
        user?.aboutMe = textView.text
        user?.date = currentDate!.timeIntervalSince1970
        user?.flats = []
        user?.instLink = instLinkLaabel.text
        user?.vkLink = vkLinkLabel.text
        user?.location = addressTextField.text
        
        user!.sex = sexTextField.text == "Мужской" ? true : false
        user?.x = place?.coordinate.latitude ?? 0
        user?.y = place?.coordinate.longitude ?? 0
        FireBaseHelper().updateUserInfoWithImage(user: user!, profileImage: photoImage!) { (result) in
           switch result {
                case .success():
                    self.close()
                case .failure(let _): self.showErrorAlert(message: "Ошибка создания мероприятия")
                }
        }
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func declineButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func choosePhoto(_ sender: Any) {
        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = .photoLibrary
        self.present(imageController, animated: true, completion: nil)
    }
    @objc func datePickerValueChanged() {
        currentDate = datePicker.date
        dateTextField.text = DateFormatterHelper().getStringFromDate_dd_MM_yyyy_HH_mm(date: currentDate!)
    }
    @objc func datePickerClose() {
        view.endEditing(true)
    }
    @IBAction func dateButtonPressed(_ sender: Any) {
        dateTextField.becomeFirstResponder()
    }
    
    @IBAction func sexButtonPressed(_ sender: Any) {
        sexTextField.becomeFirstResponder()
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

extension EditProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "Мужской" : "Женский"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sexTextField.text = row == 0 ? "Мужской" : "Женский"
    }
    
    
}

extension EditProfileViewController: GMSAutocompleteViewControllerDelegate {
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

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.aboutmeView.removeCorner()
            self.aboutmeView.addCorner(with: 10, with: .black)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.aboutmeView.removeCorner()
            self.aboutmeView.addCorner(with: 10, with: .black)
        }
    }
}

extension EditProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        photoImage = image
        photoImageView.image = image
        plusImageView.tintColor = .white
        
        self.dismiss(animated: true, completion: nil)
    }
}
