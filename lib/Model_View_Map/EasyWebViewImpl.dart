import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class EasyWebViewImpl {
  final String src;
  final num width, height;
  final bool webAllowFullScreen;
  final bool isMarkdown;
  final bool isHtml;
  final bool convertToWidgets;
  final Map<String, String> headers;
  final bool widgetsTextSelectable;
  final void Function() onLoaded;

  EasyWebViewImpl({
    @required this.src,
    this.width,
    this.height,
    @required this.onLoaded,
    this.webAllowFullScreen = true,
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidgets = false,
    this.widgetsTextSelectable = false,
    this.headers,
  }) : assert((isHtml && isMarkdown) == false);

  static String wrapHtml(String src) {
    if (EasyWebViewImpl.isValidHtml(src)) {
      return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
$src
</body>
</html>
  """;
    }
    return src;
  }

  static String html2Md(String src) => html2md.convert(src);

  static String md2Html(String src) => markdownToHtml(src);

  static bool isUrl(String src) =>
      src.startsWith('https://') || src.startsWith('http://');

  static bool isValidHtml(String src) =>
      src.contains('<html>') && src.contains('</html>');
}

class OptionalSizedChild extends StatelessWidget {
  final num width, height;
  final Widget Function(num, num) builder;

  const OptionalSizedChild({
    Key key,
    @required this.width,
    @required this.height,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (width == null || height == null) {
      return LayoutBuilder(
        builder: (context, dimens) {
          final w = width ?? dimens.maxWidth;
          final h = height ?? dimens.maxHeight;
          return SizedBox(
            width: w,
            height: h,
            child: builder(w, h),
          );
        },
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: builder(width, height),
    );
  }
}

class RemoteMarkdown extends StatelessWidget {
  const RemoteMarkdown({
    Key key,
    @required this.src,
    @required this.headers,
    @required this.isSelectable,
  }) : super(key: key);

  final String src;
  final Map<String, String> headers;
  final bool isSelectable;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<http.Response>(
      future: http.get(src, headers: headers),
      builder: (context, response) {
        if (!response.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        if (response.data.statusCode == 200) {
          String content = response.data.body;
          if (EasyWebViewImpl.isValidHtml(src)) {
            content = EasyWebViewImpl.html2Md(content);
          }
          return LocalMarkdown(
            data: content,
            isSelectable: isSelectable,
          );
        }
        return Center(child: Icon(Icons.error));
      },
    );
  }
}

class LocalMarkdown extends StatelessWidget {
  final String data;
  final bool isSelectable;

  const LocalMarkdown({
    Key key,
    @required this.data,
    @required this.isSelectable,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data,
      onTapLink: launch,
      selectable: isSelectable,
    );
  }
}