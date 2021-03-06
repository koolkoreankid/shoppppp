import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(this.id, this.productId, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(Icons.delete, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 10),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        // popup before the action with yes or no 
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("sure?"),
                  content: Text("remove"),
                  actions: <Widget>[
                    FlatButton(child: Text("no"), onPressed: () {
                      Navigator.of(context).pop(false);
                    },),
                    FlatButton(child: Text("yes"), onPressed: () {
                      Navigator.of(context).pop(true);
                    },),
                  ],
                ));
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                "\$$price",
                style: TextStyle(fontSize: 13),
              ),
            ),
            title: Text(title),
            subtitle: Text("\$${(price * quantity)}"),
            trailing: Text("$quantity"),
          ),
        ),
      ),
    );
  }
}
