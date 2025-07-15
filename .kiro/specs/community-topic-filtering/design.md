# Design Document

## Overview

The Community Topic Filtering feature will enhance the existing Community Screen by adding interactive filtering capabilities based on community topics. The design leverages the existing categories UI and integrates seamlessly with the current community data structure, where each community contains a `topics` array field from the backend API.

## Architecture

### State Management
- **Local State**: Use `selectedCategoryIds` (Set<String>) instead of single `selectedCategoryId` to support multiple selections
- **Computed State**: Filtered communities list derived from selected categories and community topics
- **Persistence**: Selected filters maintained during screen rebuilds but reset on navigation away

### Data Flow
1. User taps category → Update `selectedCategoryIds` state
2. State change triggers community list filtering
3. Filtered list updates the communities grid display
4. UI updates category styling and result counts

## Components and Interfaces

### Modified State Variables
```dart
class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  Set<String> selectedCategoryIds = <String>{}; // Changed from single String?
  
  // New computed property
  List<dynamic> get filteredCommunities {
    // Implementation details in tasks
  }
}
```

### Category Selection Logic
```dart
void _handleCategorySelection(String categoryId) {
  setState(() {
    if (selectedCategoryIds.contains(categoryId)) {
      selectedCategoryIds.remove(categoryId);
    } else {
      selectedCategoryIds.add(categoryId);
    }
  });
}
```

### Filtering Algorithm
- **Input**: List of communities from API, Set of selected category names
- **Process**: Filter communities where `community.topics` array contains ANY of the selected category names
- **Output**: Filtered list of communities or original list if no filters active

### UI Components to Modify

#### Categories Section
- Update category tap handler to support multiple selections
- Modify visual styling to show multiple selected states
- Add "Clear All" functionality when multiple categories selected

#### Communities Grid Header
- Dynamic count display: "X of Y communities" when filtered, "Y Active" when unfiltered
- Optional filter indicator showing active filter count

#### Community Cards
- No changes needed - existing cards work with filtered data

## Data Models

### Community Data Structure (from API)
```dart
{
  "id": 15,
  "name": "LGBTQ+ MEMBERS",
  "description": "...",
  "topics": ["LGBTQ+ Movements"], // Array of topic strings
  "banner_url": "...",
  "icon_url": "...",
  "created_at": "...",
  "created_by": 65,
  "member_count": 0,
  "is_member": false
}
```

### Category Mapping
```dart
final categories = [
  {'id': '1', 'name': 'Indigenous Histories', 'icon': '🏛️'},
  {'id': '2', 'name': 'African Diaspora', 'icon': '🌍'},
  {'id': '3', 'name': 'LGBTQ+ Movements', 'icon': '🏳️‍🌈'},
  // ... other categories
];
```

**Note**: The filtering will match category `name` field with community `topics` array values.

## Error Handling

### Edge Cases
1. **Empty Filter Results**: Show friendly empty state with option to clear filters
2. **API Data Inconsistency**: Handle cases where `topics` field is null/missing
3. **Category Name Mismatch**: Graceful handling when category names don't exactly match topic strings

### Error States
- **Loading State**: Disable category selection during data fetch
- **Error State**: Disable filtering when community data fails to load
- **Network Issues**: Maintain selected filters during retry operations

## Testing Strategy

### Unit Tests
- Filter logic with various community/topic combinations
- Category selection state management
- Edge cases (empty topics, null values)

### Integration Tests
- Category tap interactions
- Filter persistence during screen rebuilds
- Loading/error state interactions with filtering

### User Experience Tests
- Multiple category selection flows
- Filter clearing functionality
- Visual feedback for selected states

## Performance Considerations

### Optimization Strategies
- **Memoization**: Cache filtered results to avoid recomputation on rebuilds
- **Efficient Filtering**: Use Set operations for topic matching
- **Minimal Rebuilds**: Only rebuild affected UI components when filters change

### Memory Management
- Avoid creating new lists unnecessarily
- Use efficient data structures for category selection tracking

## Accessibility

### Screen Reader Support
- Announce filter state changes
- Provide clear labels for selected/unselected categories
- Announce filtered result counts

### Visual Accessibility
- Maintain sufficient color contrast for selected/unselected states
- Ensure touch targets meet minimum size requirements
- Support high contrast mode

## Implementation Notes

### Backward Compatibility
- Feature is additive - no breaking changes to existing functionality
- Graceful degradation if `topics` field is missing from API response

### Future Extensibility
- Design supports easy addition of new topic categories
- Filter logic can be extended for more complex matching (AND logic, nested categories)
- State structure allows for additional filter types (member count, activity level, etc.)