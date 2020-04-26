import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../models/orders.dart';
import '../widgets/item_order.dart' as wdg;

class OrdersScreen extends StatelessWidget {
  static const routeName = '/order-details';

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Orders')),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {
            if (dataSnapshot.error != null) {
              return Center(child: Text('something went wrong'));
            }
            return Consumer<Orders>(
              builder: (c, orderData, child) {
                return ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (_, i) {
                    return wdg.OrderItem(orderData.orders[i]);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
