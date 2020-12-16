part of 'places_bloc.dart';

@immutable
abstract class PlacesState {}

class PlacesInitial extends PlacesState {}

class PlacesLoading extends PlacesState {}

class PlaceLoaded extends PlacesState {

  final List<Place> places;
  final String nextPageToken;

  PlaceLoaded(this.places, this.nextPageToken);

}

class PlaceLoadFailed extends PlacesState {}
