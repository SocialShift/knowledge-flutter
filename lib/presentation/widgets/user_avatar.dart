import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.white,
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : Icon(
              Icons.person,
              size: size * 0.6,
              color: Theme.of(context).colorScheme.primary,
            ),
    );
  }
}
