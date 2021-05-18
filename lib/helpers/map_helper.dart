import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_marker.dart';

/// In here we are encapsulating all the logic required to get marker icons from url images
/// and to show clusters using the [Fluster] package.
class MapHelper {
  /// If there is a cached file and it's not old returns the cached marker image file
  /// else it will download the image and save it on the temp dir and return that file.
  ///
  /// This mechanism is possible using the [DefaultCacheManager] package and is useful
  /// to improve load times on the next map loads, the first time will always take more
  /// time to download the file and set the marker image.
  ///
  /// You can resize the marker image by providing a [targetWidth].


  /// Draw a [clusterColor] circle with the [clusterSize] text inside that is [width] wide.
  ///
  /// Then it will convert the canvas to an image and generate the [BitmapDescriptor]
  /// to be used on the cluster marker icons.













  /// Resizes the given [imageBytes] with the [targetWidth].
  ///
  /// We don't want the marker image to be too big so we might need to resize the image.

  /// Inits the cluster manager with all the [MapMarker] to be displayed on the map.
  /// Here we're also setting up the cluster marker itself, also with an [clusterImageUrl].
  ///
  /// For more info about customizing your clustering logic check the [Fluster] constructor.




  /// Gets a list of markers and clusters that reside within the visible bounding box for
  /// the given [currentZoom]. For more info check [Fluster.clusters].


  // static Future<List<Marker>> getClusterMarkers(
  //   Fluster<MapMarker> clusterManager,
  //   double currentZoom,
  //   Color clusterColor,
  //   Color clusterTextColor,
  //   int clusterWidth,
  // ) {
  //   assert(currentZoom != null);
  //   assert(clusterColor != null);
  //   assert(clusterTextColor != null);
  //   assert(clusterWidth != null);
  //
  //
  //   return Future.wait(clusterManager.clusters(
  //       [-180, -85, 180, 85], currentZoom.toInt()).map((mapMarker) async {
  //     if (mapMarker.isCluster) {
  //       mapMarker.icon = await getClusterMarker(
  //         mapMarker.pointsSize,
  //         clusterColor,
  //         clusterTextColor,
  //         clusterWidth,
  //       );
  //     }
  //
  //     return mapMarker.toMarker();
  //   }).toList());
  // }
}
