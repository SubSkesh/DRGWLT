import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/wallet.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/utils/wallet_calculator.dart';
import 'package:flutter/material.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/utils/deal_calculator.dart';
import 'package:drgwallet/theme/app_theme.dart';
import'package:drgwallet/models/enum.dart';
import 'package:drgwallet/widgets/add_fab_deal.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class  DealDetailScreen extends ConsumerStatefulWidget {
  final String walletID;
  final String dealID;
  const DealDetailScreen({super.key,required this.walletID,required this.dealID});

  @override
  ConsumerState<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends ConsumerState<DealDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
