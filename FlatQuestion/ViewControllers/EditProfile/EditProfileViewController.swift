import UIKit
import GooglePlaces
import SDWebImage
import ImagePicker

protocol EditProfileViewControllerProtocol: AnyObject {
    func successEditingProfile()
}
class EditProfileViewController: UIViewController {
    
    weak var delegate: EditProfileViewControllerProtocol?
    
    @IBOutlet fileprivate weak var addPhotoButton: UIImageView!
    @IBOutlet fileprivate weak var plusImageView: UIImageView!
    @IBOutlet fileprivate weak var underPhotoView: UIView!
    @IBOutlet fileprivate weak var label: UILabel!
    @IBOutlet fileprivate weak var cancelButton: UIButton!
    @IBOutlet fileprivate weak var navigationView: UIImageView!
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
    
    @IBOutlet weak var backButon: UIButton!
    @IBOutlet weak var backButtonImageButton: UIButton!
    
    @IBOutlet weak var imagesErrorLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var sexErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    @IBOutlet weak var aboutMeErrorLabel: UILabel!
    @IBOutlet weak var dateErrorLabel: UILabel!
    @IBOutlet weak var instErrorLabel: UILabel!
    @IBOutlet weak var vkErrorLabel: UILabel!
    
    @IBOutlet weak var editProfileLabel: UILabel!
    @IBOutlet weak var downloadImageDescription: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet fileprivate weak var aboutmeView: UIView!
    @IBOutlet fileprivate weak var textView: UITextView!
    @IBOutlet fileprivate weak var addressTextField: UITextField!
    @IBOutlet fileprivate weak var sexTextField: UITextField!
    @IBOutlet fileprivate weak var dateTextField: UITextField!
    
    var isEditingProfile: Bool = false
    fileprivate var sex: Bool?
    fileprivate var latitude: Double?
    fileprivate var longtitude: Double?
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
        localize()
        isEditingProfile ? displayUserInfo() : disableCancel()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let colorView = UIView(frame: navigationView.frame)
        colorView.backgroundColor = UIColor(hex: 0x191D29)
        navigationView.image = UIImage(view: colorView)
        navigationView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        navigationView.clipsToBounds = true
                
    }
    
    func localize() {
        cancelButton.setTitle("Отмена".localized, for: .normal)
        editProfileLabel.text = "Редактировать профиль".localized
        downloadImageDescription.text = "PNG, JPG или JPEG с максимальным размером 5Mb.".localized
        fullNameLabel.text = "Имя Фамилия".localized
        sexLabel.text = "Пол".localized
        birthDateLabel.text = "Дата рождения".localized
        locationLabel.text = "Население".localized
        aboutMeLabel.text = "Обо мне".localized
        let titleForButtonCreate = isEditingProfile ? "Редактировать".localized : "Создать".localized
        createButton.setTitle(titleForButtonCreate, for: .normal)
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
        user?.fullName = nameTextField.text
        
        user!.sex = sex
        user?.x = place?.coordinate.latitude ?? latitude ?? 0
        user?.y = place?.coordinate.longitude ?? longtitude ?? 0
        showLoadingIndicator()
        FireBaseHelper().updateUserInfoWithImage(user: user!, profileImage: photoImage!) { (result) in
            self.hideLoadingableIndicator()
           switch result {
                case .success():
                    UserSettings.appUser = user
                    let vc = SuccessViewController(delegate: self)
                    vc.transitioningDelegate = self
                    self.present(vc, animated: true, completion: nil)
           case .failure(let _): self.showErrorAlert(message: "Ошибка создания профиля".localized)
                }
        }
    }
}

