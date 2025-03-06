import Flutter
import MapboxMaps
import MapsIndoorsCore
import MapsIndoorsMapbox

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private weak var mapsIndoorsData: MapsIndoorsData?

    init(
        messenger: FlutterBinaryMessenger,
        mapsIndoorsData: MapsIndoorsData
    ) {
        self.messenger = messenger
        self.mapsIndoorsData = mapsIndoorsData
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            arguments: args,
            binaryMessenger: messenger,
            mapsIndoorsData: mapsIndoorsData)
    }
}

class FLNativeView: NSObject, FlutterPlatformView, MPMapControlDelegate, FlutterMapView {
    private var _MapView: MapView
    private weak var mapsIndoorsData: MapsIndoorsData?
    private var mapConfig: MPMapConfigCodable?

    init(
        frame: CGRect,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        mapsIndoorsData: MapsIndoorsData?
    ) {
        let arguments = args as? [String: Any]
        self.mapsIndoorsData = mapsIndoorsData
        
        if let configArgs = arguments?["mapConfig"] as? String {
            mapConfig = try? JSONDecoder().decode(MPMapConfigCodable.self, from: configArgs.data(using: .utf8)!)
        }

        let options = if let initialCamPos = arguments?["initialCameraPosition"] as? String, let position = try? JSONDecoder().decode(CameraPosition.self, from: initialCamPos.data(using: .utf8)!) {
            Self.makeMBCameraPosition(cameraPosition: position)
        } else {
            Self.makeMBCameraPosition()
        }

        let mapInitOptions = MapInitOptions(cameraOptions: options)

        _MapView = MapView(frame: frame, mapInitOptions: mapInitOptions)
        _MapView.mapboxMap.loadStyle(.streets)
        super.init()

        mapsIndoorsData?.mapView = self

        if (MPMapsIndoors.shared.ready) {
            mapsIndoorsIsReady()
        } else {
            mapsIndoorsData?.delegate.append(MIReadyDelegate(view: self))
        }
    }

    func view() -> UIView {
        return _MapView
    }
    
    func mapsIndoorsIsReady() {
        guard mapsIndoorsData?.mapView != nil else { return }
        
        DispatchQueue.main.async { [self] in
            let config = MPMapConfig(mapBoxView: _MapView, accessToken: Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as? String ?? "")
            config.setMapsIndoorsTransitionLevel(zoom: mapConfig?.mapsindoorsTransitionLevel ?? 15)
            if let mapboxStyle = mapConfig?.mapStyleUri, let styleUri = StyleURI(rawValue: mapboxStyle) {
                self._MapView.mapboxMap.loadStyle(styleUri)
                config.useMapsIndoorsStyle(value: false)
            }
            if let mapControl = MPMapsIndoors.createMapControl(mapConfig: config) {
                mapControl.showUserPosition = mapConfig?.showUserPosition ?? false
                mapsIndoorsData?.mapControl = mapControl
                mapsIndoorsData?.directionsRenderer = nil
                mapsIndoorsData?.mapControlMethodChannel?.invokeMethod("create", arguments: nil)
                mapControl.floorSelector = mapsIndoorsData?.floorSelector
            }
        }
    }
    
    func animateCamera(cameraUpdate: CameraUpdate, duration: Int) throws {
        guard let update = makeMBCameraUpdate(cameraUpdate: cameraUpdate) else {
            throw MPError.unknownError
        }
        
        DispatchQueue.main.async {
            self._MapView.mapboxMap.setCamera(to: update)
        }
    }
    
    func moveCamera(cameraUpdate: CameraUpdate) throws {
        try animateCamera(cameraUpdate: cameraUpdate, duration: 0)
    }

    static func makeMBCameraPosition(cameraPosition: CameraPosition? = nil) -> CameraOptions? {
        guard let cameraPosition else { return nil }
        
        let camera = CameraState(center: cameraPosition.target.coordinate, padding: .zero, zoom: CGFloat(cameraPosition.zoom), bearing: CLLocationDirection(cameraPosition.bearing), pitch: CGFloat(cameraPosition.tilt))
        return CameraOptions(cameraState: camera)
    }
    
    func makeMBCameraUpdate(cameraUpdate: CameraUpdate) -> CameraOptions? {
        let camera = _MapView.mapboxMap.cameraState
        var update = CameraOptions(cameraState: camera)
        
        switch cameraUpdate.mode {
        case "fromPoint":
            guard let point = cameraUpdate.point else {
                return nil
            }
            
            update.center = point.coordinate
            
        case "fromBounds":
            guard let bounds = cameraUpdate.bounds else {
                return nil
            }

            let camerabounds = CameraBoundsOptions(bounds: CoordinateBounds(southwest: bounds.southWest, northeast: bounds.northEast))
            update.center = camerabounds.bounds?.center
            
        case "zoomBy":
            update.zoom = CGFloat(cameraUpdate.zoom!)
            
        case "zoomTo":
            update.zoom = CGFloat(cameraUpdate.zoom!)
            
        case "fromCameraPosition":
            guard let position = cameraUpdate.position else {
                return nil
            }

            update.center = position.target.coordinate
            update.bearing = CLLocationDirection(position.bearing)
            update.pitch = CGFloat(position.tilt)
            if let zoom = cameraUpdate.zoom {
                update.zoom = CGFloat(zoom)
            }
            
        default:
            return nil
        }

        return update
    }
    
    func showCompassOnRotate(_ show: Bool) throws {
        if show {
            _MapView.ornaments.options.compass.visibility = .adaptive
        } else {
            _MapView.ornaments.options.compass.visibility = .hidden
        }
    }
}

class MIReadyDelegate: MapsIndoorsReadyDelegate {
    weak var view: FLNativeView?
    
    init(view: FLNativeView) {
        self.view = view
    }
    
    func isReady(error: MPError?) {
        if error == .invalidApiKey || error == .networkError || error == .unknownError {
            // TODO: Do nothing i guees?
        } else {
            view?.mapsIndoorsIsReady()
        }
    }
}

private class MPMapConfigCodable: Codable {
    var mapsindoorsTransitionLevel: Int?
    var textSize: Int?
    var showFloorSelector: Bool?
    var showInfoWindowOnLocationClicked: Bool?
    var showUserPosition: Bool?
    var useDefaultMapsIndoorsStyle: Bool?
    var mapStyleUri: String?
}
