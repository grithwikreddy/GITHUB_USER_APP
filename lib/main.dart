import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(_toggleTheme),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;

  HomeScreen(this.toggleTheme);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 20, right: 20),
              child: IconButton(
                icon: Icon(Icons.lightbulb_outline),
                onPressed: toggleTheme,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserSearchScreen()),
                    );
                  },
                  child: Text('Search GitHub Users'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserSearchScreen extends StatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  User? _selectedUser;

  Future<void> _searchUser() async {
    final query = _searchController.text;
    final response = await http.get(
      Uri.parse('https://api.github.com/users/$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final user = User.fromJson(data);

      setState(() {
        _selectedUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: null, // Removing the app bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search GitHub Users',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchUser,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_selectedUser != null)
              UserDetailsScreen(user: _selectedUser!),
          ],
        ),
      ),
    );
  }
}

class UserDetailsScreen extends StatelessWidget {
  final User user;

  UserDetailsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl),
            radius: 50,
          ),
          SizedBox(height: 20),
          Text(
            'Username: ${user.username}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text('Followers: ${user.followersCount.toString()}'),
          Text('Repositories: ${user.reposCount.toString()}'),
          SizedBox(height: 16),
          Text(
            'Bio: ${user.bio ?? "N/A"}',
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class User {
  final String username;
  final String avatarUrl;
  final int followersCount;
  final int reposCount;
  final String? bio;

  User({
    required this.username,
    required this.avatarUrl,
    required this.followersCount,
    required this.reposCount,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['login'],
      avatarUrl: json['avatar_url'],
      followersCount: json['followers'] ?? 0,
      reposCount: json['public_repos'] ?? 0,
      bio: json['bio'],
    );
  }
}