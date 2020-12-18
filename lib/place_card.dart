import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class PlaceCard extends StatelessWidget {
  
  final Map<String, dynamic> place;

  final _point = Geoflutterfire().point(latitude: -27.467237358115597, longitude: 153.0305656806858);
  
  PlaceCard(this.place, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      width: 210.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CachedNetworkImage(
                  imageUrl: place['image'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  width: 200.0,
                  height: 125.0,
                  fit: BoxFit.cover,
                )
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Text(
                    _point.distance(
                      lat: (place['location']['geopoint'] as GeoPoint).latitude, 
                      lng: (place['location']['geopoint'] as GeoPoint).longitude
                    ).toStringAsFixed(1) + 'Km'
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            place['name'],
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3.0),
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.black,
              ),
              const SizedBox(height: 5.0),
              Text(
                place['rating'].toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      )
    );
  }
}