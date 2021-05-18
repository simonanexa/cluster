import 'dart:async';
import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/helpers/map_helper.dart';
import 'package:map/helpers/map_marker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _mapController = Completer();

  /// Set of displayed markers and cluster markers on the map
  Set<Marker> _markers = Set();

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker> _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 5;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;


  /// Color of the cluster circle
  final Color _clusterColor = Colors.blue;

  /// Color of the cluster text
  final Color _clusterTextColor = Colors.white;

  /// Example marker coordinates
  final List<LatLng> _markerLocations = [
    LatLng(41.147125, -8.611249),
    LatLng(41.145599, -8.610691),
    LatLng(41.145645, -8.614761),
    LatLng(41.146775, -8.614913),
    LatLng(41.146982, -8.615682),
    LatLng(41.140558, -8.611530),
    LatLng(41.138393, -8.608642),
    LatLng(41.137860, -8.609211),
    LatLng(41.138344, -8.611236),
    LatLng(41.139813, -8.609381),
    LatLng(41.139813, -8.609381),
  ];

  /// Called when the Google Map widget is created. Updates the map loading state
  /// and inits the markers.
  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);

    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  /// Inits [Fluster] and all the markers with network images and updates the loading state.
  void _initMarkers() async {
    final List<MapMarker> markers = [];

    for (LatLng markerLocation in _markerLocations) {
      markers.add(
        MapMarker(
          id: _markerLocations.indexOf(markerLocation).toString(),
          position: markerLocation,
          icon: BitmapDescriptor.defaultMarker,
          onTap: (){
            print(_markerLocations.indexOf(markerLocation).toString());
          }
        ),
      );
    }

    _clusterManager = Fluster<MapMarker>(
      minZoom: _minClusterZoom,
      maxZoom: _maxClusterZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: markers,
      createCluster: (
          BaseCluster cluster,
          double lng,
          double lat,
          ) =>
          MapMarker(
            id: cluster.id.toString(),
            position: LatLng(lat, lng),
            isCluster: cluster.isCluster,
            clusterId: cluster.id,
            pointsSize: cluster.pointsSize,
            childMarkerId: cluster.childMarkerId,
            onTap: (){
              print("cluster id: ${cluster.childMarkerId}");
            }
          ),
    );


    // _markers = _clusterManager
    //     .clusters([-180, -85, 180, 85], _currentZoom.toInt())
    //     .map((cluster) => cluster.toMarker())
    //     .toList().toSet();
    await _updateMarkers();
  }





  static Future<BitmapDescriptor> getClusterMarker(
      int clusterSize,
      Color clusterColor,
      Color textColor,
      int width,
      ) async {
    assert(clusterSize != null);
    assert(clusterColor != null);
    assert(width != null);

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = clusterColor;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double radius = width / 2;

    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );

    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );

    final image = await pictureRecorder.endRecording().toImage(
      radius.toInt() * 2,
      radius.toInt() * 2,
    );
    final data = await image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }





  /// Gets the markers and clusters to be displayed on the map for the current zoom level and
  /// updates state.
  Future<void> _updateMarkers([double updatedZoom]) async {
    if (_clusterManager == null || updatedZoom == _currentZoom) return;

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }

    setState(() {
      _areMarkersLoading = true;
    });

    final updatedMarkers = await Future.wait(_clusterManager.clusters(
        [-180, -85, 180, 85], _currentZoom.toInt()).map((mapMarker) async {
      if (mapMarker.isCluster) {
        mapMarker.icon = await getClusterMarker(
          mapMarker.pointsSize,
          _clusterColor,
          _clusterTextColor,
          80,
        );
      }

      return mapMarker.toMarker();
    }).toList());



    _markers
      ..clear()
      ..addAll(updatedMarkers);



    setState(() {
      _areMarkersLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Markers and Clusters Example'),
      ),
      body: Stack(
        children: <Widget>[
          // Google Map widget
          Opacity(
            opacity: _isMapLoading ? 0 : 1,
            child: GoogleMap(
              mapToolbarEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(41.143029, -8.611274),
                zoom: _currentZoom,
              ),
              markers: _markers,
              onMapCreated: (controller) => _onMapCreated(controller),
              onCameraMove: (position) => _updateMarkers(position.zoom),
            ),
          ),

          // Map loading indicator
          Opacity(
            opacity: _isMapLoading ? 1 : 0,
            child: Center(child: CircularProgressIndicator()),
          ),

          // Map markers loading indicator
          if (_areMarkersLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Card(
                  elevation: 2,
                  color: Colors.grey.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      'Loading',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
