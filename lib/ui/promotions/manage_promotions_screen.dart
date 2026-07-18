import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../shared/app_header.dart';
import 'promotions_manager.dart';
import '../../services/pocketbase_client.dart';

class ManagePromotionsScreen extends StatefulWidget {
  const ManagePromotionsScreen({super.key});

  @override
  State<ManagePromotionsScreen> createState() => _ManagePromotionsScreenState();
}

class _ManagePromotionsScreenState extends State<ManagePromotionsScreen> {
  late Future<void> _fetchPromotions;

  @override
  void initState() {
    super.initState();
    _fetchPromotions = context.read<PromotionsManager>().fetchPromotions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: const Text('Quản lý khuyến mãi'),
        actions: [
          IconButton(
            tooltip: 'Thêm khuyến mãi',
            onPressed: () => context.push('/manage-promotions/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchPromotions,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final promotions = context.watch<PromotionsManager>().items;
          
          if (promotions.isEmpty) {
            return const Center(child: Text('Chưa có khuyến mãi nào.'));
          }

          return ListView.separated(
            itemCount: promotions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final promotion = promotions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(promotion.getDisplayImageUrl(baseUrl)),
                ),
                title: Text(promotion.title),
                subtitle: Text('Hết hạn: ${DateFormat('dd/MM/yyyy').format(promotion.endDate)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => context.push('/manage-promotions/${promotion.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: const Text('Bạn có chắc chắn muốn xóa khuyến mãi này?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          try {
                            await context.read<PromotionsManager>().deletePromotion(promotion.id);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Xóa thất bại')),
                              );
                            }
                          }
                        }
                      },
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
