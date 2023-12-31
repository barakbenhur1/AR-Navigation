//
//  GADBannerView+EXT.swift
//  ARGo
//
//  Created by ברק בן חור on 10/11/2023.
//

import GoogleMobileAds

class CustomGADBannerView: GADBannerView {
    private var bannerViewDidReceiveAd: (() -> ())?
    
    private func notApproved() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .boldSystemFont(ofSize: 9)
        label.text = NSLocalizedString("App Tracking Transparency Approval text short", comment: "")
        label.textAlignment = .center
        let button = UIButton()
        button.setTitleColor(.systemGreen, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 12)
        button.setTitle(NSLocalizedString("settings", comment: ""), for: .normal)
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(button)
        stack.addTo(view: self, leading: 4, trailing: -4)
        button.addTarget(self, action: #selector(goToAppPrivacySettings), for: .touchUpInside)
    }
    
    @objc private func goToAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            assertionFailure("Not able to open App privacy settings")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    override func load(_ request: GADRequest?) {
        if let request {
            super.load(request)
        }
        else {
            if SubscriptionService.shared.removedAdsPurchesd {
                isHidden = true
            }
            else {
                isHidden = false
                notApproved()
            }
        }
    }
    
    func bannerViewDidReceiveAd(_ complition: @escaping () -> ()) {
        bannerViewDidReceiveAd = complition
    }
}

extension CustomGADBannerView:  GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        bannerViewDidReceiveAd?()
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}
