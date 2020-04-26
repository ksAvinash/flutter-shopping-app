import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/all_products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formGKey = GlobalKey<FormState>();

  var _editedProduct = Product(
    id: DateTime.now().toString(),
    title: '',
    price: 0.0,
    description: '',
    imageUrl: '',
    isFavourite: false,
  );

  var _isInitiated = false;
  var _isNewProduct = true;
  var _isProgressLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {
        print('imageUrl: ${_imageUrlController.text}');
      });
    }
  }

  @override
  void didChangeDependencies() {
    if (!_isInitiated) {
      _isInitiated = true;

      String productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _isNewProduct = false;
        print('... editing existing product $productId');
        final product = Provider.of<AllProducts>(context, listen: false)
            .getProductById(productId);
        _editedProduct = product;
        _imageUrlController.text = _editedProduct.imageUrl;
      } else
        print('... creating new product');
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm(BuildContext context) async {
    if (_formGKey.currentState.validate()) {
      _formGKey.currentState.save();
      print(_editedProduct.objectMap);

      setState(() => _isProgressLoading = true);

      try {
        if (_isNewProduct) {
          print('-->> item not exists, creating item');
          await Provider.of<AllProducts>(context, listen: false)
              .addProduct(_editedProduct);
        } else {
          print('-->> item already exists, updating item');
          await Provider.of<AllProducts>(context, listen: false)
              .updateProduct(_editedProduct);
        }
      } catch (err) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(err.toString()),
            elevation: 8,
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ok'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isProgressLoading = false;
          Navigator.of(context).pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveForm(context),
          )
        ],
      ),
      body: _isProgressLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formGKey,
                autovalidate: true,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Title',
                        ),
                        initialValue: _editedProduct.title,
                        validator: (val) {
                          if (val.isEmpty) return 'empty title';
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          _priceFocusNode.requestFocus();
                        },
                        onSaved: (val) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: val,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Price',
                        ),
                        initialValue: '${_editedProduct.price}',
                        validator: (val) {
                          if (val.isEmpty) return 'empty price';
                          if (double.tryParse(val) == null)
                            return 'invalid price';
                          if (double.parse(val) <= 0)
                            return 'positive price needed';
                          return null;
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          _descriptionFocusNode.requestFocus();
                        },
                        onSaved: (val) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            price: double.parse(val),
                            description: _editedProduct.description,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Description',
                        ),
                        initialValue: _editedProduct.description,
                        validator: (val) {
                          if (val.isEmpty) return 'empty description';
                          if (val.length < 10) return 'description too short';
                          return null;
                        },
                        maxLines: 4,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        onSaved: (val) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: val,
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 120,
                            height: 120,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.teal),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('url not added')
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Image url',
                              ),
                              validator: (val) {
                                if (val.isEmpty) return 'empty url';
                                if (!val.startsWith('https:') &&
                                    !val.startsWith('http:'))
                                  return 'invalid url';
                                return null;
                              },
                              textInputAction: TextInputAction.go,
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) => _saveForm(context),
                              onSaved: (val) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  price: _editedProduct.price,
                                  description: _editedProduct.description,
                                  imageUrl: val,
                                  isFavourite: _editedProduct.isFavourite,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
