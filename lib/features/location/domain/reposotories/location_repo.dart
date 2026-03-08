import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/address/domain/models/zone_model.dart';
import 'package:stackfood_multivendor/features/location/domain/reposotories/location_repo_interface.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

class LocationRepo implements LocationRepoInterface {
  final ApiClient apiClient;
  LocationRepo({required this.apiClient});

  @override
  Future<ZoneResponseModel> getZone(String? lat, String? lng) async {
    Response response = await apiClient.getData('${AppConstants.zoneUri}?lat=$lat&lng=$lng', handleError: false);
    if(response.statusCode == 200) {
      ZoneResponseModel responseModel;
      List<int>? zoneIds = ZoneModel.fromJson(response.body).zoneIds;
      List<ZoneData>? zoneData = ZoneModel.fromJson(response.body).zoneData;
      responseModel = ZoneResponseModel(true, '' , zoneIds ?? [], zoneData??[]);
      return responseModel;
    } else {
      return ZoneResponseModel(false, response.statusText, [], []);
    }
  }

  @override
  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response = await apiClient.getData('${AppConstants.geocodeUri}?lat=${latLng.latitude}&lng=${latLng.longitude}');
    
    if (kDebugMode) {
      debugPrint('====> Geocode API Response: ${response.statusCode} - ${response.body}');
    }
    
    if(response.statusCode == 200 && response.body != null) {
      dynamic body = response.body;
      
      // Try various possible response formats
      
      // Format 1: Direct address field
      if(body['formatted_address'] != null) {
        return body['formatted_address'].toString();
      }
      else if(body['address'] != null) {
        return body['address'].toString();
      }
      // Format 2: Results array (Google Maps like)
      else if(body['results'] != null && body['results'] is List && body['results'].isNotEmpty) {
        dynamic firstResult = body['results'][0];
        if(firstResult['formatted_address'] != null) {
          return firstResult['formatted_address'].toString();
        }
        else if(firstResult['address'] != null) {
          return firstResult['address'].toString();
        }
        // Try nested address components
        else if(firstResult['address_components'] != null) {
          return _extractAddressFromComponents(firstResult['address_components']);
        }
      }
      // Format 3: Nested result object
      else if(body['result'] != null) {
        dynamic result = body['result'];
        if(result['formatted_address'] != null) {
          return result['formatted_address'].toString();
        }
        else if(result['address'] != null) {
          return result['address'].toString();
        }
        else if(result['address_components'] != null) {
          return _extractAddressFromComponents(result['address_components']);
        }
      }
      // Format 4: Data wrapper
      else if(body['data'] != null) {
        dynamic data = body['data'];
        if(data is String && data.isNotEmpty) {
          return data;
        }
        else if(data is Map) {
          if(data['formatted_address'] != null) {
            return data['formatted_address'].toString();
          }
          else if(data['address'] != null) {
            return data['address'].toString();
          }
          else if(data['address_components'] != null) {
            return _extractAddressFromComponents(data['address_components']);
          }
        }
      }
      // Format 5: Response body is directly a string
      else if(body is String && body.isNotEmpty) {
        return body;
      }
      // Format 6: Try to extract from any key containing 'address' or 'location'
      else {
        for(String key in body.keys) {
          if(key.toLowerCase().contains('address') || key.toLowerCase().contains('location')) {
            dynamic value = body[key];
            if(value is String && value.isNotEmpty) {
              return value;
            }
            else if(value is Map && value['formatted_address'] != null) {
              return value['formatted_address'].toString();
            }
            else if(value is List && value.isNotEmpty && value[0] is Map) {
              return value[0]['formatted_address']?.toString() ?? value[0].toString();
            }
          }
        }
      }
    }
    
    // Fallback: Return coordinates if no address found
    return 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}';
  }
  
  // Helper method to extract address from address_components
  String _extractAddressFromComponents(dynamic addressComponents) {
    if(addressComponents is! List) return 'Unknown Location';
    
    List<String> addressParts = [];
    for(var component in addressComponents) {
      if(component is Map) {
        // Prefer long_name over short_name
        String value = component['long_name']?.toString() ?? component['short_name']?.toString() ?? '';
        if(value.isNotEmpty && !value.contains('undefined')) {
          addressParts.add(value);
        }
      }
    }
    
    return addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown Location';
  }


  @override
  Future<Response> searchLocation(String text) async {
    return await apiClient.getData('${AppConstants.searchLocationUri}?search_text=$text');
  }

  Future<Response> getById(int id) async {
    Response response = await apiClient.getData('${AppConstants.placeDetailsUri}?placeid=$id');
    return response;
  }

  @override
  Future<Response> updateZone() async {
    return await apiClient.getData(AppConstants.updateZoneUri);
  }

  @override
  Future getList({int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future<Response> get(String? id) async {
    Response response = await apiClient.getData('${AppConstants.placeDetailsUri}?placeid=$id');
    return response;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

}
