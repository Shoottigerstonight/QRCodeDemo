//
//  QRCodeViewController.swift
//  SWB
//
//  Created by 函冰 on 2016/11/24.
//  Copyright © 2016年 今晚打老虎. All rights reserved.
//

import UIKit
import AVFoundation
class QRCodeViewController: UIViewController {

    // MARK:  属性
//    边框的高度
    @IBOutlet weak var borderHeight: NSLayoutConstraint!
//    冲击波视图
    @IBOutlet weak var cjbImageview: UIImageView!
//    冲击波的顶部距边框的距离
    @IBOutlet weak var cjbTopConstraint: NSLayoutConstraint!
//    容器视图的高度
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
//    扫描二维码展示的信息
    @IBOutlet weak var infomationLabel: UILabel!
//    创建绘画图层
    let layer = CAShapeLayer()
//    扫描二维码所需要的属性
//    输入对象  图像捕捉对象，用来捕捉相应的元素7 23763 23173 2
    private lazy var input : AVCaptureDeviceInput? = nil
//    MARK:  懒加载

//    输出对象
    private lazy var output : AVCaptureMetadataOutput = {
        let out = AVCaptureMetadataOutput()
        let rect = self.view.frame
        let containerRect = self.cjbImageview.frame
        
        let x = containerRect.origin.y / rect.height
        let y = containerRect.origin.x / rect.width
        let w = containerRect.height / rect.height
        let h = containerRect.width / rect.width
        
        out.rectOfInterest = CGRect(x: x, y: y, width: w, height: h)
        
        return out
    }()
//    回话层对象
    private lazy var session : AVCaptureSession = AVCaptureSession()
//    预览图层
    lazy var previewLayer : AVCaptureVideoPreviewLayer = {
        let previewLayer : AVCaptureVideoPreviewLayer =  AVCaptureVideoPreviewLayer(session: self.session)
       previewLayer.frame = UIScreen.main.bounds
        return previewLayer
    }()
    
    // MARK:  方法
    override func viewDidLoad() {
        super.viewDidLoad()

//        开始扫描二维码
        scanQRCode()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        1.开启动画
        startAnimation()
    }
    
    
    // MARK:  抽取的方法
    
    // 开启动画
    func startAnimation() -> () {
        
        self.cjbTopConstraint.constant = -self.borderHeight.constant
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            
            UIView.setAnimationRepeatCount(Float(uint.max))
            self.cjbTopConstraint.constant = self.borderHeight.constant
            self.view.layoutIfNeeded()
            
        })
    }
//    扫描二维码
    func scanQRCode() -> () {
        
//       对懒加载的input进行赋值
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            return
        }
        input = try? AVCaptureDeviceInput.init(device: device)
        
//        1.判断是否能加入输入
        if !session.canAddInput(input) {
            return
        }
//        2.判断是否能加入输出
        if !session.canAddOutput(output) {
            return
        }
//        3.加入输入和输出
        session.addInput(input)
        session.addOutput(output)
//        4.设置输出能够解析的数据类型
        output.metadataObjectTypes = output.availableMetadataObjectTypes
//        5.设置监听监听解析到的数据类型
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
//        6.添加预览图层
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = view.bounds
//        7.开始扫描
        session.startRunning()
    }
    // MARK:  内部控制事件
//    跳转到相册
    @IBAction func photoes(_ sender: Any) {
        
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) else {
            return
        }
        
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        self.present(imageVC, animated: true, completion: nil)
    }
//    清除layer的子视图
    func clearLayers() -> () {
        layer.removeFromSuperlayer()
    }
//    对二维码进行描边
    func drawLines(object : AVMetadataMachineReadableCodeObject) -> () {
//        1.进行安全校验，看是否有数据
        guard let array = object.corners else {
            return
        }
//        2.创建保存视图的图层
        layer.frame = UIScreen.main.bounds
        layer.borderWidth = 2
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.red.cgColor
        
//        3.创建UIBezierPath绘制矩形
        let linePath = UIBezierPath()
        linePath.lineWidth = 2
        var point = CGPoint()
        var index = 0
        
        point = CGPoint(dictionaryRepresentation: array[index] as! CFDictionary)!
        
        index += 1
//        4.连接线段到某个点
        linePath.move(to: point)
//        5.连接其他的点
        while index < array.count {
            DLog(messge: index)
            point = CGPoint(dictionaryRepresentation: array[index] as! CFDictionary)!
            DLog(messge: point)
            index += 1
            linePath.addLine(to: point)
        }
//        6.关闭路径，并添加图层
        linePath.close()
        layer.path = linePath.cgPath
        previewLayer.addSublayer(layer)

    }
//    设置好控制器器
    class func shareInstance() -> UIViewController {
        let sb = UIStoryboard(name: "QRCodeViewController", bundle: nil)
        let vc = sb.instantiateInitialViewController()!
        return vc
    }
}

extension QRCodeViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        1.判断是否能取到图片
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
//        2.转成ciimage
        guard let ciimage = CIImage(image: image) else {
            return
        }
//        3.从选中的图片中读取二维码
//        3.1创建探测器
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow])
        let resoult = (detector?.features(in: ciimage))!
        
        
        for result in resoult
        {
            guard (result as! CIQRCodeFeature).messageString != nil else {
                return
            }
            DLog(messge: (result as! CIQRCodeFeature).messageString!)
            infomationLabel.text = (result as! CIQRCodeFeature).messageString!
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension QRCodeViewController : AVCaptureMetadataOutputObjectsDelegate
{
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!)
    {
//        1.获取到文字信息
        infomationLabel.text = (metadataObjects.last as AnyObject).stringValue
//        2.清除之前画的图层
        clearLayers()
        guard let metadata = metadataObjects.last as? AVMetadataObject else {
            return
        }
        let object = previewLayer.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
//        3.对扫描到的二维码进行描边
        drawLines(object:object)
        
    }
}


