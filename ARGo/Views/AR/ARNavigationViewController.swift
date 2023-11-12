//
//  ARNavigationViewController.swift
//  AR
//
//  Created by ברק בן חור on 18/10/2023.
//

import UIKit
import MapKit

class ARNavigationViewController: UIViewController, TabBarViewController, NavigationViewController {
    //MARK: - @IBOutlets
    @IBOutlet weak var arView: UIView!
    @IBOutlet weak var regularView: RegularNavigationView! {
        didSet {
            regularView.trackUserLocation = .followWithHeading
            regularView.mapView.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var mapButton: UIButton! {
        didSet {
            mapButton.setImage(UIImage(named: "map"), for: .normal)
        }
    }
    
    //MARK: - Properties
    private var ar: ARNavigationView!
    
    private var routes: [MKRoute]!
    private var endPoint: CLLocation!
    
    private let mapAlpha = 0.7
    
    weak var delegate: NavigationViewControllerDelegate?
    
    var step: Int?
    
    //MARK: - Life cycle
    deinit {
        ar?.destroy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRegular()
        initAR()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupObservers()
        ar?.run()
        ar?.toggleFlashIfNeeded()
        regularView?.startMonitoringRegions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
        ar?.stopTimers()
        ar?.pause()
        ar?.turnFlashOff()
        regularView?.stopMonitoringAllRegions()
    }
    
    //MARK: - Helpers
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
            self?.ar?.stopTimers()
            self?.ar?.pause()
            self?.ar?.turnFlashOff()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil) { [weak self] _ in
            self?.ar?.trackAltitud()
            self?.ar?.run()
            self?.ar?.toggleFlashIfNeeded()
        }
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initRegular() {
        regularView.setEndPoint(point: endPoint)
        regularView.addRoutes(routes: routes)
        regularView?.goToStep(index: step)
        resetMapCameraListner()
    }
    
    private func initAR() {
        ar = ARNavigationView()
        ar.addTo(view: arView)
        ar?.addRoutes(routes: routes)
        ar?.run()
    }
    
    private func resetMapCameraListner() {
        regularView.setResetCamera { [weak self] in
            guard let self else { return }
            delegate?.resetMapCamera(view: self)
        }
    }
    
    func setRoutes(routes: [MKRoute]) {
        self.routes = routes
        regularView?.addRoutes(routes: routes)
        ar?.addRoutes(routes: routes)
    }
    
    func setDestination(endPoint: CLLocation) {
        self.endPoint = endPoint
        regularView?.setEndPoint(point: endPoint)
    }
    
    func goToStep(index: Int) {
        step = index
        regularView?.goToStep(index: index)
    }
    
    func reCenter() {
        step = nil
        regularView?.initMapCamera()
        regularView?.setTrackingUserLocation()
    }
    
    //MARK: - @IBActions
    @IBAction func handleMap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.alpha = sender.isSelected ? 1 : 0.5
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.regularView.alpha = sender.isSelected ? self.mapAlpha : 0
        }
    }
}
