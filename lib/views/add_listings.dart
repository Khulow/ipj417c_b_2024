import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ipj417c_b_2024/services/Listings_repository.dart';
import 'package:ipj417c_b_2024/viewmodels/add_listing_viewmodel.dart';
import 'package:provider/provider.dart';

class AddListingView extends StatelessWidget {
  const AddListingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddListingViewModel(ListingRepository()),
      child: _AddListingForm(),
    );
  }
}

class _AddListingForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddListingViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Listing')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: viewModel.currentStep,
        onStepContinue: viewModel.canProceed() ? viewModel.goToNextStep : null,
        onStepCancel:
            viewModel.currentStep > 0 ? viewModel.goToPreviousStep : null,
        steps: [
          Step(
            title: const Text('Basic Information'),
            content: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: viewModel.setTitle,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: viewModel.setDescription,
                  maxLines: 3,
                ),
              ],
            ),
            isActive: viewModel.currentStep >= 0,
          ),
          Step(
            title: const Text('Location and Price'),
            content: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      viewModel.setPrice(double.tryParse(value) ?? 0),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Address'),
                  onChanged: viewModel.setAddress,
                ),
                TextField(
                  decoration: const InputDecoration(
                      labelText: 'Distance from Campus (km)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => viewModel
                      .setDistanceFromCampus(double.tryParse(value) ?? 0),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Neighborhood'),
                  onChanged: viewModel.setNeighborhood,
                ),
                CheckboxListTile(
                  title: const Text('Bursary Eligible'),
                  value: viewModel.isBursaryEligible,
                  onChanged: (value) =>
                      viewModel.setIsBursaryEligible(value ?? false),
                ),
              ],
            ),
            isActive: viewModel.currentStep >= 1,
          ),
          Step(
            title: const Text('Images'),
            content: Column(
              children: [
                ElevatedButton(
                  child: const Text('Add Images'),
                  onPressed: () async {
                    final ImagePicker _picker = ImagePicker();
                    final List<XFile>? images = await _picker.pickMultiImage();
                    if (images != null) {
                      viewModel.setImages(images);
                    }
                  },
                ),
                Text('${viewModel.images.length} images selected'),
              ],
            ),
            isActive: viewModel.currentStep >= 2,
          ),
          Step(
            title: const Text('Amenities and Rules'),
            content: Column(
              children: [
                // Add UI for amenities and rules
                // This could be a list of checkboxes for common amenities
                // and a text field for custom rules
                CheckboxListTile(
                  title: const Text('Wi-Fi'),
                  value: viewModel.hasWifi,
                  onChanged: (value) => viewModel.setHasWifi(value ?? false),
                ),
              ],
            ),
            isActive: viewModel.currentStep >= 3,
          ),
          Step(
            title: const Text('Safety Features'),
            content: Column(
              children: [
                // Add UI for safety features
                // This could be a list of checkboxes for common safety features
                CheckboxListTile(
                  title: const Text('Smoke Detector'),
                  value: viewModel.hasSmokeDetector,
                  onChanged: (value) =>
                      viewModel.setHasSmokeDetector(value ?? false),
                ),
              ],
            ),
            isActive: viewModel.currentStep >= 4,
          ),
        ],
      ),
      floatingActionButton: viewModel.currentStep == 4
          ? FloatingActionButton(
              child: const Icon(Icons.check),
              onPressed: viewModel.submitListing,
            )
          : null,
    );
  }
}
