import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/views/home/search_screen.dart';

class SearchWidget extends StatelessWidget {
  final List<String> categories;

  const SearchWidget({
    Key? key,
    required this.categories,
    required Null Function(dynamic results) onSearchResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchScreen(categories: categories),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            const Text('Search accomodations',
                style: TextStyle(color: Colors.grey)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
