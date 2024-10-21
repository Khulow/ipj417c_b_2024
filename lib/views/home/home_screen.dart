import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/common_widgets/searchbar_widget.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/viewmodels/listing_view_model.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  List<Listing> searchResults = [];
  final List<String> categories = [
    'All',
    'Sharing',
    'Girls only',
    'Boys only',
    'Commune',
    'Single'
  ];

  @override
  void initState() {
    super.initState();
    // Fetch listings when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingViewModel>(context, listen: false).fetchListings();
    });
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
                SearchWidget(
                  onSearchResults: (results) {
                    setState(() {
                      searchResults = results;
                    });
                  },
                  categories: [
                    'Sharing',
                    'Girls only',
                    'Boys only',
                    'Commune',
                    'Single'
                  ],
                ),
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
              padding: const EdgeInsets.only(right: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selectedCategory == categories[index]
                          ? Colors.blueAccent
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.home,
                      size: 32,
                      color: selectedCategory == categories[index]
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: selectedCategory == categories[index]
                          ? Colors.blueAccent
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

        final displayListings =
            searchResults.isNotEmpty ? searchResults : viewModel.listings;
        final filteredListings = selectedCategory == 'All'
            ? displayListings
            : displayListings
                .where((listing) => listing.category == selectedCategory)
                .toList();

        if (filteredListings.isEmpty) {
          return const Center(child: Text('No listings available.'));
        }

        return Column(
          children: filteredListings
              .take(5)
              .map((listing) => Column(
                    children: [
                      _buildListingItem(listing),
                      const SizedBox(height: 24),
                    ],
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildListingItem(Listing listing) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  listing.images.isNotEmpty ? listing.images.first : '',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image, size: 48)),
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'R${listing.price.toStringAsFixed(2)}/pm',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    listing.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: listing.isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    Provider.of<UserViewModel>(context, listen: false)
                        .toggleFavorite(listing.id);
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  listing.address,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      listing.averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        _showReviewBottomSheet(context, listing);
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.rate_review,
                              size: 18, color: Colors.blueAccent),
                          SizedBox(width: 4),
                          Text('Reviews',
                              style: TextStyle(color: Colors.blueAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewBottomSheet(BuildContext context, Listing listing) {
    final reviewController = TextEditingController();
    double reviewRating = 3.0; // Default rating value

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add a Review',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                decoration:
                    const InputDecoration(hintText: 'Enter your review'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Rating: ${reviewRating.toStringAsFixed(1)}'),
              Slider(
                value: reviewRating,
                min: 1.0,
                max: 5.0,
                divisions: 4,
                label: reviewRating.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    reviewRating = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      const userId =
                          "userId_placeholder"; // Replace with actual user ID
                      Provider.of<ListingViewModel>(context, listen: false)
                          .addReview(
                        listing.id,
                        reviewController.text,
                        reviewRating,
                        userId,
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
