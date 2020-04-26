import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/all_products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = '/product-details';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final product = Provider.of<AllProducts>(context, listen: false)
        .getProductById(productId);

    Provider.of<AllProducts>(context);
    return Scaffold(
      // appBar: AppBar(title: Text(product.title)),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(product.title),
              background: Hero(
                tag: product.id,
                child: Image.network(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(height: 20),
            Text(
              '${product.price}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product.description,
                softWrap: true,
                overflow: TextOverflow.fade,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ]))
        ],
      ),
    );
  }
}
