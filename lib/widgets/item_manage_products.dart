import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../models/all_products.dart';

class ManageProductsItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  ManageProductsItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffObj = Scaffold.of(context);
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: Container(
        width: 120,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.edit,
              ),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).errorColor,
              ),
              onPressed: () async {
                try {
                  await Provider.of<AllProducts>(context, listen: false)
                      .deleteProductById(id);
                } catch (err) {
                  scaffObj.showSnackBar(SnackBar(
                    content: Text(err.toString(),
                        style: TextStyle(color: Colors.white)),
                    duration: Duration(seconds: 1),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
