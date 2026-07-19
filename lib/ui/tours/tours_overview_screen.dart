import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/tour.dart';
import '../booking/bookings_manager.dart';
import '../shared/app_header.dart';
import 'tours_manager.dart';
import '../../services/pocketbase_client.dart';

enum TourFilter { all, favorites }

class ToursOverviewScreen extends StatefulWidget {
  const ToursOverviewScreen({super.key, this.initialQuery = ''});
  final String initialQuery;

  @override
  State<ToursOverviewScreen> createState() => _ToursOverviewScreenState();
}

class _ToursOverviewScreenState extends State<ToursOverviewScreen> {
  late Future<void> _fetchTours;
  TourFilter _filter = TourFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _fetchTours = context.read<ToursManager>().fetchTours();
    context.read<BookingsManager>().fetchBookings();
  }

  @override
  void didUpdateWidget(covariant ToursOverviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery) {
      setState(() {
        _query = widget.initialQuery;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- PHẦN 1: HEADER & BỘ LỌC TÌM KIẾM ---
      appBar: AppHeader(
        title: const Text('Khám phá tour'),
        actions: [
          PopupMenuButton<TourFilter>(
            initialValue: _filter,
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: TourFilter.all,
                child: Text('Tất cả tour'),
              ),
              PopupMenuItem(
                value: TourFilter.favorites,
                child: Text('Tour yêu thích'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchTours,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final toursManager = context.watch<ToursManager>();
          final source = _filter == TourFilter.favorites
              ? toursManager.favoriteItems
              : toursManager.availableItems;
          final tours = source.where((tour) {
            final text = '${tour.title} ${tour.location}'.toLowerCase();
            return text.contains(_query.toLowerCase());
          }).toList();

          return RefreshIndicator(
            onRefresh: () => context.read<ToursManager>().fetchTours(),
            child: CustomScrollView(
              slivers: [
                // --- PHẦN 2: THANH TÌM KIẾM ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Tìm theo điểm đến hoặc tên tour...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                ),
                if (tours.isEmpty)
                  // --- PHẦN 3: TRẠNG THÁI TRỐNG ---
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Chưa có tour nào phù hợp'),
                    ),
                  )
                else
                  // --- PHẦN 4: DANH SÁCH TOUR (GRID) ---
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 90),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final columns = width >= 900
                            ? 3
                            : width >= 600
                                ? 2
                                : 1;
                        return SliverGrid.builder(
                          itemCount: tours.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            childAspectRatio: columns == 1 ? 1.45 : 0.92,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            return TourGridTile(tour: tours[index]);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TourGridTile extends StatelessWidget {
  const TourGridTile({super.key, required this.tour});
  final Tour tour;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/tours/${tour.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(tour.getDisplayImageUrl(baseUrl), fit: BoxFit.cover),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          '${tour.durationDays}N${tour.durationDays - 1}D',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tour.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      Text(tour.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${NumberFormat.decimalPattern('vi_VN').format(tour.price)} VNĐ / khách',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Yêu thích',
                        onPressed: () => context
                            .read<ToursManager>()
                            .toggleFavorite(tour.id),
                        icon: Consumer<ToursManager>(
                          builder: (context, manager, _) {
                            final isFav = manager.isFavorite(tour.id);
                            return Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: Theme.of(context).colorScheme.secondary,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}