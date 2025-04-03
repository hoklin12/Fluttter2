import 'dart:convert';
import 'dart:io';
import 'package:capstone_dr_rice/rice_disease_recognition/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Your AsyncValue implementation
enum AsyncValueState { loading, error, success }

class AsyncValue<T> {
  final T? data;
  final Object? error;
  final AsyncValueState state;

  AsyncValue._({this.data, this.error, required this.state});

  factory AsyncValue.loading() => AsyncValue._(state: AsyncValueState.loading);

  factory AsyncValue.success(T data) =>
      AsyncValue._(data: data, state: AsyncValueState.success);

  factory AsyncValue.error(Object error) =>
      AsyncValue._(error: error, state: AsyncValueState.error);
}

// REPOSITORY INTERFACE
abstract class PancakeRepository {
  Future<Pancake> addPancake({required String color, required double price});
  Future<List<Pancake>> getPancakes();
  Future<void> deletePancake(String id);
}

// FIREBASE IMPLEMENTATION
class FirebasePancakeRepository extends PancakeRepository {
  static const String baseUrl = 'https://pancakeapp-b56b8-default-rtdb.asia-southeast1.firebasedatabase.app/'; // Replace with your Firebase URL
  static const String pancakesCollection = "pancakes";
  static const String allPancakesUrl = '$baseUrl/$pancakesCollection.json';

  @override
  Future<Pancake> addPancake({required String color, required double price}) async {
    final uri = Uri.parse(allPancakesUrl);
    final newPancakeData = {'color': color, 'price': price};

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newPancakeData),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to add pancake');
    }

    final newId = json.decode(response.body)['name'];
    return Pancake(id: newId, color: color, price: price);
  }

  @override
  Future<List<Pancake>> getPancakes() async {
    final uri = Uri.parse(allPancakesUrl);
    final response = await http.get(uri);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to load pancakes');
    }

    final data = json.decode(response.body) as Map<String, dynamic>?;
    return data?.entries.map((e) => PancakeDto.fromJson(e.key, e.value)).toList() ?? [];
  }

  @override
  Future<void> deletePancake(String id) async {
    final uri = Uri.parse('$baseUrl/$pancakesCollection/$id.json');
    final response = await http.delete(uri);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Failed to delete pancake');
    }
  }
}

// MOCK IMPLEMENTATION FOR TESTING
class MockPancakeRepository extends PancakeRepository {
  final List<Pancake> _pancakes = [];

  @override
  Future<Pancake> addPancake({required String color, required double price}) {
    return Future.delayed(Duration(milliseconds: 500), () {
      final newPancake = Pancake(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        color: color,
        price: price,
      );
      _pancakes.add(newPancake);
      return newPancake;
    });
  }

  @override
  Future<List<Pancake>> getPancakes() {
    return Future.delayed(Duration(milliseconds: 500), () => _pancakes);
  }

  @override
  Future<void> deletePancake(String id) {
    return Future.delayed(Duration(milliseconds: 500), () {
      _pancakes.removeWhere((pancake) => pancake.id == id);
    });
  }
}

// DTO FOR JSON CONVERSION
class PancakeDto {
  static Pancake fromJson(String id, Map<String, dynamic> json) {
    return Pancake(
      id: id,
      color: json['color'],
      price: json['price'],
    );
  }

  static Map<String, dynamic> toJson(Pancake pancake) {
    return {
      'color': pancake.color,
      'price': pancake.price,
    };
  }
}

// DOMAIN MODEL
class Pancake {
  final String id;
  final String color;
  final double price;

  Pancake({
    required this.id,
    required this.color,
    required this.price,
  });

  @override
  bool operator ==(Object other) => 
      other is Pancake && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// STATE MANAGEMENT
class PancakeProvider extends ChangeNotifier {
  final PancakeRepository _repository;
  AsyncValue<List<Pancake>>? _pancakesState;

  PancakeProvider(this._repository) {
    fetchPancakes();
  }

  AsyncValue<List<Pancake>>? get pancakesState => _pancakesState;
  bool get isLoading => _pancakesState?.state == AsyncValueState.loading;
  bool get hasData => _pancakesState?.state == AsyncValueState.success;
  List<Pancake> get pancakes => hasData ? _pancakesState!.data! : [];

