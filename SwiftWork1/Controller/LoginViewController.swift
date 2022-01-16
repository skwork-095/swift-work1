//
//  LoginViewController.swift
//  SwiftWork1
//
//  Created by 鈴谷健二 on 2022/01/15.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func login(){
        Auth.auth().signInAnonymously { (result, error) in
            let user = result?.user
            UserDefaults.standard.set(self.textfield.text, forKey: "userName")
            
            //画面遷移
            let viewVC = self.storyboard?.instantiateViewController(identifier: "viewVC") as! ViewController
            self.navigationController?.pushViewController(viewVC, animated: true)
        }
    }

    @IBAction func done(_ sender: Any) {
        login()
    }
}
