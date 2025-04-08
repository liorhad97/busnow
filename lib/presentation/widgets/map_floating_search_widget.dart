import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:busnow/core/constants/colors.dart';
import 'package:busnow/core/constants/dimensions.dart';

class MapFloatingSearchWidget extends StatefulWidget {
  final bool isExpanded;
  final Function(String) onSearch;
  final VoidCallback onToggle;

  const MapFloatingSearchWidget({
    Key? key,
    required this.isExpanded,
    required this.onSearch,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<MapFloatingSearchWidget> createState() => _MapFloatingSearchWidgetState();
}

class _MapFloatingSearchWidgetState extends State<MapFloatingSearchWidget> 
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  
  List<String> _recentSearches = [
    'Central Station',
    'Market Street',
    'Union Square',
    'Downtown',
  ];
  
  List<String> _suggestions = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: AppDimensions.animDurationMedium),
      vsync: this,
    );
    
    _widthAnimation = Tween<double>(
      begin: 56, // Just the icon when collapsed
      end: 1.0, // Full width when expanded
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    
    // Initialize animation state
    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
    
    // Listen for text changes to show suggestions
    _searchController.addListener(_onSearchTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }
  
  @override
  void didUpdateWidget(MapFloatingSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle expansion state changes
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
        _focusNode.requestFocus();
      } else {
        _animationController.reverse();
        _focusNode.unfocus();
      }
    }
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _onSearchTextChanged() {
    final query = _searchController.text;
    setState(() {
      _isTyping = query.isNotEmpty;
      
      // Simple suggestion filtering
      if (query.isNotEmpty) {
        _suggestions = _recentSearches
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        _suggestions = [];
      }
    });
  }
  
  void _onFocusChanged() {
    if (_focusNode.hasFocus && !widget.isExpanded) {
      widget.onToggle();
    }
  }
  
  void _handleSearch(String query) {
    // Add to recent searches if not already there
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
    
    // Perform the search
    widget.onSearch(query);
    _searchController.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: AppDimensions.spacingMedium,
          left: AppDimensions.spacingMedium,
          right: AppDimensions.spacingMedium,
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Calculate dynamic width based on animation
            final maxWidth = mediaQuery.size.width - (AppDimensions.spacingMedium * 2);
            final width = _widthAnimation.value == 1.0 
                ? maxWidth 
                : _widthAnimation.value;
            
            return Stack(
              children: [
                // Suggestions panel
                if (_animationController.value > 0.8 && (_isTyping || _focusNode.hasFocus))
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: _buildSuggestionsPanel(theme, isDarkMode),
                  ),
                
                // Search bar
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: width,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        _animationController.value > 0.5 
                            ? AppDimensions.borderRadiusMedium 
                            : 28.0
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        _animationController.value > 0.5 
                            ? AppDimensions.borderRadiusMedium 
                            : 28.0
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          child: Row(
                            children: [
                              // Search icon button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: widget.onToggle,
                                  borderRadius: BorderRadius.circular(28),
                                  splashColor: AppColors.primary.withOpacity(0.1),
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(
                                      widget.isExpanded 
                                          ? Icons.arrow_back_rounded 
                                          : Icons.search_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Search text field
                              if (_animationController.value > 0.3)
                                Expanded(
                                  child: Opacity(
                                    opacity: (_animationController.value - 0.3) / 0.7,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 16.0),
                                      child: TextField(
                                        controller: _searchController,
                                        focusNode: _focusNode,
                                        decoration: InputDecoration(
                                          hintText: 'Search bus stops...',
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                            color: theme.hintColor,
                                          ),
                                          suffixIcon: _isTyping 
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    _focusNode.requestFocus();
                                                  },
                                                )
                                              : null,
                                        ),
                                        style: theme.textTheme.bodyLarge,
                                        onSubmitted: _handleSearch,
                                        textInputAction: TextInputAction.search,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildSuggestionsPanel(ThemeData theme, bool isDarkMode) {
    final suggestions = _isTyping ? _suggestions : _recentSearches;
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: AppDimensions.animDurationShort),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -10 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: theme.colorScheme.surface.withOpacity(0.9),
              constraints: const BoxConstraints(
                maxHeight: 250,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      _isTyping ? 'Suggestions' : 'Recent Searches',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                  
                  const Divider(height: 1, thickness: 1),
                  
                  // Suggestions list
                  if (suggestions.isEmpty) 
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          _isTyping 
                              ? 'No matches found' 
                              : 'No recent searches',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        
                        return ListTile(
                          leading: Icon(
                            Icons.history_rounded,
                            color: isDarkMode 
                                ? AppColors.darkTextSecondary 
                                : AppColors.lightTextSecondary,
                            size: 20,
                          ),
                          title: Text(
                            suggestion,
                            style: theme.textTheme.bodyMedium,
                          ),
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _handleSearch(suggestion);
                            widget.onToggle(); // Close search
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}