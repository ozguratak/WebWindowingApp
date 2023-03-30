

import UIKit

class OfflineViewController: UIViewController {
    
    let network = NetworkManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

//        network.reachability.whenReachable = { reachability in
//            self.showMainController()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    @IBAction func tryAgainAction(_ sender: AnyObject) {
        NetworkManager.isReachable { _ in
            self.dismiss(animated: true, completion: {
            })
        }
    }
    private func showMainController() -> Void {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
        }
    }
}
