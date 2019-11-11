//
//  Task.swift
//  taskapp
//
//  Created by 山口 彰太 on 2019/11/07.
//  Copyright © 2019 shouta.yamaguchi4. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用ID　プライマリーキー
    @objc dynamic var id = 0

    // タイトル
    @objc dynamic var title = ""

    // 内容
    @objc dynamic var contents = ""

    // 日時
    @objc dynamic var date = Date()

    // カテゴリ
    @objc dynamic var category = ""

    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
