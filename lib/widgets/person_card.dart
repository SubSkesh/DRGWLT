import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/models/wallet.dart';import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/widgets/custom_bottom_nav.dart';
import 'package:drgwallet/widgets/deal_list_item.dart';
import 'package:drgwallet/widgets/wallet_card.dart';
import 'package:drgwallet/widgets/add_fab.dart';
import 'package:drgwallet/theme/app_theme.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/services/person_service.dart';
import 'package:drgwallet/widgets/radial_action.dart';
import 'package:drgwallet/widgets/radial_context_menu.dart';
import 'package:drgwallet/widgets/drag_context_menu.dart' as drag_context_menu;
import 'dart:math';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:drgwallet/widgets/alarm_delete_wallet.dart';
class personCard extends StatelessWidget {
  final Person person;

  const personCard({
    super.key,
    required this.person,

  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: person.personType == PersonType.supplier
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.secondary.withOpacity(0.2),
          child: Icon(
            //if (person.photoUrl != null)

            person.personType == PersonType.supplier
                ? Icons.inventory
                : Icons.shopping_cart,
            color: person.personType == PersonType.supplier
                ? theme.colorScheme.primary
                : theme.colorScheme.primary,
          ),
        ),
        title: Text(person.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              person.type,
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Deals: ${person.dealIds.length}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Text(
          'prova', //_formatDate(person.createdAt),
          style: theme.textTheme.bodySmall,
        ),
        // onTap: () => _showPersonDetails(context, person),
        // onLongPressStart: (details) => _showPersonContextMenu(
        //   context,
        //   details.globalPosition,
        //   person,
        // ),
      ),
    );
  }
}