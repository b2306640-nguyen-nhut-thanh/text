import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../shared/app_navigation_bar.dart';
import '../shared/app_header.dart';
import '../tours/tours_manager.dart';
import 'widgets/banner_slideshow.dart';
import 'widgets/section_header.dart';
import 'widgets/promotion_preview.dart';
import '../home/about_us/about_us_section.dart';
import '../home/why_choose_us/why_choose_us_section.dart';
import 'widgets/home_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _fetchTours;

  @override
  void initState() {
    super.initState();
    _fetchTours = context.read<ToursManager>().fetchTours();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern('vi_VN');

    return Scaffold(
      appBar: const AppHeader(title: Text('Travol')),
      bottomNavigationBar: const AppNavigationBar(),
      body: FutureBuilder(
        future: _fetchTours,
        builder: (context, snapshot) {
          final tours = context.watch<ToursManager>().items;
          final featuredTours = tours.take(4).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              SizedBox(
                height: 270,
                child: Stack(
                  children: [
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 220,
                      child: BannerSlideshow(),
                    ),
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: HomeSearchBar(),
                    ),
                  ],
                ),
              ),
              const AboutUsSection(),
              SectionHeader(
                title: 'Tour nổi bật',
                actionLabel: 'Xem tất cả',
                onAction: () => context.go('/tours'),
              ),
              if (snapshot.connectionState != ConnectionState.done)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                SizedBox(
                  height: 238,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredTours.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final tour = featuredTours[index];
                      return SizedBox(
                        width: 240,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          margin: EdgeInsets.zero,
                          child: InkWell(
                            onTap: () => context.push('/tours/${tour.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Image.network(
                                    tour.imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tour.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${currency.format(tour.price)} đ/khách',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const WhyChooseUsSection(),
              SectionHeader(
                title: 'Khuyến mãi',
                actionLabel: 'Xem thêm',
                onAction: () => context.go('/promotions'),
              ),
              const PromotionPreview(
                icon: Icons.local_offer,
                title: 'Giảm 25% tour hè',
                subtitle: 'Áp dụng cho nhóm từ 4 khách.',
              ),
              const PromotionPreview(
                icon: Icons.card_giftcard,
                title: 'Tặng voucher khách sạn',
                subtitle: 'Dành cho booking từ 8.000.000 đ.',
              ),
            ],
          );
        },
      ),
    );
  }
}
