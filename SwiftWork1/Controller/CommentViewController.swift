//
//  CommentViewController.swift
//  SwiftWork1
//
//  Created by 鈴谷健二 on 2022/01/16.
//

import UIKit
import Firebase
import FirebaseFirestore

class CommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let db = Firestore.firestore()
    let screenSize = UIScreen.main.bounds.size

    var idString = String()
    var kaitouString = String()
    var userName = String()
    var dataSets:[CommentModel] = []
    
    @IBOutlet weak var kaitouLabel: UILabel!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        kaitouLabel.text = kaitouString
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification:NSNotification){
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
                  
            textfield.frame.origin.y = screenSize.height - keyboardHeight - textfield.frame.height
                  sendButton.frame.origin.y = screenSize.height - keyboardHeight - sendButton.frame.height
     }

    @objc func keyboardWillHide(_ notification:NSNotification){
        textfield.frame.origin.y = screenSize.height - textfield.frame.height
        sendButton.frame.origin.y = screenSize.height - sendButton.frame.height
        
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else{return}
        
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func loadData(){
        db.collection("Answers").document(idString).collection("comments").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            
            self.dataSets = []
            
            if error != nil{
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let userName = data["userName"] as? String,
                       let comment = data["comment"] as? String,
                       let postDate = data["postDate"] as? Double{
                        
                        let commentModel = CommentModel(userName: userName, comment: comment, postDate: postDate)
                        self.dataSets.append(commentModel)
                    }
                }
                self.dataSets.reverse()
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        tableView.rowHeight = 200
        let commentLabel = cell.contentView.viewWithTag(1) as! UILabel
        commentLabel.numberOfLines = 0
        commentLabel.text = "\(self.dataSets[indexPath.row].userName)くん\n\(self.dataSets[indexPath.row].comment)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //セルの高さを自動設定
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        if textfield.text?.isEmpty == true {
            return
        }
        
        db.collection("Answers").document(idString).collection("comments").document().setData([
            "userName":userName as Any,
            "comment":textfield.text as Any,
            "postDate":Date().timeIntervalSince1970
        ])
        textfield.text = ""
        textfield.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textfield.resignFirstResponder()
    }

}
