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
    
    _scrollController.addListener(() {
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
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
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
      builder: (context) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CampingItemsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
      
          backgroundColor: Colors.white,
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
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12,12, 12, 0), // Padding réduit en haut
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher du matériel...',
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                       //   contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
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
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
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
                          label: const Text('Localisation sélectionnée'),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey[300]!),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => viewModel.applyFilters(locationId: null),
                        ),
                      ),
                    // ... autres chips ...
                  ],
                ),
              ),
            const Divider(height: 16, thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CampingItemsViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.only(top: _isAtTop ? 72 : 0), // Ajustement de l'espace
      child: _buildContentList(viewModel),
    );
  }

  Widget _buildContentList(CampingItemsViewModel viewModel) {
    if (viewModel.isLoading) return const Center(child: CircularProgressIndicator());
    if (viewModel.error.isNotEmpty) return _buildErrorWidget(viewModel);
    if (viewModel.filteredItems.isEmpty) return _buildEmptyWidget();
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => true,
      child: RefreshIndicator(
        onRefresh: () => viewModel.refreshItems(),
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          itemCount: viewModel.filteredItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.52,
          ),
          itemBuilder: (context, index) {
            final item = viewModel.filteredItems[index];
            return CampingItemCard(item: item);
          },
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
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('Aucun résultat trouvé'),
        ],
      ),
    );
  }
}