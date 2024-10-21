import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:url_launcher/url_launcher.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: PhotoGallery(images: listing.images),
            ),
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'R${listing.price.toStringAsFixed(2)}/pm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 16),
                  _buildSection(context, 'Description', listing.description),
                  _buildSection(context, 'Address', listing.address),
                  _buildSection(context, 'Category', listing.category),
                  _buildSection(context, 'Room Type', listing.roomType),
                  _buildSection(context, 'Distance to Campus',
                      '${listing.distanceToCampus} km'),
                  _buildSection(
                      context, 'Lease Duration', listing.leaseDuration),
                  _buildSection(context, 'Deposit Amount',
                      'R${listing.depositAmount.toStringAsFixed(2)}'),
                  _buildSection(context, 'Utilities Included',
                      listing.utilitiesIncluded ? 'Yes' : 'No'),
                  _buildSection(context, 'Furnishing', listing.furnishing),
                  _buildSection(context, 'Number of Bedrooms',
                      listing.numberOfBedrooms.toString()),
                  _buildSection(context, 'Number of Bathrooms',
                      listing.numberOfBathrooms.toString()),
                  _buildSection(context, 'Public Transport Access',
                      listing.publicTransportAccess),
                  _buildChipSection(context, 'Amenities', listing.amenities),
                  _buildChipSection(
                      context, 'Nearby Facilities', listing.nearbyFacilities),
                  _buildChipSection(context, 'Nearby Campus Amenities',
                      listing.nearbyCampusAmenities),
                  _buildChipSection(
                      context, 'Security Features', listing.securityFeatures),
                  _buildChipSection(context, 'Rules', listing.rules),
                  _buildReviewsSection(context, listing.reviews),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showContactInfo(context),
                    child: Text('Contact Information'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Location:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: MapPlaceholder(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title + ':',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(content),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChipSection(
      BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title + ':',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Wrap(
          spacing: 8,
          children: items.map((item) => Chip(label: Text(item))).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReviewsSection(
      BuildContext context, List<Map<String, dynamic>> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        ...reviews.map((review) => ListTile(
              title: Text(review['user'] ?? 'Anonymous'),
              subtitle: Text(review['comment'] ?? ''),
              trailing: Text('${review['rating'] ?? 0}/5'),
            )),
        SizedBox(height: 16),
      ],
    );
  }

  void _showContactInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Owner ID'),
                subtitle: Text(listing.ownerId),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Contact Number'),
                subtitle: Text(listing.contactNumber),
                onTap: () => _launchUrl('tel:${listing.contactNumber}'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}

class PhotoGallery extends StatelessWidget {
  final List<String> images;

  const PhotoGallery({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        enableInfiniteScroll: false,
      ),
      items: images.map((image) {
        return Builder(
          builder: (BuildContext context) {
            return Image.network(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
        );
      }).toList(),
    );
  }
}

class MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.map,
          size: 50,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
