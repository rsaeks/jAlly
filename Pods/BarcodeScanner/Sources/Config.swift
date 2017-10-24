import UIKit
import AVFoundation

// MARK: - Configurations

public struct Title {
  public static var text = localizedString("SCAN_BARCODE_TITLE")
  public static var font = UIFont.boldSystemFont(ofSize: 17)
  public static var color = UIColor.black
  public static var backgroundColor = UIColor.white
}

public struct CloseButton {
  public static var text = localizedString("BUTTON_CLOSE")
  public static var font = UIFont.boldSystemFont(ofSize: 17)
  public static var color = UIColor.black
}

public struct SettingsButton {
  public static var text = localizedString("BUTTON_SETTINGS")
  public static var font = UIFont.boldSystemFont(ofSize: 17)
  public static var color = UIColor.white
}

public struct Info {
  public static var text = localizedString("INFO_DESCRIPTION_TEXT")
  public static var loadingText = localizedString("INFO_LOADING_TITLE")
  public static var notFoundText = localizedString("NO_PRODUCT_ERROR_TITLE")
  public static var settingsText = localizedString("ASK_FOR_PERMISSION_TEXT")

  public static var font = UIFont.boldSystemFont(ofSize: 14)
  public static var textColor = UIColor.black
  public static var tint = UIColor.black

  public static var loadingFont = UIFont.boldSystemFont(ofSize: 16)
  public static var loadingTint = UIColor.black

  public static var notFoundTint = UIColor.red
}

/**
 Returns image with a given name from the resource bundle.

 - Parameter name: Image name.
 - Returns: An image.
 */
func imageNamed(_ name: String) -> UIImage {
  let cls = BarcodeScannerController.self
  var bundle = Bundle(for: cls)
  let traitCollection = UITraitCollection(displayScale: 3)

  if let path = bundle.resourcePath,
    let resourceBundle = Bundle(path: path + "/BarcodeScanner.bundle") {
      bundle = resourceBundle
  }

  guard let image = UIImage(named: name, in: bundle,
    compatibleWith: traitCollection)
    else { return UIImage() }

  return image
}

func localizedString(_ key: String) -> String {
  if let path = Bundle(for: BarcodeScannerController.self).resourcePath,
    let resourceBundle = Bundle(path: path + "/Localization.bundle") {
    return resourceBundle.localizedString(forKey: key, value: nil, table: "Localizable")
  }
  return key
}


/**
 `AVCaptureMetadataOutput` metadata object types.
 */
public var metadata = [
  AVMetadataObject.ObjectType.aztec,
  AVMetadataObject.ObjectType.code128,
  AVMetadataObject.ObjectType.code39,
  AVMetadataObject.ObjectType.code39Mod43,
  AVMetadataObject.ObjectType.code93,
  AVMetadataObject.ObjectType.dataMatrix,
  AVMetadataObject.ObjectType.ean13,
  AVMetadataObject.ObjectType.ean8,
  AVMetadataObject.ObjectType.face,
  AVMetadataObject.ObjectType.interleaved2of5,
  AVMetadataObject.ObjectType.itf14,
  AVMetadataObject.ObjectType.pdf417,
  AVMetadataObject.ObjectType.qr,
  AVMetadataObject.ObjectType.upce,
]

extension AVMetadataObject.ObjectType {
    public static let upca: AVMetadataObject.ObjectType = AVMetadataObject.ObjectType(rawValue: "org.gs1.UPC-A")
}
