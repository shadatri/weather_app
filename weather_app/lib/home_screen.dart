import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? lat;
  String? long;
  String? acc;
  String? deg;
  String? getW;
  Position? position;
  Placemark? placemark;

      WeatherFactory wf = WeatherFactory('03041b70c0e860bbfa0c6d643bbdb6f8');
  Future<bool> checkServicePermission() async {
    var isEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission;
    print(isEnabled);
    if (!isEnabled) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enable location')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Location permission is denied, you cannot use the app without allowing location permission.')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Location permission is denied, please enable in the settings')));
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    if (!await checkServicePermission()) {
      return;
    }
    await Geolocator.getCurrentPosition().then((value) async {
      List<Placemark> getLOc =
          await placemarkFromCoordinates(value.latitude, value.longitude);

      
      Weather w =
          await wf.currentWeatherByLocation(value.latitude, value.longitude);

      setState(() {
        position = value;
        lat = position?.latitude.toString();
        long = position?.longitude.toString();
        acc = position?.accuracy.toString();
        deg = w.temperature!.celsius.toString();
        placemark = getLOc[0];
        print(getLOc[0]);
      });
    });
    print(position);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentPosition();
  }

  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text("TEMPERATURE SA LOCATION MO: ${deg}"),
            Text("Latitude: ${lat}"),
            Text("Longtitude: ${long}"),
            Text("Accuracy: ${acc}"),
            Text(
                "${placemark == null ? "" : placemark!.thoroughfare} ${placemark == null ? "" : placemark!.street} ${placemark == null ? "" : placemark!.locality}  ${placemark == null ? "" : placemark!.subAdministrativeArea} ${placemark == null ? "" : placemark!.administrativeArea}   ${placemark == null ? "" : placemark!.country}"),
            TextField(
              controller: controller,
            ),
            ElevatedButton(onPressed: () async{
              Weather w = await wf.currentWeatherByCityName(controller.text);
setState(() {
   getW = w.temperature!.celsius.toString();
});
              print(w);
            }, child: Text("Get weather")),
            if(getW != null)
             Text("TEMPERATURE SA LOCATION na pinili mo: ${getW}"),
          ]),
        ),
      ),
    );
  }
}
