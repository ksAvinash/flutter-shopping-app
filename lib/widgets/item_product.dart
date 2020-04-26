import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scaffoldObj = Scaffold.of(context);
    final product = Provider.of<Product>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailsScreen.routeName,
                arguments: product.id);
          },
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.fade,
          ),
          leading: Consumer<Product>(
            builder: (context, product, child) {
              return IconButton(
                icon: product.isFavourite
                    ? Icon(Icons.bookmark)
                    : Icon(Icons.bookmark_border),
                onPressed: () async {
                  try {
                    await product.toggleFavourite(auth.token, auth.userId);
                  } catch (err) {
                    scaffoldObj.showSnackBar(SnackBar(
                      content: Text(err.toString()),
                      duration: Duration(seconds: 1),
                    ));
                  }
                },
                color: Theme.of(context).accentColor,
              );
            },
          ),
          trailing: Consumer<Cart>(builder: (context, cart, child) {
            return IconButton(
              icon: cart.isItemInCart(product.id)
                  ? Icon(Icons.shopping_cart)
                  : Icon(Icons.add_shopping_cart),
              onPressed: () {
                cart.addToCart(product.id, product.title, product.price);
                Scaffold.of(context).removeCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added to cart',
                      style: TextStyle(color: Colors.black),
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        cart.removeSingleQuantityFromCartItem(product.id);
                      },
                      textColor: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              },
              color: Theme.of(context).accentColor,
            );
          }),
        ),
      ),
    );
  }
}
