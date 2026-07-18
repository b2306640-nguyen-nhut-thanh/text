import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../services/pocketbase_client.dart';
import '../../shared/app_header.dart';
import '../destinations_manager.dart';

class ManageDestinationsScreen extends StatefulWidget {
  const ManageDestinationsScreen({super.key});

  @override
  State<ManageDestinationsScreen> createState() =>
      _ManageDestinationsScreenState();
}

class _ManageDestinationsScreenState extends State<ManageDestinationsScreen> {
  late Future<void> _fetchDestinations;

  @override
  void initState() {
    super.initState();
    _fetchDestinations =
        context.read<DestinationsManager>().fetchDestinations();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchDestinations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            appBar: AppHeader(title: Text('Quản lý Địa điểm')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final manager = context.watch<DestinationsManager>();
        final regions = manager.regions;

        return DefaultTabController(
          length: regions.isEmpty ? 1 : regions.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Quản lý Địa điểm'),
              bottom: TabBar(
                isScrollable: true,
                tabs: regions.isEmpty
                    ? [const Tab(text: 'Tất cả')]
                    : regions.map((r) => Tab(text: r)).toList(),
              ),
            ),
            body: regions.isEmpty
                ? const Center(child: Text('Chưa có địa điểm nào.'))
                : TabBarView(
                    children: regions.map((region) {
                      final destinations =
                          manager.getDestinationsByRegion(region);
                      return ListView.builder(
                        itemCount: destinations.length,
                        itemBuilder: (context, index) {
                          final dest = destinations[index];
                          return Dismissible(
                            key: ValueKey(dest.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            confirmDismiss: (direction) => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: Text('Bạn có chắc muốn xóa ${dest.title}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (direction) {
                              manager.deleteDestination(dest.id);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    dest.getDisplayImageUrl(baseUrl)),
                                onBackgroundImageError: (_, __) {},
                              ),
                              title: Text(dest.title),
                              subtitle: Text(dest.region),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  context.push('/manage-destinations/edit', extra: dest);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.push('/manage-destinations/edit'),
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
