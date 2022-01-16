//
//  CheckViewController.swift
//  SwiftWork1
//
//  Created by 鈴谷健二 on 2022/01/16.
//

import UIKit
import Firebase
import FirebaseFirestore

class CheckViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let db = Firestore.firestore()
    
    var odaiString = String()
    var dataSets:[AnswersModel] = []
    
    @IBOutlet weak var odaiLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false

        odaiLabel.text = odaiString
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        tableView.rowHeight = 200
        let answerLabel = cell.contentView.viewWithTag(1) as! UILabel
        answerLabel.numberOfLines = 0
        answerLabel.text = "\(self.dataSets[indexPath.row].userName)くんの回答\n\(self.dataSets[indexPath.row].answers)"
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //画面遷移
        let commentVC = self.storyboard?.instantiateViewController(identifier: "commentVC") as! CommentViewController
        commentVC.idString = dataSets[indexPath.row].docID
        commentVC.kaitouString = "\(self.dataSets[indexPath.row].userName)くんの回答\n\(self.dataSets[indexPath.row].answers)"
        
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func loadData(){
        db.collection("Answers").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            self.dataSets = []
            if error != nil {
                return
            }
            
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let answer = data["answer"] as? String,
                       let userName = data["userName"] as? String{
                        
                        let answerModel = AnswersModel(answers: answer, userName: userName, docID: doc.documentID)
                        self.dataSets.append(answerModel)
                    }
                }
                self.dataSets.reverse()
                self.tableView.reloadData()
            }
        }
    }
}
