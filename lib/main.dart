import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';

import 'helpers/custom_route.dart';
import 'models/orders.dart';
import 'models/all_products.dart';
import 'models/cart.dart';
import 'models/auth.dart';

import 'screens/auth_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/manage_products_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, AllProducts>(
          create: (_) => AllProducts('', '', []),
          update: (ctx, auth, previousItems) => AllProducts(
            auth.token,
            auth.userId,
            previousItems == null ? [] : previousItems.items,
          ),
        ),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders('', '', []),
          update: (ctx, auth, oldOrders) => Orders(
            auth.token,
            auth.userId,
            oldOrders == null ? [] : oldOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (__, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: env == 'dev',
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            accentColor: Colors.orangeAccent.shade100,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransition(),
              TargetPlatform.iOS: CustomPageTransition(),
            }
            ),
          ),
          home: auth.isAuthenticated
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.isUserLoggedIn(),
                  builder: (_, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductsOverviewScreen.routeName: (_) => ProductsOverviewScreen(),
            ProductDetailsScreen.routeName: (_) => ProductDetailsScreen(),
            CartScreen.routeName: (_) => CartScreen(),
            OrdersScreen.routeName: (_) => OrdersScreen(),
            ManageProductsScreen.routeName: (_) => ManageProductsScreen(),
            EditProductScreen.routeName: (_) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
