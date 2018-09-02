//
//  ViewController.swift
//  FaceRecognition
//
//  Created by 木村優太 on 2018/09/02.
//  Copyright © 2018年 木村優太. All rights reserved.
//

import UIKit
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //写真の設定
    private var picture = UIImage(named: "default.png")

    //結果表示用
    @IBOutlet weak var dipPicture: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        dipPicture.image = UIImage(named: "default.png")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func faceDetection() {
        //顔検出用のリクエスト
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            var image = self.picture
            //リクエスト結果が返ってくる。（例えば、二つの顔が検出されたら二つの結果が返ってくる。）
            for observation in request.results as! [VNFaceObservation] {
                //検出結果の表示
                print(observation)
                //検出結果を緑線で描画
                image = self.drawFaceRectangle(image: image, observation: observation)
            }
            self.dipPicture.image = image
        }
        
        //Visionが処理できるデータ型に画像を変換
        if let cgImage = self.picture?.cgImage {
            //画像データを設定してリクエストヘッダを生成
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            //顔検出を実行
            try? handler.perform([request])
        }
    }
    
    //顔の緑線描画処理(Core Graphicsを利用)
    private func drawFaceRectangle(image: UIImage?, observation: VNFaceObservation) -> UIImage? {
        
        let imageSize = image!.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        image?.draw(in: CGRect(origin: .zero, size: imageSize))
        //描画する線の太さ
        context?.setLineWidth(4.0)
        //描画する線の色
        context?.setStrokeColor(UIColor.green.cgColor)
        //線形を描画
        context?.stroke(observation.boundingBox.converted(to: imageSize))
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return drawnImage
    }
    
    @IBAction func choosePicture(_ sender: Any) {
        // カメラロールが利用可能か？
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // 写真を選ぶビュー
            let pickerView = UIImagePickerController()
            // 写真の選択元をカメラロールにする
            // 「.camera」にすればカメラを起動できる
            pickerView.sourceType = .photoLibrary
            // デリゲート
            pickerView.delegate = self
            // ビューに表示
            self.present(pickerView, animated: true)
        }
    }
    
    //リセット処理
    @IBAction func resetPicture(_ sender: Any) {
        // アラートで確認
        let alert = UIAlertController(title: "確認", message: "画像を初期化してもよいですか？", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction) -> Void in
            // デフォルトの画像を表示する
            self.dipPicture.image = UIImage(named: "default.png")
        })
        let cancelButton = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        // アラートにボタン追加
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        // アラート表示
        present(alert, animated: true, completion: nil)
    }

    // 写真を選んだ後に呼ばれる処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // 選択した写真を取得する
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // ビューに表示する
        self.picture = image
        
        faceDetection()
        
        // 写真を選ぶビューを引っ込める
        self.dismiss(animated: true)
    }
    
    
}

extension CGRect {
    //座標の変換
    func converted(to size: CGSize) -> CGRect {
        return CGRect(x: self.minX * size.width,
                      //座標系をUIKitに合わせるためにY軸の反転
                      y: (1 - self.maxY) * size.height,
                      width: self.width * size.width,
                      height: self.height * size.height)
    }
}

