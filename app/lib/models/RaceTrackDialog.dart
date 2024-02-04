import 'package:app/util/dark_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:sizer/sizer.dart';

class TrackDialog extends StatefulWidget {
  final List<LatLng> rideTrackpoints;
  final List<LatLng> routeTrackpoints;
  final String title;

  const TrackDialog(this.rideTrackpoints, this.routeTrackpoints, this.title, {Key? key}) : super(key: key);

  @override
  _TrackDialogState createState() => _TrackDialogState();
}

class _TrackDialogState extends State<TrackDialog> {

  final mapController = MapController();

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        tileProvider: CancellableNetworkTileProvider(),
      tileBuilder: context.isDarkMode ? darkModeTileBuilder : null,
      );

  PolylineLayer get trackPolylineLayer => PolylineLayer(
        polylines: [
          Polyline(
            points: widget.routeTrackpoints,
            strokeWidth: 5,
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
          ),
        ],
      );

  PolylineLayer get recordingPolylineLayer => PolylineLayer(
        polylines: [
          Polyline(
            points: widget.rideTrackpoints,
            strokeWidth: 3,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 70.w,
        height: 40.h,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          child: FlutterMap(
            mapController: mapController,
            options: widget.rideTrackpoints.length + widget.routeTrackpoints.length > 0
                ? MapOptions(
                    initialCameraFit: CameraFit.bounds(
                        bounds: LatLngBounds.fromPoints(widget.routeTrackpoints..addAll(widget.rideTrackpoints)),
                        padding: EdgeInsets.all(32)))
                : MapOptions(
                    initialCenter: LatLng(52.23202828872916, 21.006132649819673), // Warsaw
                    initialZoom: 13,
                  ),
            children: [openStreetMapTileLayer, trackPolylineLayer, recordingPolylineLayer],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Zamknij"))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
  }
}
