//
//  ViewController.swift
//  RandomUser
//
//  Created by apple on 2019/7/17.
//  Copyright © 2019年 Benson. All rights reserved.
//

import UIKit

struct User
{
    var name:String?
    var email:String?
    var number:String?
    var image:String?
}


class ViewController: UIViewController
{
    
    
    @IBOutlet weak var userImage: UIImageView!
    
    
    @IBOutlet weak var userName: UILabel!
    
    var infoTableViewController:InfoTableViewController?
    
    var urlSession = URLSession(configuration: .default)
    
    let apiAddress = "https://randomuser.me/api/"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //设置导航控制器的导航栏颜色
        navigationController?.navigationBar.barTintColor
         = UIColor(displayP3Red: 0.67, green: 0.2, blue: 0.157, alpha: 1)
       //设置导航栏文字颜色
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        downloadInfo(withAddress: apiAddress)
    }

    func downloadInfo(withAddress webAddress:String)
    {
        //网址转url
        if let url = URL(string: webAddress)
        {
            //准备下载，session默认同步
            let task = urlSession.dataTask(with: url) { (data, response, error) in
                //网络异常
                if error != nil
                {
                    let errorCode = (error! as NSError).code
                    if errorCode == -1009
                    {
                        DispatchQueue.main.async
                            {
                                self.popAlert(withTitle: "没有网络连接")
                            }
                    }
                    else
                    {
                        DispatchQueue.main.async
                        {
                            self.popAlert(withTitle: "网络连接超时请稍后再试")
                        }
                    }
                    return
                }
                if let loadedData = data
                {
                    //解析
                    do{
                        let json = try JSONSerialization.jsonObject(with: loadedData, options: [])
                        DispatchQueue.main.async
                            {
                                self.parseJson(json: json)
                            }
                    }
                    catch
                    {
                        DispatchQueue.main.async {
                            self.popAlert(withTitle: "Sorry")
                        }
                    }
                }
            }
            task.resume()
        }
       
    }
    
    //解析过程
    func parseJson(json:Any)
    {
       if let okJson = json as? [String:Any]
       {
          if let infoArray = okJson["results"] as? [[String:Any]]
         {
           let infoDictionary = infoArray[0]
           let loadedName = userFullName(nameDictionary: infoDictionary["name"])
           let loadedEmail = infoDictionary["email"] as? String
            let loadPhone = infoDictionary["phone"] as? String
           let imageDictionary = infoDictionary["picture"] as? [String:String]
           let loadedImageAddress = imageDictionary?["large"]
           let loadedInfo = User(name: loadedName, email: loadedEmail, number: loadPhone, image: loadedImageAddress)
            settingInfo(user: loadedInfo)
         }
       }
    }
    
    //拼接名字
    func userFullName(nameDictionary:Any?) -> String?
    {
        if let okDictionary = nameDictionary as? [String:String]
        {
            //有值放进去没值放空格
            let firstName = okDictionary["first"] ?? ""
            let lastName = okDictionary["last"] ?? ""
            return firstName + lastName
        }
        else
        {
            return nil
        }
    }
    
    //跳出警告控制器
    func popAlert(withTitle title:String)
    {
        let alert = UIAlertController(title: title, message: "请稍后再试", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert,animated: true,completion: nil)
    }
    
    //设置信息
    func settingInfo(user:User)
    {
        userName.text = user.name
        infoTableViewController?.phoneLabel.text = user.number
        infoTableViewController?.emailLabel.text = user.email
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "moreInfo"
        {
            infoTableViewController = segue.destination as? InfoTableViewController
        }
    }
    
    //因为屏幕大小还没确定
    override func viewDidAppear(_ animated: Bool)
    {
        //让图片变圆形
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

