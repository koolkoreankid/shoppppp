import 'package:flutter/material.dart';
import 'package:shop/screens/orders_screen.dart';
import 'package:shop/screens/user_product_screen.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text("hey"),
            automaticallyImplyLeading: false, // will never add back button
          ),
          Divider(), // horizontal line
          ListTile(
              leading: Icon(Icons.shop),
              title: Text("shop"),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              }),
          Divider(), // horizontal line
          ListTile(
              leading: Icon(Icons.payment),
              title: Text("payment"),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(OrderScreen.routeName);
              }),
          Divider(), // horizontal line
          ListTile(
              leading: Icon(Icons.view_agenda),
              title: Text("user product"),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserProductScreen.routeName);
              }),
          Divider(), // horizontal line
          ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Log out"),
              onTap: () {
                Navigator.of(context).pop();
                // makes it come back to the homeroute when logging out 
                Navigator.of(context).pushReplacementNamed('/');
                // Navigator.of(context)
                //     .pushReplacementNamed(UserProductScreen.routeName);
                Provider.of<Auth>(context, listen: false).logout();
              })
        ],
      ),
    );
  }
}
