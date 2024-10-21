import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/models/listings.dart';
import 'package:ipj417c_b_2024/views/listing_view_detail.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:provider/provider.dart';

class ListingUserCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onEdit;

  const ListingUserCard({
    super.key,
    required this.listing,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    String status = listing.status;
    bool isPending = status == 'pending';

    return Dismissible(
      key: Key(listing.id),
      background: _buildEditBackground(),
      secondaryBackground: _buildDeleteBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return await _showDeleteDialog(context);
        }
        return false;
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await _deleteListing(context);
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 4,
        child: ListTile(
          contentPadding: const EdgeInsets.all(8),
          title: Text(
            listing.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${listing.price} - ${listing.address}'),
              const SizedBox(height: 4),
              Text(
                'Status: $status',
                style: TextStyle(
                  color: isPending ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          leading: listing.images.isNotEmpty
              ? Image.network(
                  listing.images[0],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.home, size: 50),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListingDetailScreen(listing: listing),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditBackground() {
    return Container(
      color: Colors.blue,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Listing"),
          content: const Text("Are you sure you want to delete this listing?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteListing(BuildContext context) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    try {
      await userViewModel.removeListingFromUser(listing.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${listing.title} deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete ${listing.title}: $e')),
      );
    }
  }
}
