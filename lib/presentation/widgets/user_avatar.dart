import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/providers/profile_provider.dart';

class UserAvatar extends ConsumerWidget {
  final String? imageUrl;
  final double size;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        final avatarUrl = imageUrl ?? profile.avatarUrl;

        return CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.white,
          child: avatarUrl != null && avatarUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(size / 2),
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl,
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
      },
      loading: () => CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      error: (_, __) => CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
