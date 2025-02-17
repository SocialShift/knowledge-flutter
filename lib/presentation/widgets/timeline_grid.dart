import 'package:flutter/material.dart';

enum ConnectionDirection { left, right, top, bottom }

class TimelineGrid extends StatelessWidget {
  final int itemCount;
  final Function(int index) onNodeTap;
  final List<TimelineNodeData> nodes;

  const TimelineGrid({
    super.key,
    required this.itemCount,
    required this.onNodeTap,
    required this.nodes,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return TimelineNode(
          data: node,
          onTap: () => onNodeTap(index),
          connections: _getConnections(index),
        );
      },
    );
  }

  List<ConnectionDirection> _getConnections(int index) {
    if (index % 2 == 0) {
      return [ConnectionDirection.right, ConnectionDirection.bottom];
    } else {
      return [ConnectionDirection.left, ConnectionDirection.bottom];
    }
  }
}

class TimelineNodeData {
  final int year;
  final bool isCompleted;
  final bool isActive;
  final String? imageUrl;
  final String? title;

  const TimelineNodeData({
    required this.year,
    required this.isCompleted,
    required this.isActive,
    this.imageUrl,
    this.title,
  });
}

class TimelineNode extends StatelessWidget {
  final TimelineNodeData data;
  final VoidCallback onTap;
  final List<ConnectionDirection> connections;

  static const double nodeSize = 80.0;
  static const double lineThickness = 3.0;
  static const double lineLength = 40.0;

  const TimelineNode({
    super.key,
    required this.data,
    required this.onTap,
    required this.connections,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Connection lines
          ...connections
              .map((direction) => _buildConnection(context, direction)),

          // Circle node
          Center(
            child: Hero(
              tag: 'timeline_node_${data.year}',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: data.isCompleted || data.isActive ? onTap : null,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: nodeSize,
                    height: nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getNodeColor(context),
                      border: Border.all(
                        color: data.isActive
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: lineThickness,
                      ),
                      image: _buildNodeImage(),
                    ),
                    child: _buildNodeContent(),
                  ),
                ),
              ),
            ),
          ),

          // Year text
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Text(
              data.year.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNodeColor(BuildContext context) {
    if (data.isCompleted) {
      return Theme.of(context).colorScheme.primary;
    } else if (data.isActive) {
      return const Color(0xFFB5FF3A);
    }
    return Colors.grey[300]!;
  }

  DecorationImage? _buildNodeImage() {
    if (!data.isCompleted && !data.isActive) return null;

    return data.imageUrl != null
        ? DecorationImage(
            image: NetworkImage(data.imageUrl!),
            fit: BoxFit.cover,
          )
        : const DecorationImage(
            image: AssetImage('assets/images/placeholder.png'),
            fit: BoxFit.cover,
          );
  }

  Widget? _buildNodeContent() {
    if (data.isCompleted || data.isActive) return null;
    return Icon(Icons.lock, color: Colors.grey[600]);
  }

  Widget _buildConnection(BuildContext context, ConnectionDirection direction) {
    final color = data.isCompleted
        ? Theme.of(context).colorScheme.primary
        : Colors.grey[300]!;

    return Positioned(
      left: direction == ConnectionDirection.left ? 0 : null,
      right: direction == ConnectionDirection.right ? 0 : null,
      top: direction == ConnectionDirection.top ? 0 : null,
      bottom: direction == ConnectionDirection.bottom ? 0 : null,
      child: Center(
        child: Container(
          width: direction.isHorizontal ? lineLength : lineThickness,
          height: direction.isHorizontal ? lineThickness : lineLength,
          color: color,
        ),
      ),
    );
  }
}

extension ConnectionDirectionX on ConnectionDirection {
  bool get isHorizontal =>
      this == ConnectionDirection.left || this == ConnectionDirection.right;
}
