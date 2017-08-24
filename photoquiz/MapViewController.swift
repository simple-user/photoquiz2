//
//  MapViewController.swift
//  PhotoQuizz
//
//  Created by Oleksandr on 8/11/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import UIKit
import MapKit
import Pulley
import Presentr

class MapViewController: UIViewController {

    // input
    func setPoints(points: [PhotoPoint]) {
        self.points = points
        self.centerMapOnLocation()
    }

    var successCallback: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centerMapOnLocation()
        self.infoController.onButtinComletion = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.collapseMap(weakSelf)
            weakSelf.successCallback?()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.rivneMapView.setRegion(self.stockRegion, animated: false)
    }

    @IBOutlet fileprivate var rivneMapView: MKMapView!
    fileprivate var tappedPoints = Set<PhotoPoint>()
    fileprivate var points: [PhotoPoint]!
    fileprivate var stockRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50.610946246904518,
                                                                                    longitude: 26.257657015311921),
                                                     span: MKCoordinateSpan(latitudeDelta: 0.17014498714487303,
                                                                            longitudeDelta: 0.1868872709158893))

    let infoController = InfoViewController()
    fileprivate let presenter: Presentr = {

        let customPresenter = Presentr(presentationType: .alert)
        customPresenter.transitionType = TransitionType.coverVertical
        customPresenter.dismissTransitionType = .crossDissolve
        customPresenter.roundCorners = false
        customPresenter.backgroundColor = .black
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = true
        customPresenter.dismissOnSwipeDirection = .top
        return customPresenter
    }()


    private func centerMapOnLocation() {
        guard points != nil else { return }
        guard let coordinateRegion = self.getCoordRegion() else { return }
        self.rivneMapView.setRegion(coordinateRegion, animated: true)
        self.addPoints()
    }

    // adding points to the map
    fileprivate func addPoints() {
        print("added points count = \(self.points.count)")
        self.rivneMapView.addAnnotations(self.points)
    }

    fileprivate func removePoints() {
        guard self.rivneMapView != nil && self.points != nil else { return }
        tappedPoints.removeAll()
        self.rivneMapView.removeAnnotations(self.points)
    }

    // get coord rect to whow all points
    // position and size of this rect will be changed every time
    // it will depend on positions of points
    private func getCoordRegion() -> MKCoordinateRegion? {
        if self.points.count == 0 {
            return nil
        } else if self.points.count == 1 {
            return nil //
        } else {
            var minX = self.points[0].coordinate.longitude
            var minY = self.points[0].coordinate.latitude
            var maxX = self.points[0].coordinate.longitude
            var maxY = self.points[0].coordinate.latitude

            for point in self.points {
                minX = point.coordinate.longitude < minX ? point.coordinate.longitude : minX
                minY = point.coordinate.latitude < minY ? point.coordinate.latitude : minY

                maxX = point.coordinate.longitude > maxX ? point.coordinate.longitude : maxX
                maxY = point.coordinate.latitude > maxY ? point.coordinate.latitude : maxY
            }

            let center = CLLocationCoordinate2D(latitude: (minY + maxY) / 2,
                                                longitude: (minX + maxX) / 2)
            let span = MKCoordinateSpan(latitudeDelta: (maxY - minY) * 1.8,
                                        longitudeDelta: (maxX - minX) * 1.5)
            return MKCoordinateRegion(center: center, span: span)
        }
    }
    
    @IBAction func collapseMap(_ sender: Any?) {
        
        if let drawer = self.parent as? PulleyViewController {
            drawer.setDrawerPosition(position: .collapsed)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {

    // dequeue for points
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKAnnotationView
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: "HardcodedId") {
            view = dequeueView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "HardcodedId")
        }
        self.setImage(#imageLiteral(resourceName: "pin2Copy"), forView: view)
        return view
    }

    // change point in to red after select
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let pin = view.annotation as? PhotoPoint else { return }
        if self.tappedPoints.contains(where: { point -> Bool in
            point.id == pin.id
        }) {
            // we have already tapped this point
            return
        }
        if pin.isTruePoint {
            self.setImage(#imageLiteral(resourceName: "true"), forView: view)
            self.infoController.isTrueAnswer = true
        }
        else {
            self.infoController.isTrueAnswer = false
            self.setImage(#imageLiteral(resourceName: "fascle"), forView: view)
        }
        self.tappedPoints.insert(pin)

        customPresentViewController(self.presenter, viewController: self.infoController, animated: true, completion: nil)

    }

    // func to set image for ping (with size correction)
    private func setImage(_ image: UIImage, forView view: MKAnnotationView) {
        view.image = image
        view.contentMode = .scaleAspectFit
        let x = view.frame.origin.x
        let y = view.frame.origin.y
        let w = view.frame.width
        let h = view.frame.height
        let w1: CGFloat = 40.0
        let h1: CGFloat = 40.0
        view.frame = CGRect(x: x + ((w - w1) / 2),
                            y: y + ((h - h1) / 2),
                            width: w1,
                            height: h1)

    }

    
}

extension MapViewController: PulleyDrawerViewControllerDelegate {
    
    func partialRevealDrawerHeight() -> CGFloat {
        return 0
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return [.open, .partiallyRevealed, .closed, .collapsed]
    }

    func collapsedDrawerHeight() -> CGFloat {
        return 0
    }
}

extension MapViewController: PulleyPrimaryContentControllerDelegate {

    func drawerPositionDidChange(drawer: PulleyViewController) {
        if drawer.drawerPosition == .collapsed || drawer.drawerPosition == .closed {
            self.rivneMapView.setRegion(self.stockRegion, animated: false)
            self.removePoints()
        }
    }
}


