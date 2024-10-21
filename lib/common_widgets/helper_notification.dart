/// Helper method to generate notification messages based on status
String _generateMessage(String status, String listingId) {
  switch (status) {
    case 'resubmitted':
      return 'Your listing $listingId has been resubmitted and is now pending review.';
    case 'approved':
      return 'Congratulations! Your listing $listingId has been approved.';
    case 'rejected':
      return 'We are sorry to inform you that your listing $listingId has been rejected.';
    default:
      return 'You have a new notification regarding listing $listingId.';
  }
}
