part of 'places_bloc.dart';

@immutable
abstract class PlacesEvent {}

class LoadPlaces extends PlacesEvent {

  final String pageToken;
  final String location;

  LoadPlaces(this.location, this.pageToken);
}
