import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/orders.dart';
import '../models/cart.dart';

import '../widgets/item_cart.dart' as wdg;

class CartScreen extends StatelessWidget {
  static const routeName = '/cart-details';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Cart Items')),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FittedBox(
                    child: Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 18),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  Spacer(),
                  Chip(
                      label: Text(
                    '${cart.totalCartPrice}',
                  )),
                  OrderNowButton(cart: cart),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemsCount,
              itemBuilder: (_, i) {
                return wdg.CartItem(
                  id: cart.itemsList[i].id,
                  productId: cart.itemsMap.keys.toList()[i],
                  title: cart.itemsList[i].title,
                  price: cart.itemsList[i].price,
                  quantity: cart.itemsList[i].quantity,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OrderNowButton extends StatefulWidget {
  const OrderNowButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderNowButtonState createState() => _OrderNowButtonState();
}

class _OrderNowButtonState extends State<OrderNowButton> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    final scaffoldObj = Scaffold.of(context);
    return FlatButton(
      child: isLoading ? CircularProgressIndicator() : Text('Order Now'),
      onPressed: (widget.cart.totalCartPrice <= 0 || isLoading)
          ? null
          : () async {
              setState(() => isLoading = true);
              await Provider.of<Orders>(context, listen: false)
                  .addOrder(widget.cart.itemsList, widget.cart.totalCartPrice);
              setState(() => isLoading = false);
              scaffoldObj.showSnackBar(SnackBar(
                content: Text('order placed successfully'),
                duration: Duration(seconds: 1),
              ));
              widget.cart.clearCart();
            },
    );
  }
}
