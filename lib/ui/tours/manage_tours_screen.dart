import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../shared/app_header.dart';
import 'tours_manager.dart';

class ManageToursScreen extends StatefulWidget {
  const ManageToursScreen({super.key});

  @override
  State<ManageToursScreen> createState() => _ManageToursScreenState();
}

class _ManageToursScreenState extends State<ManageToursScreen> {
  late Future<void> _fetchTours;

  @override
  void initState() {
    super.initState();
    _fetchTours = context.read<ToursManager>().fetchTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: const Text('Quản lý tour'),
        actions: [
          IconButton(
            tooltip: 'Thêm tour',
            onPressed: () => context.push('/manage-tours/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchTours,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final tours = context.watch<ToursManager>().items;
          return ListView.separated(
            itemCount: tours.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tour = tours[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(tour.imageUrl),
                ),
                title: Text(tour.title),
                subtitle: Text(tour.location),
                trailing: Wrap(
                  children: [
                    IconButton(
                      tooltip: 'Sửa',
                      onPressed: () =>
                          context.push('/manage-tours/${tour.id}/edit'),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      tooltip: 'Xóa',
                      onPressed: () =>
                          context.read<ToursManager>().deleteTour(tour.id),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
