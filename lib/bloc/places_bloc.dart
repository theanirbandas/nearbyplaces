import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:meta/meta.dart';

part 'places_event.dart';
part 'places_state.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  
  final _geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;

  PlacesBloc() : super(PlacesInitial());

  @override
  Stream<PlacesState> mapEventToState(PlacesEvent event) async* {
    if(event is LoadPlaces) {
      yield* _mapLoadRestaurants(event.lastPlace);
    }
  }

  Stream<PlacesState> _mapLoadRestaurants(DocumentSnapshot last) async* {
    yield PlacesLoading();

    GeoFirePoint center = _geo.point(latitude: -27.467237358115597, longitude: 153.0305656806858);
    double radius = 100;

    Query query = last != null ? 
      _firestore.collection('Restaurants').orderBy('name').startAfterDocument(last).limit(3) :
      _firestore.collection('Restaurants');//.orderBy('name').limit(3);

      print(last);

    Stream<List<DocumentSnapshot>> stream = _geo
      .collection(collectionRef: query)
      .within(center: center, radius: radius, field: 'location');
      
    await for(List<DocumentSnapshot> dataList in stream) {
      yield PlaceLoaded(dataList);
      break;
    }
  }

}
