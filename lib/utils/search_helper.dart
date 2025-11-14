class BackendHelper {
  // Local backend for Windows desktop
  static const String baseUrl = 'http://localhost:4000'; // replace port if different

  static String getProductsUrl(String query) {
    // Encode query to handle spaces, special characters, etc.
    final encodedQuery = Uri.encodeQueryComponent(query);
    return '$baseUrl/api/products/search?query=$encodedQuery';
  }
}
