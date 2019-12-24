import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // have to move to next node manually, foucs node is to indicate
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>(); // key
  var _editedProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');

  @override
  void initState() {
    // whenever the focus changes, it runs the function _updateImageUrl
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  var _isLoading = false;
  var _isInit = true;
  var _initValues = {
    "title": '',
    "description": '',
    "price": '',
    "imageUrl": '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // cover the entire Navigator
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          // "imageUrl": _editedProduct.imageUrl,
          "imageUrl": '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    // so whenever it loses focus, it updates by saying setstate
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  // focusnode leaves memory leaks so have to reset:
  @override
  void dispose() {
    _imageUrlController.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    // check if its valid, if not, just return null and dont run
    if (!isValid) {
      return;
      // if not valid, dont save
    }
    _form.currentState.save(); // save form globally and now can use freely
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("Error"),
                  content: Text("something is wrong"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // close the overlay
                      },
                    )
                  ],
                ));
      } 
    //   finally {
    //     // 'finally' runs no matter
    //     setState(() {
    //       _isLoading = true;
    //     });
    //     // since 'then' can only be used if its future!
    //     Navigator.of(context).pop(); // goes to previous page
    //   }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("edit"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),

      // for long scrolls so it doesnt remove
      // Form(
      //     child: SingleChildScrollView(
      //         child: Column(
      //             children: [ ... ],
      //         ),
      //     ),
      // ),
      // load if not yet done, otherwise tdo
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _form, // can now interact with
                // Form will help saving/retrieving data for input/output
                child: ListView(children: <Widget>[
                  TextFormField(
                    initialValue: _initValues['title'],
                    decoration: InputDecoration(labelText: "Title"),
                    textInputAction: TextInputAction.next,
                    //move focus after type
                    validator: (value) {
                      if (value.isEmpty) {
                        return "value missing";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                          title: value,
                          price: _editedProduct.price,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite);
                    },
                  ),
                  Divider(),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration: InputDecoration(labelText: "Price"),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Enter something";
                      }
                      if (double.tryParse(value) == null) {
                        return "not valid";
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                          title: _editedProduct.title,
                          price: double.parse(value),
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite);
                    },
                  ),
                  Divider(),
                  TextFormField(
                    initialValue: _initValues['description'],
                    decoration: InputDecoration(labelText: "Description"),
                    maxLines: 3,
                    focusNode: _descriptionFocusNode,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "write something";
                      }
                      if (value.length < 10) {
                        return "at least 10 characters";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite);
                    },
                  ),
                  Divider(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(top: 8, right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                        ),
                        //image
                        child: _imageUrlController.text.isEmpty
                            ? Text("Enter Url")
                            : FittedBox(
                                child: Image.network(_imageUrlController.text),
                                fit: BoxFit.cover,
                              ),
                      ),
                      Expanded(
                        child: TextFormField(
                          // cant use controller and initValue at the same time
                          // initialValue: _initValues['imageUrl'],
                          decoration: InputDecoration(labelText: "imageUrl"),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "write soemthing";
                            }
                            if (!value.startsWith("http") &&
                                !value.startsWith('https')) {
                              return "not valid";
                            }
                            //regular expression:
                            // var urlPattern =
                            //     r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
                            // var result = new RegExp(urlPattern, caseSensitive: false)
                            //     .firstMatch('https://www.google.com');
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite);
                          },
                        ),
                      )
                    ],
                  )
                ]),
              ),
            ),
    );
  }
}
