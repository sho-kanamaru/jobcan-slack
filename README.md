# シフトリマインダー

## データベース設計
### users table
has_many :shifts

|column|type|constraint|index|
|:---:|:---:|:---:|:---:|
|name|string|-|-|
|mention|string|-|-|
|mention_exp|string|-|-|

### shifts table
belongs_to :user

enum location: %w(shibuya vr ai waseda tokyo ikebukuro shinjuku ochanomizu expert umeda nagoya)

|column|type|constraint|index|
|:---:|:---:|:---:|:---:|
|date|string|-|-|
|time|string|-|-|
|location|integer|-|-|
|user_id|integer|null:false,unique|-|


## ファイル説明

jobcanからスクレイピングするファイル:
```
app/model/scraping.rb
```

slackAPIを叩いてslackにシフト情報を流すファイル:
```
app/model/jobcan.rb
```

## rakeタスク実行

全拠点のシフト:
```
rake jobcan_task:all_group
```

各拠点のシフト:
```
rake jobcan_task:"拠点名"
```

