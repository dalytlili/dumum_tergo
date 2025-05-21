import 'package:dumum_tergo/viewmodels/user/camping_items_viewmodel.dart';
import 'package:dumum_tergo/views/user/item/camping_item_card.dart';
import 'package:dumum_tergo/views/user/item/filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class CampingItemsScreen extends StatefulWidget {
  const CampingItemsScreen({Key? key}) : super(key: key);

  @override
  State<CampingItemsScreen> createState() => _CampingItemsScreenState();
}

class _CampingItemsScreenState extends State<CampingItemsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  double _searchBarOffset = 0;
  double _lastScrollPosition = 0;
  bool _isAtTop = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CampingItemsViewModel>(context, listen: false).fetchCampingItems();
    });
    _searchController.addListener(_onSearchChanged);
    
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final currentPosition = _scrollController.offset;
    final scrollDirection = currentPosition > _lastScrollPosition 
        ? ScrollDirection.reverse 
        : ScrollDirection.forward;
    final scrollDistance = (currentPosition - _lastScrollPosition).abs();

    setState(() {
      _isAtTop = currentPosition <= 0;
      
      if (scrollDirection == ScrollDirection.reverse && !_isAtTop) {
        _searchBarOffset = (_searchBarOffset - scrollDistance * 2.5)
            .clamp(-120.0, 0.0);
      } else if (scrollDirection == ScrollDirection.forward) {
        _searchBarOffset = (_searchBarOffset + scrollDistance * 2.5)
            .clamp(-120.0, 0.0);
      }
      _lastScrollPosition = currentPosition;
    });

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = maxScroll - currentScroll;

    if (delta < 100 && 
        !Provider.of<CampingItemsViewModel>(context, listen: false).isLoadingMore &&
        Provider.of<CampingItemsViewModel>(context, listen: false).hasMore) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    await Provider.of<CampingItemsViewModel>(context, listen: false).loadMoreCampingItems();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    Provider.of<CampingItemsViewModel>(context, listen: false)
        .applyFilters(searchTerm: _searchController.text);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CampingItemsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildContent(viewModel),
              _buildSlidingSearchBar(context, viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlidingSearchBar(BuildContext context, CampingItemsViewModel viewModel) {
    return Positioned(
      top: _searchBarOffset,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Rechercher du matériel...',
                          hintStyle: TextStyle(color: Theme.of(context).hintColor),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 20, color: Theme.of(context).hintColor),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.onPrimary),
                      onPressed: _showFilterSheet,
                    ),
                  ),
                ],
              ),
            ),
            if (viewModel.currentCategory != 'All' || 
                viewModel.currentType != 'All' || 
                viewModel.currentCondition != 'All')
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (viewModel.currentLocationId != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text('Localisation sélectionnée', 
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          side: BorderSide(color: Theme.of(context).dividerColor),
                          deleteIcon: Icon(Icons.close, size: 18, color: Theme.of(context).hintColor),
                          onDeleted: () => viewModel.applyFilters(locationId: null),
                        ),
                      ),
                  ],
                ),
              ),
            Divider(height: 16, thickness: 1, color: Theme.of(context).dividerColor),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CampingItemsViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.only(top: _isAtTop ? 72 : 0),
      child: _buildContentList(viewModel),
    );
  }

  Widget _buildContentList(CampingItemsViewModel viewModel) {
    if (viewModel.isLoading && !viewModel.isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (viewModel.error.isNotEmpty) return _buildErrorWidget(viewModel);
    if (viewModel.filteredItems.isEmpty) return _buildEmptyWidget();
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => true,
      child: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onRefresh: () => viewModel.refreshItems(),
        child: Stack(
          children: [
            GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: viewModel.filteredItems.length + (viewModel.hasMore ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.55,
              ),
              itemBuilder: (context, index) {
                if (index >= viewModel.filteredItems.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final item = viewModel.filteredItems[index];
                return CampingItemCard(item: item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(CampingItemsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            viewModel.error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.fetchCampingItems(),
            child: Text('Réessayer', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Theme.of(context).hintColor),
          const SizedBox(height: 16),
          Text('Aucun résultat trouvé', style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}