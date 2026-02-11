import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class WeatherService {
  Future<String> getLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Konum servisiniz kapalı');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Konum izni vermelisiniz...');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Konum izni kalıcı olarak reddedildi (Ayarlar’dan açmalısın).',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final List<Placemark> placeMark = await placemarkFromCoordinates(
      position.latitude,
      position.longitude, // ✅ burası longitude olmalı
    );

    final String? city = placeMark.isNotEmpty ? placeMark[0].locality : null;
    if (city == null || city.isEmpty) {
      return Future.error('Şehir bilgisi alınamadı');
    }

    return city;
  }

  Future<void> getWeatherData() async {
    final String city = await getLocation();

    final String url =
        "https://api.collectapi.com/weather/getWeather?lang=tr&city=$city";
    const Map headers = {
      "authorization": "apikey 2gtmDjlEsWw4eAkcAvumt3:2Wvyv5d9jwvXW0dz2UQqAc",
      "content-type": "application/json",
    };

    final dio = Dio();

    final response = await dio.get(url);

    if (response.statusCode != 200) {
      return Future.error('Bir hata meydana geldi..');
    }

    print(response.data);
  }
}
