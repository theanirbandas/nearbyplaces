import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:nearby/models/place.dart';

part 'places_event.dart';
part 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  
  final String api = 'AIzaSyAXUZJV__NaYwjpvaMjAfZgZ4AqfaG5gww';

  PlacesBloc() : super(PlacesInitial());

  @override
  Stream<PlacesState> mapEventToState(PlacesEvent event) async* {
    if(event is LoadPlaces) {
      yield* _mapLoadPlaces(event.location, event.pageToken);
    }
  }

  Stream<PlacesState> _mapLoadPlaces(String location, String pageToken) async* {
    yield PlacesLoading();

    Dio dio = Dio();

    Map<String, dynamic> parameters = {
      'location': location,
      'radius': 1500,
      'key': api
    };

    if(pageToken != null)
      parameters['pagetoken'] = pageToken;

    try {
      Response response = await dio.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json', queryParameters: parameters);

      if(response.statusCode == HttpStatus.ok) {
        String nextPageToken = response.data['next_page_token'];
        List<Place> places = await _getPlaces(location, response.data['results']);

        yield PlaceLoaded(places, nextPageToken);
      }
    } on Exception {
      yield PlaceLoadFailed();
    }
  }

  Future<List<Place>> _getPlaces(String location, List data) async {
    Dio dio = Dio();

    List<Place> places = [];

    for(int i=0;i<data.length;i++) {
      var element = data[i];
    
      Response response = await dio.get('https://maps.googleapis.com/maps/api/distancematrix/json', queryParameters: {
        'origins': location,
        'destinations': '${element['geometry']['location']['lat']},${element['geometry']['location']['lng']}',
        'mode': 'walking',
        'key': 'AIzaSyA7hFWktlCsXxOn_U_pnyzJHkqS0k-F7WE'
      });

      if(response.statusCode == HttpStatus.ok) {
        print(element['rating']);
        places.add(Place(
          name: element['name'],
          photo: 'https://maps.googleapis.com/maps/api/place/photo?photoreference='
                  '${element['photos'][0]['photo_reference']}&maxwidth=${element['photos'][0]['width']}'
                  '&key=$api',
          rating: double.parse(element['rating']?.toString() ?? '0'),
          location: '${element['geometry']['location']['lat']},${element['geometry']['location']['lng']}',
          distance: response.data['rows'][0]['elements'][0]['distance']['text'],
          estimatedTime: response.data['rows'][0]['elements'][0]['duration']['text'],
        ));
      }
    }

    return places;
  }
}
