import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

import './product.dart';

//merge inheritance
class Products with ChangeNotifier {
  // mixing (with), utility, building connection
  // List but the type is Product from product.dart
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://scontent-icn1-1.xx.fbcdn.net/v/t31.0-8/10380167_1616897021874744_3848436711027605674_o.jpg?_nc_cat=102&_nc_ohc=xyZKXSEvWQUAQkY8pzShK3CTRmITjGjBThlAq3OWW-Nc42jsLW_nVJfFA&_nc_ht=scontent-icn1-1.xx&oh=ceed91ff634544bedf3e13c8db30e125&oe=5E86D51A',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoriteOnly = false;

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoriteOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items]; // return copy of it, not using direct address
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  // good to create method in provider
  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoriteOnly() {
  //   _showFavoriteOnly = true;
  //   notifyListeners(); // so that it updates
  // }
  // void showAll() {
  //   _showFavoriteOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetAndSetProducts([bool filterByUser = false]) async {
      // [bool filterByUser = false] - makes it optional
      // run time constant - final
      // compile time constant - const
      final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = 'https://flutter-tut-fc384.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      // 'dynnamic' is another map
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      url ='https://flutter-tut-fc384.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteReponse = await http.get(url);
      final favoriteData = json.decode(favoriteReponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl']));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      Future.error(error);
    }
  }

  Future<void> addProduct(Product product) async {
    // async wraps with futurem await waits until finish
    // get = fetch
    // post = store data
    // patch = update data, put = replace data
    // Delete = delete
    // must convert into json file beforehand
    // 'future' allow us to execute method once certain action is done
    final url = 'https://flutter-tut-fc384.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      // invisibly covered in 'then' bloack by async
      // asynchronous code : run seperately from primary application
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // 'future' runs first, and 'then' runs whenever future finishes
  // meanwhile, other functions also run asynchronously
  // useful for you dont have to wait for one function for others
  // void main() {
  //   var myFuture = Future(() {
  //     return "hello";
  //   });
  //   print("this runs first");
  //   myFuture.then((result) => print(result)).catchError((error) {
  //       "do something when error is catched"
  //   })
  // ;
  //   print("after");
  // }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);

    if (prodIndex >= 0) {
      final url = 'https://flutter-tut-fc384.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://flutter-tut-fc384.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);

    // notify thus update after the change
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete');
    }
    existingProduct = null;

    // re-add fail if failed
  }
}
