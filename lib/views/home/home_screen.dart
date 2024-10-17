import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/viewmodels/listing_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch listings when the screen is initialized
    Provider.of<ListingViewModel>(context, listen: false).fetchListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 24),
                _buildCategories(),
                const SizedBox(height: 24),
                _buildFeaturedListings(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Where to?',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Anywhere • Any week • Add guests',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.tune, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      'All',
      'Sharing',
      'Girls only',
      'Boys only',
      'Commune',
      'Single',
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = categories[index];
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 38),
              child: Column(
                children: [
                  Icon(
                    Icons.home,
                    size: 32,
                    color: selectedCategory == categories[index]
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedCategory == categories[index]
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedListings(BuildContext context) {
    return Consumer<ListingViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(child: Text('Error: ${viewModel.error}'));
        }

        final filteredListings = selectedCategory == 'All'
            ? viewModel.listings
            : viewModel.getListingsByCategory(selectedCategory);

        if (filteredListings.isEmpty) {
          return const Center(child: Text('No listings available.'));
        }

        return Column(
          children: filteredListings
              .take(5)
              .map((listing) => Column(
                    children: [
                      _buildListingItem(
                        listing.address,
                        listing.title,
                        listing.averageRating,
                        listing.images.isNotEmpty
                            ? listing.images.first
                            : 'https://via.placeholder.com/300x200',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildListingItem(
      String location, String title, double rating, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.error)),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(location, style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 4),
                Text(rating.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
