import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearby/bloc/places_bloc.dart';
import 'package:nearby/place_card.dart';

import 'models/place.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final PlacesBloc _bloc = PlacesBloc();
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _places = [];
  bool _isLoading = false;

  void _placeLoadingListener(BuildContext context, PlacesState state) {
    if(state is PlaceLoaded) {
      _places.removeLast();
      _places.addAll(state.places);
      _isLoading = false;
      state.places.forEach((element) => print(element.data().toString()));
    }
    else if(state is PlaceLoadFailed) {
      _places.removeLast();
      _isLoading = false;
    }
  }

  void _loadPlace() {
    _bloc.add(LoadPlaces(_places.isNotEmpty ? _places.last : null));
    _places.add(null);
    print('Last: $_isLoading');
    _isLoading = true;
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && 
      !_scrollController.position.outOfRange && !_isLoading) {
      _loadPlace();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlace());
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() { 
    _bloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Places')),
      body: SafeArea(
        child: BlocConsumer<PlacesBloc, PlacesState>(
          cubit: _bloc,
          listener: _placeLoadingListener,
          builder: (context, state) => ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(5.0),
            scrollDirection: Axis.horizontal,
            itemCount: _places.length,
            itemBuilder: (context, i) => _places[i] != null ? 
              PlaceCard(_places[i].data()) : SizedBox(
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator()
              ),
          )
        ),
      ),
    );
  }

  Widget _placeList(List<Place> places) {
    return ListView.separated(
      itemCount: places.length,
      separatorBuilder: (context, i) => Divider(),
      itemBuilder: (context, i) => Container(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: places[i].photo,
              placeholder: (context, url) => CircularProgressIndicator(),
              width: 100.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    places[i].name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Rating: ${places[i].rating.toString()}'),
                  Text('Distance: ${places[i].distance}'),
                  Text('Estimated Time: ${places[i].estimatedTime}'),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}