private extension EditProfileViewController {
    func disableCancel() {
        DispatchQueue.main.async {
            self.backButon.isHidden = true
            self.backButtonImageButton.isHidden = true
            self.cancelButton.isHidden = true
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.async {
            self.createButton.removeSublayers()
            self.createButton.applyGradientV2(colours: [UIColor(hex: "0x615CBF"), UIColor(hex: "0x1C2F4B")])
            self.createButton.layer.cornerRadius = 20
            self.createButton.clipsToBounds = true
            self.view.layoutIfNeeded()
        }
        
    }
    func displayUserInfo() {
        guard let user = UserSettings.appUser else { return }
        photoImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        photoImageView.sd_setImage(with: URL(string: user.avatarUrl!)) { (image, error, cache, url) in
            self.photoImage = image
        }
        nameTextField.text = user.fullName!
        addressTextField.text = user.location
        textView.text = user.aboutMe
        instLinkLaabel.text = user.instLink
        vkLinkLabel.text = user.vkLink
        sex = user.sex
        sexTextField.text = sex! ? "Мужской".localized : "Женский".localized
        currentDate = user.date?.date()
        dateTextField.text = DateFormatterHelper().getStringFromDate_MMM_yyyy(date: currentDate!)
        latitude = user.x
        longtitude = user.y
        plusImageView.tintColor = .white
    }
    
    func setupView() {
//        if !isEditingProfile {
        createButton.applyGradientV2(colours: [UIColor(hex: "0x615CBF"), UIColor(hex: "0x1C2F4B")])
        createButton.layer.cornerRadius = 20
        createButton.clipsToBounds = true
//        }

        nameView.addCorner(with: 10, with: .black)
        dateView.addCorner(with: 10, with: .black)
        locationView.addCorner(with: 10, with: .black)
        underPhotoView.addCorner(with: 75.5, with: .black)
        VKView.addCorner(with: 10, with: .black)
        instagramView.addCorner(with: 10, with: .black)
        sexView.addCorner(with: 10, with: .black)
        aboutView.addCorner(with: 10, with: .black)
        cancelButton.addCorner(with: 20, with: .black)
        self.view.layoutSubviews()
    }
    
    func setupPickers() {
        dateTextField.inputView = datePicker
        dateTextField.delegate = self
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = .dateAndTime
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localeID!)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor(hexString: "0x03CCE0")!
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(datePickerClose))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        doneButton.tintColor = .white
        toolbar.setItems([spacer,doneButton], animated: true)
        dateTextField.inputAccessoryView = toolbar
        nameTextField.inputAccessoryView = toolbar
        textView.inputAccessoryView = toolbar
        addressTextField.inputAccessoryView = toolbar
        sexTextField.inputView = pickerSex
        sexTextField.delegate = self
        sexTextField.inputAccessoryView = toolbar
        pickerSex.delegate = self
        pickerSex.dataSource = self
        instLinkLaabel.inputAccessoryView = toolbar
        vkLinkLabel.inputAccessoryView = toolbar
        
    }
    
    func setupData() {
        textView.delegate = self
        nameTextField.delegate = self
        sexTextField.delegate = self
        dateTextField.delegate = self
        addressTextField.delegate = self
        vkLinkLabel.delegate = self
        instLinkLaabel.delegate = self
        
    }
    
    
}

