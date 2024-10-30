import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Daycare> _daycares = [];
  String _message = '';

  Future<void> _searchDaycares() async {
    final place = _searchController.text;
    if (place.isEmpty) {
      setState(() {
        _message = 'Type in your area';
        _daycares = []; // Clear previous results
      });
      return;
    }

    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/search?place=$place'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _daycares = data.map((json) => Daycare.fromJson(json)).toList();
        _message = _daycares.isEmpty ? "Can't find daycare in your area" : '';
      });
    } else {
      // Handle error
      setState(() {
        _message = 'Error fetching daycares';
        _daycares = []; // Clear previous results
      });
    }
  }

  void _navigateToDetails(Daycare daycare) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DaycareDetailPage(daycare: daycare),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Daycare'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter place',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchDaycares,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _daycares.length,
                itemBuilder: (context, index) {
                  final daycare = _daycares[index];
                  return ListTile(
                    title: Text(daycare.name),
                    subtitle: Text(
                        'Rating: ${daycare.rating} | Price: ${daycare.price}'),
                    onTap: () => _navigateToDetails(daycare),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Daycare {
  final String id;
  final String name;
  final String rating;
  final String price;

  Daycare(
      {required this.id,
      required this.name,
      required this.rating,
      required this.price});

  factory Daycare.fromJson(Map<String, dynamic> json) {
    return Daycare(
      id: json['id_daycare'],
      name: json['name_daycare'],
      rating: json['rating'].toString(),
      price: json['price'].toString(),
    );
  }
}

class DaycareDetailPage extends StatelessWidget {
  final Daycare daycare;

  const DaycareDetailPage({super.key, required this.daycare});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(daycare.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${daycare.name}', style: const TextStyle(fontSize: 24)),
            Text('Rating: ${daycare.rating}', style: const TextStyle(fontSize: 20)),
            Text('Price: ${daycare.price}', style: const TextStyle(fontSize: 20)),
            // Tambahkan detail lainnya sesuai kebutuhan
          ],
        ),
      ),
    );
  }
}
