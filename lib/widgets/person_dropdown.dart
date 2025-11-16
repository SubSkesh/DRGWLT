// lib/widgets/person_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drgwallet/models/deal.dart';
import 'package:drgwallet/models/person.dart';
import 'package:drgwallet/models/enum.dart';
import 'package:drgwallet/providers/providers.dart';
import 'package:drgwallet/services/deal_service.dart';
import 'package:drgwallet/services/person_service.dart';
import 'package:drgwallet/widgets/person_avatar.dart';

// Trasformato in un ConsumerWidget, non più Stateful
class PersonDropdown extends ConsumerWidget {
  final Deal deal;
  final List<Person> persons;
  final Person? currentPerson;

  const PersonDropdown({
    super.key,
    required this.deal,
    required this.persons,
    this.currentPerson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // I service ora li otteniamo dal ref, non da istanze locali
    final dealService = ref.read(dealServiceProvider);
    final personService = ref.read(personServiceProvider);

    Color getPersonTypeColor(PersonType type) {
      switch (type) {
        case PersonType.supplier: return Colors.blue;
        case PersonType.buyer: return Colors.green;
        case PersonType.anon: return Colors.grey;
      }
    }

    return DropdownButtonFormField<Person?>(
      // LEGGI IL VALORE DIRETTAMENTE DAL WIDGET, NON DA UNO STATO LOCALE
      value: currentPerson,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Assign person',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<Person?>(
          value: null,
          child: Text('No person'),
        ),
        ...persons.map((person) {
          return DropdownMenuItem<Person?>(
            value: person,
            child: Row(
              children: [
                PersonAvatar(person: person, size: 30),
                const SizedBox(width: 8),
                Flexible(child: Text(person.name, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: getPersonTypeColor(person.personType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    person.type.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
      onChanged: (Person? selectedPerson) async {
        // Evita operazioni se la selezione non è cambiata
        if (currentPerson == selectedPerson) {
          return;
        }

        // NON C'È PIÙ setState()

        try {
          // Rimuovi il deal dalla persona precedente, se esisteva
          if (currentPerson != null) {
            await personService.removeDealFromPerson(currentPerson!.id, deal.id);
          }

          // Aggiungi il deal alla nuova persona, se selezionata
          if (selectedPerson != null) {
            await personService.addDealToPerson(selectedPerson.id, deal.id);
          }

          // Aggiorna il deal stesso con il nuovo personId
          final updatedDeal = deal.copyWith(personId: selectedPerson?.id);
          await dealService.updateDeal(updatedDeal);

          // Invalida i provider per forzare un ricaricamento globale dei dati
          ref.invalidate(enrichedDealProvider(deal.id));
          ref.invalidate(personsProvider);

        } catch (e) {
          // Mostra un errore se qualcosa va storto
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating association: $e'), backgroundColor: Colors.red),
          );
        }
      },
    );
  }
}
