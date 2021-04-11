//
//  LoginViewController.swift
//  MapApp
//
//  Created by Антон Васильченко on 11.04.2021.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let realm = try! Realm()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        loginTextField.autocorrectionType = UITextAutocorrectionType.no
        passwordTextField.autocorrectionType = UITextAutocorrectionType.no
    }
    @IBAction func signInPressed(_ sender: Any) {
        searchUser(login: loginTextField.text ?? "") { user in
            self.user = user
            if self.user != nil {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "signInSegue", sender: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "No such user", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        searchUser(login: loginTextField.text ?? "") { (user) in
            self.user = user
            if self.user == nil {
                let newUser = User()
                newUser.login = self.loginTextField.text ?? "default"
                newUser.password = self.passwordTextField.text ?? "default"
                
                try! self.realm.write {
                    self.realm.add(newUser)
                }
                
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "signInSegue", sender: nil)
                }
                
            } else {
                
                try! self.realm.write {
                    self.user?.password = self.passwordTextField.text ?? "default"
                    self.realm.add(self.user!, update: .modified)
                }
                
            }
        }
    }
    
    func searchUser(login: String, completion: @escaping((User?) -> Void)) {
        guard let user = realm.object(ofType: User.self, forPrimaryKey: login) else {
            completion (nil)
            return
        }
        completion(user)
    }
}
