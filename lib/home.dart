import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearby/bloc/places_bloc.dart';

import 'models/place.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final String _location = '-27.467237358115597,153.0305656806858';

  final PlacesBloc _bloc = PlacesBloc();
  
  String _nextPageToken;

  void _placeLoadingListener(BuildContext context, PlacesState state) {
    if(state is PlaceLoaded)
      _nextPageToken = state.nextPageToken;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bloc.add(LoadPlaces(_location, null)));
  }

  @override
  void dispose() { 
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Places')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<PlacesBloc, PlacesState>(
                cubit: _bloc,
                listener: _placeLoadingListener,
                builder: (context, state) {
                  if(state is PlacesLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  else if(state is PlaceLoadFailed) {
                    return Center(
                      child: InkWell(
                        child: Text(
                          'Places Loading Failed!!!',
                          style: TextStyle(
                            color: Colors.blueGrey
                          ),
                        ),
                      )
                    );
                  }
                  else if(state is PlaceLoaded) {
                    return _placeList(state.places);
                  }
                  else return Container();
                }
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10.0),
              child: FlatButton(
                onPressed: () => _bloc.add(LoadPlaces(_location, _nextPageToken)), 
                color: Colors.lightBlue,
                textColor: Colors.white,
                minWidth: double.infinity,
                child: Text('Next Page')
              ),
            )
          ],
        )
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