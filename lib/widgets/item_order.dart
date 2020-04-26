import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../models/orders.dart' as obj;

class OrderItem extends StatefulWidget {
  final obj.OrderItem order;
  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _isExpanded
            ? min(widget.order.products.length * 20.0 + 150, 220)
            : 80,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.order.price}'),
              subtitle: Text(DateFormat.yMMMEd().format(widget.order.dateTime)),
              trailing: IconButton(
                icon: Icon(Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _isExpanded
                  ? min(widget.order.products.length * 20.0 + 50, 180)
                  : 0,
              child: ListView.builder(
                itemCount: widget.order.products.length,
                itemBuilder: (_, i) {
                  return Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 8),
                        child: Text(widget.order.products[i].title),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, top: 8),
                        child: Text(
                            'quantity: ${widget.order.products[i].quantity}'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
