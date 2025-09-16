import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/router.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/theme/app_theme.dart';

@RoutePage()
class AddDealScreen extends StatefulWidget {
  final TxType dealType;
  final VoidCallback? onDealCreated;
  final String? preSelectedWalletId; // ← Aggiungi questo.preSelectedWalletId // ← Aggiungi questo


  const AddDealScreen({super.key, required this.dealType, this.onDealCreated,this.preSelectedWalletId});

  @override
  State<AddDealScreen> createState() => _AddDealScreenState();
}

class _AddDealScreenState extends State<AddDealScreen> {
  final DealService _dealService = DealService();
  final WalletService _walletService = WalletService();
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalPriceController = TextEditingController();

  String? _selectedWalletId;
  String? _selectedGoodId;
  String? _selectedPersonId;
  Unit _selectedUnit = Unit.gram;
  Unit _selectedPriceUnit = Unit.gram;
  Value _selectedCurrency = Value.euro;
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> _wallets = [];
  List<Map<String, dynamic>> _goods = [];
  List<Map<String, dynamic>> _persons = [];

  bool isPendin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();//dispose dei focusnode per i form
    _priceController.dispose();
    _totalPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser!;
    final wallets = await _walletService.getUserWallets().first;

    setState(() {
      _wallets = wallets.map((wallet) => {
        'id': wallet.id,
        'name': wallet.name
      }).toList();

      // Cerca il wallet pre-selezionato
      if (widget.preSelectedWalletId != null) {
        try {
          final preSelectedWallet = _wallets.firstWhere(
                  (w) => w['id'] == widget.preSelectedWalletId
          );
          _selectedWalletId = preSelectedWallet['id'];
        } catch (e) {
          // Se non trovato, usa il primo wallet disponibile
          if (_wallets.isNotEmpty) {
            _selectedWalletId = _wallets.first['id'];
          }
        }
      }
      // Fallback al primo wallet se non c'è pre-selezione
      else if (_wallets.isNotEmpty) {
        _selectedWalletId = _wallets.first['id'];
      }
    });
  }

  void _calculateTotal() {
    if (_amountController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      try {
        final amount = double.parse(_amountController.text.replaceAll(',', '.'));
        final pricePerUnit = double.parse(_priceController.text.replaceAll(',', '.'));
        final convertedPricePerUnit = _selectedPriceUnit.convertPrice(pricePerUnit, _selectedUnit);
        final total = amount * convertedPricePerUnit;
        setState(() {
          _totalPriceController.text = total.toStringAsFixed(2);
        });
      } catch (e) {
        // Ignora errori
      }
    }
  }

  void _calculatePricePerUnit() {
    if (_amountController.text.isNotEmpty && _totalPriceController.text.isNotEmpty) {
      try {
        final amount = double.parse(_amountController.text.replaceAll(',', '.'));
        final total = double.parse(_totalPriceController.text.replaceAll(',', '.'));
        final priceInQuantityUnit = total / amount;
        final pricePerUnit = _selectedUnit.convertPrice(priceInQuantityUnit, _selectedPriceUnit);
        setState(() {
          _priceController.text = pricePerUnit.toStringAsFixed(2);
        });
      } catch (e) {
        // Ignora errori
      }
    }
  }

  void _calculateAmount() {
    if (_priceController.text.isNotEmpty && _totalPriceController.text.isNotEmpty) {
      try {
        final pricePerUnit = double.parse(_priceController.text.replaceAll(',', '.'));
        final total = double.parse(_totalPriceController.text.replaceAll(',', '.'));
        final convertedPricePerUnit = _selectedPriceUnit.convertPrice(pricePerUnit, _selectedUnit);
        final amount = total / convertedPricePerUnit;
        setState(() {
          _amountController.text = amount.toStringAsFixed(2);
        });
      } catch (e) {
        // Ignora errori
      }
    }
  }

  Future<void> _submitDeal() async {
    if (_formKey.currentState!.validate() && _selectedWalletId != null) {
      try {
        // Sostituisce le virgole e converte in double
        final amount = double.parse(_amountController.text.replaceAll(',', '.'));
        final pricePerUnit = double.parse(_priceController.text.replaceAll(',', '.'));

        double finalPricePerUnit = pricePerUnit;
        if (_selectedPriceUnit != _selectedUnit) {
          finalPricePerUnit = _selectedPriceUnit.convertPrice(pricePerUnit, _selectedUnit);
        }

        final deal = Deal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          walletId: _selectedWalletId!,
          goodId: _selectedGoodId ?? '',
          personId: _selectedPersonId,
          type: widget.dealType,
          amount: amount,
          unit: _selectedUnit,
          currency: _selectedCurrency,
          pricePerUnit: finalPricePerUnit,
          timestamp: DateTime.now(),
          date: _selectedDate,
          isPending: isPendin,
        );

        await _dealService.createDeal(deal);
         widget.onDealCreated?.call();

        if (mounted) {
          // Navigator.pop(context);
          context.router.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Deal creato con successo!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Errore: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dealType == TxType.purchase ? 'New Purchase' : 'New Sell'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Selezione Wallet
              DropdownButtonFormField<String>(
                value: _selectedWalletId,
                decoration: const InputDecoration(labelText: 'Wallet'),
                items: _wallets.map((wallet) {
                  return DropdownMenuItem<String>(
                    value: wallet['id'],
                    child: Text(wallet['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWalletId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Seleziona un wallet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Prezzo totale e valuta
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _totalPriceController,
                      decoration: InputDecoration(
                        labelText: 'Prezzo totale',
                        suffixIcon: IconButton(
                          icon: Image.asset('assets/icons/wand.png',color: theme.colorScheme.primary, width: 20, height: 20,),
                          onPressed: _calculateTotal,
                          tooltip: 'Calcola totale',
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        if (value.contains(',')) {
                          final newValue = value.replaceAll(',', '.');
                          _totalPriceController.value = _totalPriceController.value.copyWith(
                            text: newValue,
                            selection: TextSelection.collapsed(offset: newValue.length),
                          );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il prezzo totale';
                        }
                        final numericValue = value.replaceAll(',', '.');
                        if (double.tryParse(numericValue) == null) {
                          return 'Inserisci un numero valido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<Value>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Valuta'),
                      items: Value.values.map((currency) {
                        return DropdownMenuItem<Value>(
                          value: currency,
                          child: Text('${currency.displayName} (${currency.symbol})',overflow: TextOverflow.ellipsis,),

                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quantità e unità di misura
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Quantità',
                        suffixIcon: IconButton(
                          icon: Image.asset('assets/icons/wand.png',color: theme.colorScheme.primary, width: 20, height: 20,),
                          onPressed: _calculateAmount,
                          tooltip: 'Calcola quantità',
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        if (value.contains(',')) {
                          final newValue = value.replaceAll(',', '.');
                          _amountController.value = _amountController.value.copyWith(
                            text: newValue,
                            selection: TextSelection.collapsed(offset: newValue.length),
                          );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci una quantità';
                        }
                        final numericValue = value.replaceAll(',', '.');
                        if (double.tryParse(numericValue) == null) {
                          return 'Inserisci un numero valido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<Unit>(
                      value: _selectedUnit,
                      isExpanded: true, // ← Aggiungi questa linea

                      decoration: const InputDecoration(labelText: 'Unità quantità'),
                      items: Unit.values.map((unit) {
                        return DropdownMenuItem<Unit>(
                          value: unit,
                          child: Text('${unit.displayName} (${unit.symbol})',overflow: TextOverflow.ellipsis,),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Prezzo per unità e sua unità di misura
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Prezzo per unità',
                        suffixIcon: IconButton(
                          icon: Image.asset('assets/icons/wand.png',color: theme.colorScheme.primary, width: 20, height: 20,),
                          onPressed: _calculatePricePerUnit,
                          tooltip: 'Calcola prezzo unitario',
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        if (value.contains(',')) {
                          final newValue = value.replaceAll(',', '.');
                          _priceController.value = _priceController.value.copyWith(
                            text: newValue,
                            selection: TextSelection.collapsed(offset: newValue.length),
                          );
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci un prezzo';
                        }
                        final numericValue = value.replaceAll(',', '.');
                        if (double.tryParse(numericValue) == null) {
                          return 'Inserisci un numero valido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<Unit>(
                      value: _selectedPriceUnit,
                      isExpanded: true, // ← Aggiungi questa linea

                      decoration: const InputDecoration(labelText: 'Unità prezzo'),
                      items: Unit.values.map((unit) {
                        return DropdownMenuItem<Unit>(
                          value: unit,
                          child: Text('${unit.displayName} (${unit.symbol})',overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriceUnit = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Etichetta che mostra l'unità del prezzo
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Prezzo espresso in: ${_selectedCurrency.symbol}/${_selectedPriceUnit.symbol}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Row(
                    children: [
                      const Text('Data:'),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Switch(value: isPendin,
                      activeTrackColor: theme.colorScheme.primary,
                        onChanged:
                          (value) {
                        setState(() {
                          isPendin = value;
                        });
                      },

                      ),
                      Text(isPendin==true ? 'Pending' : 'Confirmed',style: TextStyle(color: isPendin==true ? theme.colorScheme.primary : theme.colorScheme.onSecondary),),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bottone di conferma
              ElevatedButton(
                onPressed: _submitDeal,
                child: const Text('Create Deal',),
              ),
            ],
          ),
        ),
      ),
    );
  }
}