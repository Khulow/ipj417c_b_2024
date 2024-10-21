import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/viewmodels/listing_view_model.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final List<String> categories;

  const SearchScreen({
    super.key,
    required this.categories,
  });

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 10000); // Adjust max as needed
  bool _filtersApplied = false;
  List<Listing> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'All';
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _priceRange = const RangeValues(0, 10000);
      _filtersApplied = false;
    });
    _performSearch();
  }

  void _performSearch() async {
    final query = _searchController.text;
    final listingViewModel =
        Provider.of<ListingViewModel>(context, listen: false);

    final results = await listingViewModel.searchListings(
      query: query,
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
    );
    setState(() {
      _searchResults = results;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        categories: ['All', ...widget.categories],
        selectedCategory: _selectedCategory!,
        priceRange: _priceRange,
        onCategoryChanged: (category) {
          setState(() => _selectedCategory = category);
        },
        onPriceRangeChanged: (range) {
          setState(() => _priceRange = range);
        },
        onApply: () {
          Navigator.pop(context);
          setState(() {
            _filtersApplied = _selectedCategory != 'All' ||
                _priceRange != const RangeValues(0, 10000);
          });
          _performSearch();
        },
        onClear: () {
          Navigator.pop(context);
          _resetFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _performSearch();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Where are you going?',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                FilterButton(
                  onTap: _showFilterBottomSheet,
                  filtersApplied: _filtersApplied,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final listing = _searchResults[index];
                return ListTile(
                  title: Text(listing.title),
                  subtitle: Text(listing.description),
                  trailing: Text('R${listing.price.toStringAsFixed(2)}/pm'),
                  // Add more details or onTap functionality as needed
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool filtersApplied;

  const FilterButton({
    Key? key,
    required this.onTap,
    required this.filtersApplied,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
          color: filtersApplied ? Colors.black : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 18,
              color: filtersApplied ? Colors.white : Colors.black,
            ),
            if (filtersApplied) ...[
              const SizedBox(width: 4),
              const Text(
                'Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final List<String> categories;
  final String selectedCategory;
  final RangeValues priceRange;
  final Function(String) onCategoryChanged;
  final Function(RangeValues) onPriceRangeChanged;
  final VoidCallback onApply;
  final Function() onClear;

  const FilterBottomSheet({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.priceRange,
    required this.onCategoryChanged,
    required this.onPriceRangeChanged,
    required this.onApply,
    required this.onClear,
  });

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _category;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _priceRange = widget.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: widget.onClear,
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: widget.categories.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: _category == category,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _category = category);
                    widget.onCategoryChanged(category);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Price Range',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 10000,
            divisions: 100,
            labels: RangeLabels(
              'R${_priceRange.start.round()}',
              'R${_priceRange.end.round()}',
            ),
            onChanged: (RangeValues values) {
              setState(() => _priceRange = values);
              widget.onPriceRangeChanged(values);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onApply,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
