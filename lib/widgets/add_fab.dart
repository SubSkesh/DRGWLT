import 'package:flutter/material.dart';
import 'package:drgwallet/models/enum.dart';

class AddFloatingButton extends StatelessWidget {
  final Function(TxType?) onAddPressed;

  const AddFloatingButton({
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
                title: const Text('Nuovo Acquisto'),
                onTap: () {
                  Navigator.pop(context);
                  onAddPressed(TxType.purchase);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sell),
                title: const Text('Nuova Vendita'),
                onTap: () {
                  Navigator.pop(context);
                  onAddPressed(TxType.sale);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Nuovo Wallet'),
                onTap: () {
                  Navigator.pop(context);
                  onAddPressed(null);
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