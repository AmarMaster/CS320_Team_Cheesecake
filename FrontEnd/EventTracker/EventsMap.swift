import SwiftUI
import MapKit

struct EventsMap: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var events: [EventData]
    @Binding var selectedEvent: EventData?
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: EventsMap

        init(_ parent: EventsMap) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let newRegion = mapView.region

            // Update on new region
            DispatchQueue.main.async {
                self.parent.region = newRegion
            }
        }

        // Selecting annotations still works
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? MKPointAnnotation else { return }
            guard let idString = annotation.subtitle else { return }
            guard let eventId = Int(idString) else { return }
            guard let event = parent.events.first(where: { $0.id == eventId }) else { return }

            DispatchQueue.main.async {
                self.parent.selectedEvent = event
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.setRegion(region, animated: false)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

        // Apply region changes if movement
        if !regionsEqual(uiView.region, region) {
            uiView.setRegion(region, animated: true)
        }

        // Update annotations
        uiView.removeAnnotations(uiView.annotations)

        let annotations = events.compactMap { event -> MKPointAnnotation? in
            guard let coord = event.coordinate else { return nil }
            // Map markers here...
            let annotation = MKPointAnnotation()
            annotation.coordinate = coord
            annotation.title = event.name
            annotation.subtitle = event.id.map(String.init)
            
            return annotation
        }

        uiView.addAnnotations(annotations)
    }

    // Compare regions
    private func regionsEqual(_ r1: MKCoordinateRegion, _ r2: MKCoordinateRegion) -> Bool {
        let threshold = 0.0001
        return
            abs(r1.center.latitude - r2.center.latitude) < threshold &&
            abs(r1.center.longitude - r2.center.longitude) < threshold &&
            abs(r1.span.latitudeDelta - r2.span.latitudeDelta) < threshold &&
            abs(r1.span.longitudeDelta - r2.span.longitudeDelta) < threshold
    }
}