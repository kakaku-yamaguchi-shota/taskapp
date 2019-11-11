//
//  ViewController.swift
//  taskapp
//
//  Created by 山口 彰太 on 2019/11/07.
//  Copyright © 2019 shouta.yamaguchi4. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var searchTextFeild: UITextField! {
        didSet {
            searchTextFeild.placeholder = "カテゴリ名で検索"
        }
    }

    @IBOutlet weak var tableView: UITableView!

    // Realmインスタンスを取得
    lazy var realm = try! Realm()

    // DB内のタスクが格納されるリスト
    // 日付近い順＼順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される
    lazy var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    // 入力画面から戻ってきた時に TableViewを更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Cellに値を設定する
        let task = taskArray[indexPath.row]
        var labelText = task.title
        if task.category != "" { labelText += String(format: "（%@）", task.category) }
        // カテゴリがあれば(category)表示する
        cell.textLabel?.text = labelText

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString: String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString

        return cell
    }

    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 削除するタスクを取得
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセル
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }

    @IBAction func searchTask(_ sender: Any) {
        let searchText: String = searchTextFeild.text ?? ""
        if searchText == "" {
            // 空文字の場合、全件表示
            taskArray = try! Realm().objects(Task.self)
                .sorted(byKeyPath: "date", ascending: false)
        } else {
            let predicate = NSPredicate(format: "category == %@", searchText)
            taskArray = try! Realm().objects(Task.self)
                .filter(predicate)
                .sorted(byKeyPath: "date", ascending: false)
        }
        tableView.reloadData()
        searchTextFeild.text = searchText
    }


    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController: InputViewController = segue.destination as! InputViewController

        var task: Task! {
            switch segue.identifier {
            case "cellSegue":
                let indexPath = self.tableView.indexPathForSelectedRow
                return taskArray[indexPath!.row]
            default:
                let task = Task()
                task.date = Date()

                let allTasks = realm.objects(Task.self)
                if allTasks.count != 0 {
                    task.id = allTasks.max(ofProperty: "id")! + 1
                }
                return task
            }
        }
        inputViewController.task = task
    }
}

