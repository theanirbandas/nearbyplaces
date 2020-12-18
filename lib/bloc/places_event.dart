part of 'places_bloc.dart';

@immutable
abstract class PlacesEvent extends Equatable {

  @override
  List<Object> get props => [];
}

class LoadPlaces extends PlacesEvent {

  final DocumentSnapshot lastPlace;

  LoadPlaces(this.lastPlace);

  @override
  List<Object> get props => [lastPlace];
}
