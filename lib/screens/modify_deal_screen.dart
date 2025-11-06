import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/services/wallet_service.dart';
import 'package:drgwallet/theme/app_theme.dart';

@RoutePage(name: 'ModifyDealRoute')
class ModifyDealScreen extends StatefulWidget {
  final String dealId;

  const ModifyDealScreen({super.key, required this.dealId});

  @override
  State<ModifyDealScreen> createState() => _ModifyDealScreenState();
}

class _ModifyDealScreenState extends State<ModifyDealScreen> {
  final _formKey = GlobalKey<FormState>();
  final DealService _dealService = DealService();
  final WalletService _walletService = WalletService();

  // Controllers
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalPriceController = TextEditingController();

  // Stato
  Deal? _deal;
  bool _isLoading = true;

  // Dropdown values
  String? _selectedWalletId;
  Unit _selectedUnit = Unit.gram;
  Unit _selectedPriceUnit = Unit.gram;
  Value _selectedCurrency = Value.euro;
  DateTime _selectedDate = DateTime.now();
  bool _isPending = false;

  // Liste per dropdown
  List<Map<String, dynamic>> _wallets = [];

  @override
  void initState() {
    super.initState();
    _loadDealData();
  }

  Future<void> _loadDealData() async {
    try {
      // Carica i wallets
      final wallets = await _walletService.getUserWallets().first;
      setState(() {
        _wallets = wallets.map((wallet) => {
          'id': wallet.id,
          'name': wallet.name
        }).toList();
      });

      // Carica il deal
      final deal = await _dealService.getDeal(widget.dealId);

      if (deal != null) {
        setState(() {
          _deal = deal;
          _selectedWalletId = deal.walletId;
          _selectedUnit = deal.unit;
          _selectedPriceUnit = deal.unit; // Default come unità quantità
          _selectedCurrency = deal.currency;
          _selectedDate = deal.date;
          _isPending = deal.isPending;

          // Popola i controller
          _amountController.text = deal.amount.toString();
          _priceController.text = deal.pricePerUnit.toString();
          _totalPriceController.text = (deal.amount * deal.pricePerUnit).toStringAsFixed(2);
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    _totalPriceController.dispose();
    super.dispose();
  }

  // Metodi per i calcoli (presi da AddDealScreen)
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

  Future<void> _modifyDeal() async {
    if (!_formKey.currentState!.validate() || _selectedWalletId == null) return;

    setState(() => _isLoading = true);

    try {
      // Parsing valori
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final pricePerUnit = double.parse(_priceController.text.replaceAll(',', '.'));

      // Conversione unità prezzo se necessario
      double finalPricePerUnit = pricePerUnit;
      if (_selectedPriceUnit != _selectedUnit) {
        finalPricePerUnit = _selectedPriceUnit.convertPrice(pricePerUnit, _selectedUnit);
      }

      // Crea oggetto Deal aggiornato
      final updatedDeal = Deal(
        id: _deal!.id,
        walletId: _selectedWalletId!,
        goodId: _deal!.goodId,
        personId: _deal!.personId,
        type: _deal!.type,
        amount: amount,
        unit: _selectedUnit,
        currency: _selectedCurrency,
        pricePerUnit: finalPricePerUnit,
        timestamp: _deal!.timestamp, // Mantieni timestamp originale
        date: _selectedDate,
        isPending: _isPending,
      );

      await _dealService.updateDeal(updatedDeal);

      if (mounted) {
        context.router.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Deal succesfully modified!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante la modifica: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifica Deal',
          style: theme.textTheme.headlineSmall,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Wallet (sola lettura o modificabile?)
              DropdownButtonFormField<String>(
                value: _selectedWalletId,
                decoration: InputDecoration(
                  labelText: 'Wallet',
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                items: _wallets.map((wallet) {
                  return DropdownMenuItem<String>(
                    value: wallet['id'],
                    child: Text(
                      wallet['name'],
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
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
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        suffixIcon: IconButton(
                          icon: Image.asset('assets/icons/wand.png', color: theme.colorScheme.primary, width: 20, height: 20),
                          onPressed: _calculateTotal,
                          tooltip: 'Calcola totale',
                        ),
                      ),
                      style: TextStyle(color: theme.colorScheme.onSurface),
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
                      decoration: InputDecoration(
                        labelText: 'Valuta',
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      items: Value.values.map((currency) {
                        return DropdownMenuItem<Value>(
                          value: currency,
                          child: Text(
                            '${currency.displayName} (${currency.symbol})',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
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
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        suffixIcon: IconButton(
                          icon: Image.asset('assets/icons/wand.png', color: theme.colorScheme.primary, width: 20, height: 20),
                          onPressed: _calculateAmount,
                          tooltip: 'Calcola quantità',
                        ),
                      ),
                      style: TextStyle(color: theme.colorScheme.onSurface),
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
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Unità quantità',
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      items: Unit.values.map((unit) {
                        return DropdownMenuItem<Unit>(
                          value: unit,
                          child: Text(
                            '${unit.displayName} (${unit.symbol})',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
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
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        suffixIcon: IconButton(
                          icon: Image.asset('assets/icons/wand.png', color: theme.colorScheme.primary, width: 20, height: 20),
                          onPressed: _calculatePricePerUnit,
                          tooltip: 'Calcola prezzo unitario',
                        ),
                      ),
                      style: TextStyle(color: theme.colorScheme.onSurface),
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
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Unità prezzo',
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      items: Unit.values.map((unit) {
                        return DropdownMenuItem<Unit>(
                          value: unit,
                          child: Text(
                            '${unit.displayName} (${unit.symbol})',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                          ),
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
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Data e Pending status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Data:',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Switch(
                        value: _isPending,
                        activeTrackColor: theme.colorScheme.primary,
                        onChanged: (value) {
                          setState(() {
                            _isPending = value;
                          });
                        },
                      ),
                      Text(
                        _isPending ? 'Pending' : 'Confirmed',
                        style: TextStyle(
                          color: _isPending ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bottone di aggiornamento
              ElevatedButton(
                onPressed: _isLoading ? null : _modifyDeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update Deal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}