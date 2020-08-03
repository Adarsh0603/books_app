import 'dart:convert';
import 'dart:math';
import 'package:books_app/models/book.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class NYT with ChangeNotifier {
  List<String> _categories = [];
  List<Book> _bestSellers = [];
  String _selectedCategory = '';

  List<Book> get getShowcaseBooks {
    return [..._bestSellers];
  }

  String get getSelectedCategory {
    return _selectedCategory;
  }

  Future<void> getCategoryList() async {
    print('[getCategoryList()]');
    final url =
        'https://api.nytimes.com/svc/books/v3/lists/names.json?api-key=0Db7fWAZAY6kK0Gz3NwcVQiMKf1MUnH9';
    try {
      http.Response response = await http.get(url);
      var jsonResponse = await jsonDecode(response.body);
      List categoriesJsonList = jsonResponse['results'];

      List<String> categories = [];
      categoriesJsonList.forEach((category) {
        categories.add(category['list_name_encoded'].toString());
      });
      _categories = categories;
      int randomIndex = Random().nextInt(_categories.length);
      String bestSellerRandomCategory = _categories[randomIndex];
      await getBestsellers(bestSellerRandomCategory);
    } catch (e) {
      print(e);
    }
  }

  Future<void> getBestsellers(String category) async {
    final url =
        'https://api.nytimes.com/svc/books/v3/lists/current/$category.json?api-key=0Db7fWAZAY6kK0Gz3NwcVQiMKf1MUnH9';
    http.Response response = await http.get(url);
    var jsonResponse = await jsonDecode(response.body)['results'];
    List bestsellersJson = jsonResponse['books'];
    List<Book> bestsellers = [];
    bestsellersJson.forEach((book) {
      bestsellers.add(
        Book(
            isbn: book['primary_isbn13'],
            rank: book['rank'],
            title: book['title'],
            singleAuthor: book['author'],
            thumbnailUrl: book['book_image'],
            buyLink: book['amazon_product_url'],
            description: book['description'],
            publisher: book['publisher']),
      );
    });
    _bestSellers = bestsellers;
    _selectedCategory = jsonResponse['display_name'];
    notifyListeners();
  }

  Book getShowcaseBook(int rank) {
    return _bestSellers.firstWhere((book) => (book.rank == rank));
  }
}
