import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';

/// Extension on [String] to convert a URL string into a [CachedNetworkImage] widget.
extension StringImageExt on String {
  /// Converts this [String] image URL to a [CachedNetworkImage] widget with optional customizations.
  Widget image({
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    Alignment alignment = Alignment.center,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    ImageWidgetBuilder? imageBuilder,
    Map<String, String>? httpHeaders,
    Color? color,
    BlendMode? colorBlendMode,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
    bool useShimmer = true,
    IconData fallbackIcon = Icons.broken_image_rounded,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
  }) {
    final trimmedUrl = trim();
    if (trimmedUrl.isEmpty) {
      return _buildFallback(
        key: key,
        width: width,
        height: height,
        borderRadius: borderRadius,
        shape: shape,
        fallbackIcon: fallbackIcon,
        errorWidget: errorWidget,
        url: trimmedUrl,
      );
    }

    Widget child = CachedNetworkImage(
      key: key,
      imageUrl: trimmedUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      httpHeaders: httpHeaders,
      color: color,
      colorBlendMode: colorBlendMode,
      fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 300),
      fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 300),
      imageBuilder: imageBuilder,
      placeholder: placeholder ??
          (context, url) => useShimmer
              ? _buildShimmerPlaceholder(
                  context,
                  width: width,
                  height: height,
                  borderRadius: borderRadius,
                  shape: shape,
                  baseColor: shimmerBaseColor,
                  highlightColor: shimmerHighlightColor,
                )
              : Container(
                  width: width,
                  height: height,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surface
                      : Colors.grey[200],
                ),
      errorWidget: errorWidget ??
          (context, url, error) => _buildFallback(
                key: key,
                width: width,
                height: height,
                borderRadius: borderRadius,
                shape: shape,
                fallbackIcon: fallbackIcon,
                errorWidget: errorWidget,
                url: url,
                error: error,
              ),
    );

    if (borderRadius != null && shape != BoxShape.circle) {
      child = ClipRRect(
        borderRadius: borderRadius,
        child: child,
      );
    } else if (shape == BoxShape.circle) {
      child = ClipOval(
        child: child,
      );
    }

    return child;
  }

  static Widget _buildShimmerPlaceholder(
    BuildContext context, {
    double? width,
    double? height,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBase = isDark ? AppColors.border : Colors.grey[300]!;
    final defaultHighlight = isDark
        ? Theme.of(context).colorScheme.surface
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBase,
      highlightColor: highlightColor ?? defaultHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: shape == BoxShape.circle ? null : borderRadius,
          shape: shape,
        ),
      ),
    );
  }

  static Widget _buildFallback({
    Key? key,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    IconData fallbackIcon = Icons.broken_image_rounded,
    LoadingErrorWidgetBuilder? errorWidget,
    required String url,
    Object? error,
  }) {
    Widget fallback = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: Colors.grey.withValues(alpha: 0.15),
      child: Icon(
        fallbackIcon,
        color: AppColors.textMuted,
        size: (width != null && height != null)
            ? (width < height ? width * 0.4 : height * 0.4)
            : 24.0,
      ),
    );

    if (borderRadius != null && shape != BoxShape.circle) {
      fallback = ClipRRect(
        borderRadius: borderRadius,
        child: fallback,
      );
    } else if (shape == BoxShape.circle) {
      fallback = ClipOval(
        child: fallback,
      );
    }

    return fallback;
  }
}

/// Extension on nullable [String] to convert a URL string into a [CachedNetworkImage] widget.
extension NullableStringImageExt on String? {
  /// Converts a nullable [String] image URL to a [CachedNetworkImage] widget with optional customizations.
  Widget image({
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    Alignment alignment = Alignment.center,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    ImageWidgetBuilder? imageBuilder,
    Map<String, String>? httpHeaders,
    Color? color,
    BlendMode? colorBlendMode,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
    bool useShimmer = true,
    IconData fallbackIcon = Icons.broken_image_rounded,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
  }) {
    if (this == null) {
      return StringImageExt._buildFallback(
        key: key,
        width: width,
        height: height,
        borderRadius: borderRadius,
        shape: shape,
        fallbackIcon: fallbackIcon,
        errorWidget: errorWidget,
        url: '',
      );
    }

    return this!.image(
      key: key,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      placeholder: placeholder,
      errorWidget: errorWidget,
      imageBuilder: imageBuilder,
      httpHeaders: httpHeaders,
      color: color,
      colorBlendMode: colorBlendMode,
      borderRadius: borderRadius,
      shape: shape,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      useShimmer: useShimmer,
      fallbackIcon: fallbackIcon,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
    );
  }
}

/// Extension on [Uri] to convert a [Uri] object into a [CachedNetworkImage] widget.
extension UriImageExt on Uri {
  /// Converts a [Uri] image object to a [CachedNetworkImage] widget with optional customizations.
  Widget image({
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    Alignment alignment = Alignment.center,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    ImageWidgetBuilder? imageBuilder,
    Map<String, String>? httpHeaders,
    Color? color,
    BlendMode? colorBlendMode,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
    bool useShimmer = true,
    IconData fallbackIcon = Icons.broken_image_rounded,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
  }) {
    return toString().image(
      key: key,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      placeholder: placeholder,
      errorWidget: errorWidget,
      imageBuilder: imageBuilder,
      httpHeaders: httpHeaders,
      color: color,
      colorBlendMode: colorBlendMode,
      borderRadius: borderRadius,
      shape: shape,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      useShimmer: useShimmer,
      fallbackIcon: fallbackIcon,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
    );
  }
}

/// Extension on nullable [Uri] to convert a [Uri] object into a [CachedNetworkImage] widget.
extension NullableUriImageExt on Uri? {
  /// Converts a nullable [Uri] image object to a [CachedNetworkImage] widget with optional customizations.
  Widget image({
    Key? key,
    double? width,
    double? height,
    BoxFit? fit,
    Alignment alignment = Alignment.center,
    PlaceholderWidgetBuilder? placeholder,
    LoadingErrorWidgetBuilder? errorWidget,
    ImageWidgetBuilder? imageBuilder,
    Map<String, String>? httpHeaders,
    Color? color,
    BlendMode? colorBlendMode,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Duration? fadeInDuration,
    Duration? fadeOutDuration,
    bool useShimmer = true,
    IconData fallbackIcon = Icons.broken_image_rounded,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
  }) {
    final urlStr = this?.toString();
    return urlStr.image(
      key: key,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      placeholder: placeholder,
      errorWidget: errorWidget,
      imageBuilder: imageBuilder,
      httpHeaders: httpHeaders,
      color: color,
      colorBlendMode: colorBlendMode,
      borderRadius: borderRadius,
      shape: shape,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      useShimmer: useShimmer,
      fallbackIcon: fallbackIcon,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
    );
  }
}