  // DISPLAY ALL ITEMS
  // Fetches and displays all pancakes from the repository
  Future<void> fetchPancakes() async {
    try {
      _pancakesState = AsyncValue.loading(); // Show loading state
      notifyListeners();
      // Get all pancakes from repository and update state
      _pancakesState = AsyncValue.success(await _repository.getPancakes());
    } catch (error) {
      _pancakesState = AsyncValue.error(error);
      print("Error fetching pancakes: $error");
    }
    notifyListeners(); // Notify UI to rebuild with new data
  }

  // ADD FEATURE
  // Implements optimistic UI update for adding new pancakes
  Future<void> addPancake(String color, double price) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final newPancake = Pancake(id: tempId, color: color, price: price);
    
    // Optimistic update: Add to UI immediately
    if (_pancakesState?.state == AsyncValueState.success) {
      _pancakesState = AsyncValue.success([..._pancakesState!.data!, newPancake]);
      notifyListeners();
    }

    try {
      // Perform actual repository operation
      final addedPancake = await _repository.addPancake(
        color: color,
        price: price,
      );
      
      // Update temporary ID with real ID from repository
      if (_pancakesState?.state == AsyncValueState.success) {
        final updatedPancakes = _pancakesState!.data!
            .map((pancake) => pancake.id == tempId ? addedPancake : pancake)
            .toList();
        _pancakesState = AsyncValue.success(updatedPancakes);
        notifyListeners();
      }
    } catch (error) {
      // Rollback on error: Remove the temporary item
      if (_pancakesState?.state == AsyncValueState.success) {
        _pancakesState = AsyncValue.success(
          _pancakesState!.data!.where((pancake) => pancake.id != tempId).toList()
        );
        notifyListeners();
      }
      print("Error adding pancake: $error");
      rethrow;
    }
  }

  // REMOVE FEATURE
  // Implements optimistic UI update for removing pancakes
  Future<void> deletePancake(String id) async {
    final pancakeToDelete = pancakes.firstWhere((pancake) => pancake.id == id);
    
    // Optimistic update: Remove from UI immediately (Option 2: better performance)
    if (_pancakesState?.state == AsyncValueState.success) {
      _pancakesState = AsyncValue.success(
        _pancakesState!.data!.where((pancake) => pancake.id != id).toList()
      );
      notifyListeners();
    }

    try {
      // Perform actual repository deletion
      await _repository.deletePancake(id);
    } catch (error) {
      // Rollback on error: Add item back to list
      if (_pancakesState?.state == AsyncValueState.success) {
        _pancakesState = AsyncValue.success([..._pancakesState!.data!, pancakeToDelete]);
        notifyListeners();
      }
      print("Error deleting pancake: $error");
      rethrow;
    }
  }
}

// UI LAYER
class PancakeApp extends StatelessWidget {
  const PancakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddPancakeDialog(context),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final pancakeProvider = context.watch<PancakeProvider>();

    // DISPLAY ALL ITEMS: Handle different states
    if (pancakeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!pancakeProvider.hasData || pancakeProvider.pancakes.isEmpty) {
      return const Center(child: Text('No pancakes available'));
    }

    // DISPLAY ALL ITEMS: Show list of pancakes
    return ListView.builder(
      itemCount: pancakeProvider.pancakes.length,
      itemBuilder: (context, index) {
        final pancake = pancakeProvider.pancakes[index];
        return ListTile(
          title: Text(pancake.color),
          subtitle: Text('\$${pancake.price.toStringAsFixed(2)}'),
          // REMOVE FEATURE: Delete button for each item
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => pancakeProvider.deletePancake(pancake.id),
          ),
        );
      },
    );
  }

  // ADD FEATURE: Dialog for adding new pancakes
  void _showAddPancakeDialog(BuildContext context) {
    final colorController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Pancake'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: colorController,
              decoration: const InputDecoration(labelText: 'Color'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<PancakeProvider>().addPancake(
                  colorController.text,
                  double.parse(priceController.text),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding pancake: $e')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // final pancakeRepository = MockPancakeRepository(); // Or FirebasePancakeRepository()
  final pancakeRepository = FirebasePancakeRepository(); // Switch to Firebase

  runApp(
    ChangeNotifierProvider(
      create: (context) => PancakeProvider(pancakeRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const PancakeApp(),
      ),
    ),
  );
}

