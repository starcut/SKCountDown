# 目次　_Table of contents_

# スクリーンショット　 _Screenshots_

# インストール方法　_Installation_

## CocoaPods

Podfileに以下のように入力してください。

```
use_frameworks!
target '<Tour target Name>' do
  pod 'SKCountDown'
end
```

#### English 
Please input Podfile the code written in the following.

```
use_frameworks!
target '<Tour target Name>' do
  pod 'SKCountDown'
end
```

# Setup

## storyboardなど、IBを使う場合　_Use Interface Builder_
1. ViewControllerにUILabelをドラッグします
2. 1.で追加したUILabelのCustom Classを`SKCountDownLabel`に変えます
3. コードに記載した@IBOutletのプロパティと紐付けます
4. ソースコードに以下のコードを記載します
```
fileprivate weak var countDownLabel: SKCountDownLabel!
```

```
self.countDownLabel.setDeadline(deadline: SKDateFormat.createTime(string: "<期日（フォーマット:「yyyy/MM/dd HH:mm」）>",
                                                                  identifier: "ja_JP"),
                                style: .defaultStyle)
```

#### English
1. Drag an UILabel object to ViewController
1. Change the Custom Class to `SKCountDownLabel`
1. Connect to IBOutlet property

```
self.countDownLabel.setDeadline(deadline: SKDateFormat.createTime(string: "<deadline（format:「yyyy/MM/dd HH:mm」）>",
                                                                  identifier: "ja_JP"),
                                style: .defaultStyle)
```

## swiftのコードで使う場合　_Write Swift Code_
```
fileprivate weak var countDownLabel: SKCountDownLabel!
```

```
// In loadView or viewDidLoad
let countDownLabel = SKCountDownLabel(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
self.countDownLabel.setDeadline(deadline: SKDateFormat.createTime(string: "<期日（フォーマット:「yyyy/MM/dd HH:mm」）>",
                                                                  identifier: "ja_JP"),
                                style: .defaultStyle)view.addSubview(countDownLabel)
self.countDownLabel = countDownLabel
```

> SKCountDownLabelはSwift4.0での表記です。

#### English

```
fileprivate weak var countDownLabel: SKCountDownLabel!
```

```
// In loadView or viewDidLoad
let countDownLabel = SKCountDownLabel(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
self.countDownLabel.setDeadline(deadline: SKDateFormat.createTime(string: "<deadline（format:「yyyy/MM/dd HH:mm」）>",
                                                                  identifier: "ja_JP"),
                                style: .defaultStyle)view.addSubview(countDownLabel)
self.countDownLabel = countDownLabel
```

> SKCountDownLabel is coded in Swift4.0.

# 注意　Warning
オートレイアウトで設定しないと表示が変になります。
きちんとオートレイアウトを設定してください。

#### English

Please set SKCountDownLabel's Autolayout appropriately, or the Label is got out of shape.

# プロパティ　Properties

## timeStyle
表示する時間の形式を変えられます

### defaultStyle
残り時間のそれぞれの単位を秒まで表示します
timeStyleを設定しなかった場合はこの設定になります
例：「残り3年4ヶ月4日12時間45分39.373秒」の場合
表示：「3年4ヶ月4日12時間45分39秒」

### milliSecond
残り時間をミリ秒まで表示します。
例：「残り3時間15分37.123秒」の場合
表示：「11737.123秒」

### second
残り時間を秒で表示します。
例：「残り3時間15分37.123秒」の場合
表示：「11737秒」

### minute
残り時間を分で表示します。
例：「残り3時間15分37.123秒」の場合
表示：「11700分」

### hour
残り時間を時間で表示します。
例：「残り4ヶ月4日12時間45分39秒」の場合
表示：「2988時間」（この例では一ヶ月を30日と計算）

### day
残り時間を日数で表示します
例：「残り4ヶ月4日12時間45分39秒」の場合
表示：「124日」（この例では一ヶ月を30日と計算）

### month
残り時間を月数で表示します
例：「残り3年4ヶ月4日12時間45分39秒」の場合
表示：「40ヶ月」

### year
残り時間を年数で表示します
例：「残り3年4ヶ月4日12時間45分39秒」の場合
表示：「3年」

### full
残り時間のそれぞれの単位をミリ秒まで表示します
例：「残り3年4ヶ月4日12時間45分39.373秒」の場合
表示：「3年4ヶ月4日12時間45分39.373秒」

## timeupString
期限が来た時に表示する文字列


#### English

## timeStyle
the displayed remaining time' style

### defaultStyle
the remaining time is displayed years, months, days, hours, minutes, and seconds.
If you don't set timeStyle, this property is setted defaultStyle

Example: 「3years 4months 4days 12hours 45minutes 39.373 seconds to deadline」
display：「3年4ヶ月4日12時間45分39秒」

### milliSecond
the remaining time is displayed in milliseconds

Example:「3hours 15minutes 37.123 seconds to deadline」
display：「11737.123秒」

### second
the remaining time is displayed in seconts

Example:「3hours 15minutes 37.123 seconds to deadline」
display：「11737秒」

### minute
the remaining time is displayed in minutes

Example:「3hours 15minutes 37.123 seconds to deadline」
display：「11700分」

### hour
the remaining time is displayed in hours

Example:「4months 4days 12hours 45minutes 39 seconds to deadline」
display：「2988時間」（We calc remaining time as a month is 30days in this example）

### day
the remaining time is displayed in days

Example:「4months 4days 12hours 45minutes 39 seconds to deadline」
display：「124日」（We calc remaining time as a month is 30days in this example）

### month
the remaining time is displayed in months

Example:「3year 4months 4days 12hours 45minutes 39 seconds to deadline」
display：「40ヶ月」

### year
the remaining time is displayed in years

Example:「3years 4months 4days 12hours 45minutes 39 seconds to deadline」
display：「3年」

## timeupString
this property is text displayed when your scheduel expires
