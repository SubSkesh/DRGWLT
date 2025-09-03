import 'package:flutter/material.dart';
import 'package:drgwallet/models/enum.dart';

class AddDealFloatingButton extends StatelessWidget {
  final Function(TxType?) onAddPressed;

  const AddDealFloatingButton({
    super.key,
    required this.onAddPressed,
  });

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: const Text('New purchase'),
                onTap: () {
                  Navigator.pop(context);
                  onAddPressed(TxType.purchase);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sell),
                title: const Text('New Sale'),
                onTap: () {
                  Navigator.pop(context);
                  onAddPressed(TxType.sale);
                },
              ),

            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddMenu(context),
      child: const Icon(Icons.add),
    );
  }
}