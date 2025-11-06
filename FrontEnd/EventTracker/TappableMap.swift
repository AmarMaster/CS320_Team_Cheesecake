import SwiftUI
import MapKit

struct TappableMap: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var pickedCoordinate: CLLocationCoordinate2D?

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TappableMap

        init(parent: TappableMap) {
            self.parent = parent
        }

        @objc func mapTapped(_ recognizer: UITapGestureRecognizer) {
            guard let mapView = recognizer.view as? MKMapView else { return }
            let point = recognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            // Update picked coordinate with tapped location
            parent.pickedCoordinate = coordinate

            // Preserve zoom (span) but move center to tapped coordinate
            parent.region = MKCoordinateRegion(
                center: coordinate,
                span: parent.region.span
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.setRegion(region, animated: false)
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)
        mapView.delegate = context.coordinator

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let currentRegion = uiView.region
        let newRegion = MKCoordinateRegion(center: region.center, span: region.span)

        // Update region only if it changed significantly
        if abs(currentRegion.center.latitude - newRegion.center.latitude) > 0.0001 ||
            abs(currentRegion.center.longitude - newRegion.center.longitude) > 0.0001 ||
            abs(currentRegion.span.latitudeDelta - newRegion.span.latitudeDelta) > 0.0001 ||
            abs(currentRegion.span.longitudeDelta - newRegion.span.longitudeDelta) > 0.0001 {
            uiView.setRegion(newRegion, animated: true)
        }

        // Remove existing annotations first
        uiView.removeAnnotations(uiView.annotations)

        // Add an annotation for the selected coordinate if available
        if let coord = pickedCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            uiView.addAnnotation(annotation)
        }
    }
}
