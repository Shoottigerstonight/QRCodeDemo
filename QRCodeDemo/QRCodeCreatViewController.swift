//
//  QRCodeCreatViewController.swift
//  SWB
//
//  Created by 函冰 on 2016/12/7.
//  Copyright © 2016年 今晚打老虎. All rights reserved.
//

import UIKit

class QRCodeCreatViewController: UIViewController {

    @IBOutlet weak var QRCodeImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

//        1.创建一个滤镜
        let filter = CIFilter(name:"CIQRCodeGenerator")
//        2.将滤镜恢复到默认状态
        filter?.setDefaults()
//        3.为滤镜添加属性
        filter?.setValue("函冰".data(using: String.Encoding.utf8), forKey: "InputMessage")
//        判断是否有图片
        guard let ciimage = filter?.outputImage else {
            return
        }
//        4。将二维码赋给imageview
        QRCodeImageView.image = createNonInterpolatedUIImageFormCIImage(image: ciimage, size: 200)
    }
    /**
     生成高清二维码
     
     - parameter image: 需要生成原始图片
     - parameter size:  生成的二维码的宽高
     */
    private func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        let extent: CGRect = image.extent.integral
        let scale: CGFloat = min(size/extent.width, size/extent.height)
        
        // 1.创建bitmap;
        let width = extent.width * scale
        let height = extent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)!
        
        let context = CIContext(options: nil)
        let bitmapImage: CGImage = context.createCGImage(image, from: extent)!
        
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: scale, y: scale);
//        CGContextDrawImage(bitmapRef, extent, bitmapImage);
        bitmapRef.draw(bitmapImage, in: extent)
        // 2.保存bitmap到图片
        let scaledImage: CGImage = bitmapRef.makeImage()!
        
        return UIImage(cgImage: scaledImage)
    }


}
