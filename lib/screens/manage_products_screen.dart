import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/item_manage_products.dart';
import '../models/all_products.dart';
import '../widgets/app_drawer.dart';
import 'edit_product_screen.dart';

class ManageProductsScreen extends StatelessWidget {
  static const routeName = '/manage-products';

  Future<void> refreshProducts(BuildContext context) async {
    await Provider.of<AllProducts>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: Provider.of<AllProducts>(context, listen: false)
              .fetchAndSetProducts(true),
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            else if (dataSnapShot.error != null)
              return Center(child: Text('something went wrong'));
            return RefreshIndicator(
              onRefresh: () => refreshProducts(context),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Consumer<AllProducts>(
                  builder: (__, allproducts, _) => ListView.builder(
                    itemCount: allproducts.items.length,
                    itemBuilder: (_, i) {
                      return Column(
                        children: <Widget>[
                          ManageProductsItem(
                            allproducts.items[i].id,
                            allproducts.items[i].title,
                            allproducts.items[i].imageUrl,
                          ),
                          Divider(color: Colors.black45),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          }),
    );
  }
}
