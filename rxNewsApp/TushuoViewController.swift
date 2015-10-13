//
//  TushuoViewController.swift
//  
//
//  Created by Shakugan on 15/10/5.
//
//

import UIKit

class TushuoViewController: UIViewController,UITableViewDataSource {
    
    var newsArray = Array<AnyObject>()
    var articleID = String()
    @IBOutlet weak var tushuoTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tushuoTable.header = MJRefreshNormalHeader(refreshingBlock: { () -> Void in
            self.initData()
        })
        self.tushuoTable.footer = MJRefreshAutoNormalFooter(refreshingBlock: { () -> Void in
            self.loadMoreData(self.articleID)
        })
        self.tushuoTable.header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let vc = segue.destinationViewController as! tsShowCardViewController
        vc.pid = cell.tag
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tushuoTable.dequeueReusableCellWithIdentifier("tushuoCell")
//        cell.frame = CGRectMake(CGFloat(0),
//            CGFloat(Int(tushuoTable.frame.width/CGFloat(320)*CGFloat(300))*indexPath.row),tushuoTable.frame.width,tushuoTable.frame.width/CGFloat(320)*CGFloat(400))
//        let image = cell.viewWithTag(1) as! UIImageView
        let view = cell!.contentView.viewWithTag(1)
        let title = cell!.contentView.viewWithTag(2) as! UILabel
        let click = cell!.contentView.viewWithTag(3) as! UILabel
        let info = cell!.contentView.viewWithTag(4) as! UILabel
        let time = cell!.contentView.viewWithTag(5) as! UILabel
        let pid = newsArray[indexPath.row].objectForKey("pid") as! String
        cell!.tag = Int(pid)!
        title.text = newsArray[indexPath.row].objectForKey("title") as? String
        click.text = newsArray[indexPath.row].objectForKey("click") as? String
        info.text = newsArray[indexPath.row].objectForKey("count") as? String
        time.text = timeStampToString((newsArray[indexPath.row].objectForKey("pubdate") as? String)!)
        let surl = newsArray[indexPath.row].objectForKey("thumb") as! String
        let url = "http://\(surl)"
        var image = UIImageView()
        if view?.viewWithTag(6) == nil {
            view?.addSubview(image)
            image.tag = 6
        } else {
            image = view?.viewWithTag(6) as! UIImageView
        }
        image.sd_setImageWithURL(NSURL(string:url), completed: { (UIimage:UIImage!, error:NSError!, cacheType:SDImageCacheType, nsurl:NSURL!) -> Void in
            image.frame = CGRectMake(CGFloat(0),
                CGFloat(0),cell!.frame.width,cell!.frame.width/UIimage.size.width*UIimage.size.height)
//            CGRectMake(cell.frame.width/CGFloat(320)*CGFloat(8),
//                CGFloat(8),cell.frame.width-cell.frame.width/CGFloat(320)*CGFloat(16),(cell.frame.width-cell.frame.width/CGFloat(320)*CGFloat(16))/UIimage.size.width*UIimage.size.height)
        })
        return cell!
    }
    
    func initData() {
        let afManager = AFHTTPRequestOperationManager()
        let op = afManager.GET("http://pic.ecjtu.net/api.php/list", parameters: nil,
            success: { (operation:AFHTTPRequestOperation, response:AnyObject) -> Void in
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(response as! NSData , options:NSJSONReadingOptions() )
                self.newsArray = json?.objectForKey("list") as! Array<AnyObject>
                self.articleID = self.newsArray[self.newsArray.count-1].objectForKey("pubdate") as! String
                for index in 0...self.newsArray.count-1 {
                    let id:AnyObject! = self.newsArray[index].objectForKey("pid")
                    print(id)
                }
                self.tushuoTable.reloadData()
                self.tushuoTable.header.endRefreshing()
            },
            failure:{ (operation:AFHTTPRequestOperation, error:NSError) -> Void in
                self.tushuoTable.header.endRefreshing()
        })
        op!.responseSerializer = AFHTTPResponseSerializer()
        op!.start()
    }
    
    func loadMoreData(id:String) {
        let afManager = AFHTTPRequestOperationManager()
        let op = afManager.GET("http://pic.ecjtu.net/api.php/list?before=\(id)", parameters: nil,
            success: { (operation:AFHTTPRequestOperation, response:AnyObject) -> Void in
                let json: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(response as! NSData , options:NSJSONReadingOptions() )
                let count = json?.objectForKey("count") as! Int
                if count==0 {
                    self.tushuoTable.footer.endRefreshing()
                    return
                }
                let array = json?.objectForKey("list") as! Array<AnyObject>
                for index in 0...count-1 {
                    self.newsArray.append(array[index])
                }
                self.articleID = array[array.count-1].objectForKey("pubdate") as! String
                for index in 0...self.newsArray.count-1 {
                    let id:AnyObject! = self.newsArray[index].objectForKey("pid")
                    print(id)
                }
                self.tushuoTable.reloadData()
                self.tushuoTable.footer.endRefreshing()
            },
            failure:{ (operation:AFHTTPRequestOperation, error:NSError) -> Void in
                self.tushuoTable.footer.endRefreshing()
        })
        op!.responseSerializer = AFHTTPResponseSerializer()
        op!.start()
    }
    
    func timeStampToString(timeStamp:String)->String {
        
        let string = NSString(string: timeStamp)
        
        let timeSta:NSTimeInterval = string.doubleValue
        let dfmatter = NSDateFormatter()
        dfmatter.dateFormat="yyyy/MM/dd"
        
        let date = NSDate(timeIntervalSince1970: timeSta)

        return dfmatter.stringFromDate(date)
    }

}
