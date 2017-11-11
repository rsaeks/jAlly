![BarcodeScanner](https://github.com/hyperoslo/BarcodeScanner/blob/master/Art/BarcodeScannerPresentation.png)

[![CI Status](http://img.shields.io/travis/hyperoslo/BarcodeScanner.svg?style=flat)](https://travis-ci.org/hyperoslo/BarcodeScanner)
[![Version](https://img.shields.io/cocoapods/v/BarcodeScanner.svg?style=flat)](http://cocoadocs.org/docsets/BarcodeScanner)
![Swift](https://img.shields.io/badge/%20in-swift%204.0-orange.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/BarcodeScanner.svg?style=flat)](http://cocoadocs.org/docsets/BarcodeScanner)
[![Platform](https://img.shields.io/cocoapods/p/BarcodeScanner.svg?style=flat)](http://cocoadocs.org/docsets/BarcodeScanner)

## Description

**BarcodeScanner** is a simple and beautiful wrapper around the camera with
barcode capturing functionality and a great user experience.

- [x] Barcode scanning.
- [x] State modes: scanning, processing, unauthorized, not found.
- [x] Handling of camera authorization status.
- [x] Animated focus view and custom loading indicator.
- [x] Torch mode switch.
- [x] Customizable colors, informational and error messages.
- [x] No external dependencies.
- [x] [Demo project](https://github.com/hyperoslo/BarcodeScanner/tree/master/Example/BarcodeScannerExample).

## Table of Contents

<img src="https://github.com/hyperoslo/BarcodeScanner/blob/master/Art/BarcodeScannerIcon.png" alt="BarcodeScanner Icon" width="190" height="190" align="right" />

* [Usage](#usage)
  * [Controller](#controller)
  * [Delegates](#delegates)
  * [Actions](#actions)
  * [Customization](#customization)
* [Installation](#installation)
* [Author](#author)
* [Contributing](#contributing)
* [License](#license)

## Usage

### Controller

To start capturing just instantiate `BarcodeScannerController`, set needed
delegates and present it:

```swift
let controller = BarcodeScannerController()
controller.codeDelegate = self
controller.errorDelegate = self
controller.dismissalDelegate = self

present(controller, animated: true, completion: nil)
```

<div align="center">
<img src="https://github.com/hyperoslo/BarcodeScanner/blob/master/Art/ExampleScanning.png" alt="BarcodeScanner scanning" width="270" height="480" />
</div><br/>

You can also push `BarcodeScannerController` to your navigation stack:

```swift
let controller = BarcodeScannerController()
controller.codeDelegate = self

navigationController?.pushViewController(controller, animated: true)
```

### Delegates

**Code delegate**

Use `BarcodeScannerCodeDelegate` when you want to get the captured code back.

```swift
extension ViewController: BarcodeScannerCodeDelegate {

  func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
    print(code)
    controller.reset()
  }
}
```

**Error delegate**

Use `BarcodeScannerErrorDelegate` when you want to handle session errors.
```swift
extension ViewController: BarcodeScannerErrorDelegate {

  func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
    print(error)
  }
}
```

**Dismissal delegate**

Use `BarcodeScannerDismissalDelegate` to handle "Close button" tap.
**Please note** that `BarcodeScannerController` doesn't dismiss itself if it was
presented initially.

```swift
extension ViewController: BarcodeScannerDismissalDelegate {

  func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
    controller.dismiss(animated: true, completion: nil)
  }
}
```

### Actions

When the code is captured `BarcodeScannerController` switches to the processing
mode:

<div align="center">
<img src="https://github.com/hyperoslo/BarcodeScanner/blob/master/Art/ExampleLoading.png" alt="BarcodeScanner loading" width="270" height="480" />
</div><br/>

While the user see a nice loading animation you can perform some
background task, for example make a network request to fetch product info based
on the code. When the task is done you have 3 options to proceed:

1. Dismiss `BarcodeScannerController` and show your results.

 ```swift
 func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
   // Code processing
   controller.dismiss(animated: true, completion: nil)
 }
 ```
2. Show an error message and switch back to the scanning mode (for example,
when there is no product found with a given barcode in your database):

 <div align="center">
 <img src="https://github.com/hyperoslo/BarcodeScanner/blob/master/Art/ExampleError.png" alt="BarcodeScanner error" width="270" height="480" />
 </div><br/>

 ```swift
 func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
   // Code processing
   controller.resetWithError(message: "Error message")
   // If message is not provided the default message from the config will be used instead.
 }
 ```
3. Reset the controller to the scanning mode (with or without animation):

 ```swift
 func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
   // Code processing
   controller.reset(animated: true)
 }
 ```

If you want to do continuous barcode scanning just set the `isOneTimeSearch`
property on your `BarcodeScannerController` instance to `false`.

### Customization

We styled **BarcodeScanner** to make it look nice, but feel free to customize
its appearance by changing global configuration variables:

```swift
// Strings
BarcodeScanner.Title.text = NSLocalizedString("Scan barcode", comment: "")
BarcodeScanner.CloseButton.text = NSLocalizedString("Close", comment: "")
BarcodeScanner.SettingsButton.text = NSLocalizedString("Settings", comment: "")
BarcodeScanner.Info.text = NSLocalizedString(
  "Place the barcode within the window to scan. The search will start automatically.", comment: "")
BarcodeScanner.Info.loadingText = NSLocalizedString("Looking for your product...", comment: "")
BarcodeScanner.Info.notFoundText = NSLocalizedString("No product found.", comment: "")
BarcodeScanner.Info.settingsText = NSLocalizedString(
  "In order to scan barcodes you have to allow camera under your settings.", comment: "")

// Fonts
BarcodeScanner.Title.font = UIFont.boldSystemFont(ofSize: 17)
BarcodeScanner.CloseButton.font = UIFont.boldSystemFont(ofSize: 17)
BarcodeScanner.SettingsButton.font = UIFont.boldSystemFont(ofSize: 17)
BarcodeScanner.Info.font = UIFont.boldSystemFont(ofSize: 14)
BarcodeScanner.Info.loadingFont = UIFont.boldSystemFont(ofSize: 16)

// Colors
BarcodeScanner.Title.color = UIColor.black
BarcodeScanner.CloseButton.color = UIColor.black
BarcodeScanner.SettingsButton.color = UIColor.white
BarcodeScanner.Info.textColor = UIColor.black
BarcodeScanner.Info.tint = UIColor.black
BarcodeScanner.Info.loadingTint = UIColor.black
BarcodeScanner.Info.notFoundTint = UIColor.red
```

## Installation

**BarcodeScanner** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'BarcodeScanner'
```

In order to quickly try the demo project of a **BarcodeScanner** just run
`pod try BarcodeScanner` in your terminal.

**BarcodeScanner** is also available through [Carthage](https://github.com/Carthage/Carthage).
To install just write into your Cartfile:

```ruby
github "hyperoslo/BarcodeScanner"
```

To install **BarcodeScanner** manually just download and drop `Sources` and
`Images` folders in your project.

## Author

Hyper Interaktiv AS, ios@hyper.no

## Contributing

We would love you to contribute to **BarcodeScanner**, check the [CONTRIBUTING](https://github.com/hyperoslo/BarcodeScanner/blob/master/CONTRIBUTING.md) file for more info.

## License

**BarcodeScanner** is available under the MIT license. See the [LICENSE](https://github.com/hyperoslo/BarcodeScanner/blob/master/LICENSE.md) file for more info.
