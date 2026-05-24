import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedCity;
  bool? _hasAC;

  @override
  void initState() {
    super.initState();
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    // Initialize with current filter values
    _selectedCity = roomProvider.selectedCity;
    _hasAC = roomProvider.hasACFilter;
  }

  void _applyFilters() {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    roomProvider.filterByCity(_selectedCity);
    roomProvider.filterByAC(_hasAC);

    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _hasAC = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Text(
                      'Filter Rooms',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearFilters,
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: AppColors.primaryRed),
                      ),
                    ),
                  ],
                ),
              ),

              // Filters Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    // City Filter
                    _buildCityFilter(),
                    const SizedBox(height: AppSpacing.lg),

                    // AC Filter
                    _buildACFilter(),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),

              // Apply Button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: CustomButton(
                  text: 'Apply Filters',
                  onPressed: _applyFilters,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCityFilter() {
    return Consumer<RoomProvider>(
      builder: (context, roomProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // All Cities option
            _buildFilterOption(
              title: 'All Cities',
              isSelected: _selectedCity == null,
              onTap: () {
                setState(() {
                  _selectedCity = null;
                });
              },
            ),

            // Individual cities
            ...roomProvider.cities.map((city) {
              return _buildFilterOption(
                title: city,
                isSelected: _selectedCity == city,
                onTap: () {
                  setState(() {
                    _selectedCity = city;
                  });
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildACFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Air Conditioning',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildFilterOption(
          title: 'Any',
          isSelected: _hasAC == null,
          onTap: () {
            setState(() {
              _hasAC = null;
            });
          },
        ),
        _buildFilterOption(
          title: 'AC Available',
          isSelected: _hasAC == true,
          onTap: () {
            setState(() {
              _hasAC = true;
            });
          },
        ),
        _buildFilterOption(
          title: 'Non-AC',
          isSelected: _hasAC == false,
          onTap: () {
            setState(() {
              _hasAC = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryRed : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? AppColors.primaryRed
                        : AppColors.primaryText,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