private extension EditProfileViewController {
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
                  locationView.layer.borderWidth = 1
                  locationView.layer.borderColor = UIColor.red.cgColor
                  locationErrorLabel.text = "Пожалуйста, заполните поле".localized
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
                  sexErrorLabel.text = "Пожалуйста, заполните поле".localized
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
                  vkErrorLabel.text = "Пожалуйста, заполните поле".localized
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
                  instErrorLabel.text = "Пожалуйста, заполните поле".localized
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
            aboutMeErrorLabel.text = "Пожалуйста, заполните поле".localized
            aboutMeErrorLabel.isHidden = false
                   return false
        }
        aboutMeErrorLabel.isHidden = true
               aboutmeView.layer.borderWidth = 0
        return true
    }
    
    func imageIsValid() -> Bool {
        guard photoImage != nil else {
            imagesErrorLabel.text = "Пожалуйста, добавьте картинку".localized
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if let _ = self.navigationController {
            self.navigationController?.popViewController(animated: true)
        } else {
        self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func declineButtonPressed(_ sender: Any) {
        if let _ = self.navigationController {
            self.navigationController?.popViewController(animated: true)
        } else {
        self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func choosePhoto(_ sender: Any) {
//        let imageController = UIImagePickerController()
//        imageController.delegate = self
//        imageController.sourceType = .photoLibrary
//        self.present(imageController, animated: true, completion: nil)
        let config = Configuration()
        config.doneButtonTitle = "Готово".localized
        config.noImagesTitle = "Извините, изображения отсутствуют!".localized
        config.recordLocation = false
        config.allowVideoSelection = true

        let imagePicker = ImagePickerController(configuration: config)
        imagePicker.imageLimit = 1
        imagePicker.delegate = self

        present(imagePicker, animated: true, completion: nil)
    }
    @objc func datePickerValueChanged() {
        currentDate = datePicker.date
        dateTextField.text = DateFormatterHelper().getStringFromDate_MMM_yyyy(date: currentDate!)
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
        filter.type = .city
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
        return row == 0 ? "Мужской".localized : "Женский".localized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sexTextField.text = row == 0 ? "Мужской".localized : "Женский".localized
        sex = row == 0 ? true : false
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
    func textViewDidEndEditing(_ textView: UITextView) {
        aboutMeIsValid()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
            aboutView.layer.borderWidth = 1.5
        aboutView.layer.borderColor = UIColor(hex: 0x03CCE0).cgColor
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

extension EditProfileViewController: SuccessViewControllerProtocol {
    func successScreenWillClose() {
        self.delegate?.successEditingProfile()
        self.close()
    }
}

extension EditProfileViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is AcceptModalViewController {
            return TransparentBackgroundModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        } else {
        return SuccessModalPresenter(isPush: true, originFrame: UIScreen.main.bounds)
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is AcceptModalViewController {
        return TransparentBackgroundModalPresenter(isPush: false)
        } else {
            return SuccessModalPresenter(isPush: false)
        }
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case dateTextField:
            currentDate = datePicker.date
            dateTextField.text = DateFormatterHelper().getStringFromDate_MMM_yyyy(date: currentDate!)
        case sexTextField:
            if (sexTextField.text!.isEmpty) {sexTextField.text = "Мужской".localized}
            self.sex = true
        default:
            print("Default")
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            nameView.layer.borderWidth = 1.5
            nameView.layer.borderColor = UIColor(hex: 0x03CCE0).cgColor
        case dateTextField:
            dateView.layer.borderWidth = 1.5
            dateView.layer.borderColor = UIColor(hex: 0x03CCE0).cgColor
        case addressTextField:
            locationView.layer.borderWidth = 1.5
            locationView.layer.borderColor = UIColor(hex: 0x03CCE0).cgColor
        case sexTextField:
            sexView.layer.borderWidth = 1.5
            sexView.layer.borderColor = UIColor(hex: 0x03CCE0).cgColor
        case vkLinkLabel:
            VKView.layer.borderWidth = 1.5
            VKView.layer.borderColor = UIColor(hex: 0x03CCE0).cgColor
        case instLinkLaabel:
            instagramView.layer.borderWidth = 1.5
            instagramView.layer.borderColor = UIColor(hex: 0x03CCE0).cgColor
        default:
            break
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameTextField:
            nameFieldIsValid()
        case dateTextField:
            dateFiledIsValid()
        case addressTextField:
            addressFieldIsValid()
        case sexTextField:
            sexTextFieldIsValid()
        case vkLinkLabel:
            vkTextFieldIsValid()
        case instLinkLaabel:
            instTextFieldIsValid()
        default:
            break
        }
    }
}

extension EditProfileViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("Wrapper tapped")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        photoImage = images[0]
        photoImageView.image = images[0]
        plusImageView.tintColor = .white
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
      
}
