part of 'places_bloc.dart';

@immutable
abstract class PlacesState {}

class PlacesInitial extends PlacesState {}

class PlacesLoading extends PlacesState {}

class PlaceLoaded extends PlacesState {

  final List<DocumentSnapshot> places;

  PlaceLoaded(this.places);

}

class PlaceLoadFailed extends PlacesState {}
