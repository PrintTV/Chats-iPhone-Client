import UIKit

let account = Account()

let baseURL = NSURL(string: "https://acani-chats.herokuapp.com")
//let baseURL = NSURL(string: "http://localhost:5100")

let AccountAccessTokenKey = "AccountAccessTokenKey"

class Account: NSObject {
    var phone: String!
    dynamic var accessToken: String! {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(AccountAccessTokenKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: AccountAccessTokenKey)
        }
    }
    var user: User!
    dynamic var users = [User]()
    var chats = [Chat]()

    func logOut() -> NSURLSessionDataTask {
        let activityOverlayView = ActivityOverlayView.sharedView()
        activityOverlayView.showWithTitle("Deleting")

        let request = NSMutableURLRequest(URL: URLWithPath("/sessions"))
        request.HTTPMethod = "DELETE"
        request.setValue("Bearer "+accessToken, forHTTPHeaderField: "Authorization")
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let statusCode = (response as! NSHTTPURLResponse).statusCode

            dispatch_async(dispatch_get_main_queue(), {
                activityOverlayView.dismissAnimated(true)

                switch statusCode {
                case 200:
                    self.reset()
                default:
                    let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as! Dictionary<String, String>?
                    UIAlertView(dictionary: dictionary, error: error, delegate: self).show()
                }
            })
        })
        dataTask.resume()
        return dataTask
    }

    func deleteAccount() -> NSURLSessionDataTask {
        let activityOverlayView = ActivityOverlayView.sharedView()
        activityOverlayView.showWithTitle("Deleting")

        let request = NSMutableURLRequest(URL: URLWithPath("/me"))
        request.HTTPMethod = "DELETE"
        request.setValue("Bearer "+accessToken, forHTTPHeaderField: "Authorization")
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            let statusCode = (response as! NSHTTPURLResponse).statusCode

            dispatch_async(dispatch_get_main_queue(), {
                activityOverlayView.dismissAnimated(true)

                switch statusCode {
                case 200:
                    self.reset()
                default:
                    let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as! Dictionary<String, String>?
                    UIAlertView(dictionary: dictionary, error: error, delegate: self).show()
                }
            })
        })
        dataTask.resume()
        return dataTask
    }

    func setUserWithAccessToken(accessToken: String, firstName: String, lastName: String) {
        let userIDString = accessToken.substringToIndex(advance(accessToken.endIndex, -33))
        let userID = UInt(userIDString.toInt()!)
        user = User(ID: userID, username: "", firstName: firstName, lastName: lastName)
    }

    private func reset() {
        phone = nil
        accessToken = nil
        user = nil
        users = []
        chats = []
    }
}
