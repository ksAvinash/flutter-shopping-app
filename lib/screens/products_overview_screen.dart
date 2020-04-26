import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/cart_screen.dart';

import '../models/cart.dart';
import '../models/all_products.dart';

import '../widgets/badge.dart';
import '../widgets/item_product.dart';
import '../widgets/app_drawer.dart';

enum FilterOptions {
  FavouritesOnly,
  AllProducts,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/products-overview';
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavouritesOnly = false;
  var _isLoading = false;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Provider.of<AllProducts>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ShoppingApp'),
        actions: <Widget>[
          Consumer<Cart>(
            builder: (context, cart, child) {
              return Badge(
                child: IconButton(
                  icon: child,
                  onPressed: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                ),
                value: '${cart.itemsCount}',
              );
            },
            child: Icon(Icons.shopping_cart),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOptions val) {
              if (val == FilterOptions.AllProducts) {
                setState(() => _showFavouritesOnly = false);
              } else if (val == FilterOptions.FavouritesOnly) {
                setState(() => _showFavouritesOnly = true);
              } else {
                setState(() => _showFavouritesOnly = true);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Favourites Only'),
                  value: FilterOptions.FavouritesOnly),
              PopupMenuItem(
                  child: Text('All Products'),
                  value: FilterOptions.AllProducts),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showFavouritesOnly),
    );
  }
}

class ProductsGrid extends StatelessWidget {
  final bool showFavouritesOnly;
  ProductsGrid(this.showFavouritesOnly);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<AllProducts>(context);

    final products = showFavouritesOnly
        ? productData.favouritesOnlyItems
        : productData.items;

    return GridView.builder(
      padding: EdgeInsets.all(15),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.25,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, i) {
        return ChangeNotifierProvider.value(
          value: products[i],
          child: ProductItem(
              // products[i].id,
              // products[i].title,
              // products[i].imageUrl,
              ),
        );
      },
      itemCount: products.length,
    );
  }
}
