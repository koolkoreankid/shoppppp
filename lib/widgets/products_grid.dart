import 'package:flutter/material.dart';
import '../providers/products.dart';
import './product_item.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData =
        Provider.of<Products>(context); // only this part rebuilt
    final products = showFavs ? productsData.favoriteItems: productsData.items;

    return GridView.builder(
      // 3 required argument, itembuilder is what you see
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(

        value : products[i],
        child: ProductItem(
            // // give this data to the productitem file so it renders widgets
            // products[i].id,
            // products[i].title,
            // products[i].imageUrl
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // number of columns
          childAspectRatio: 3 / 2, //
          crossAxisSpacing: 10, // space between columns
          mainAxisSpacing: 10 // space between rows
          ),
    );
  }
}
