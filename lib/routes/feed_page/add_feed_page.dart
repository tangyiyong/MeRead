import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meread/models/feed.dart';
import 'package:meread/routes/feed_page/edit_feed_page.dart';
import 'package:meread/utils/notification_util.dart';
import 'package:meread/utils/parse_feed_util.dart';

class AddFeedPage extends StatefulWidget {
  const AddFeedPage({super.key});

  @override
  State<AddFeedPage> createState() => _AddFeedPageState();
}

class _AddFeedPageState extends State<AddFeedPage> {
  final TextEditingController _urlController = TextEditingController();
  // 右侧 Feed 编辑页面
  Widget? rightWidget;
  // 左侧 Feed 添加页面宽度
  double leftWidth = 400;
  // 右侧 Feed 编辑页面宽度
  double rightWidth = 400;

  // 展示解析得到的 Feed 详情
  Widget _feedWidget = const SizedBox();

  @override
  void initState() {
    super.initState();
    _feedWidget = const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return buildScaffold();
    } else {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: leftWidth,
              child: buildScaffold(),
            ),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  leftWidth += details.delta.dx;
                  if (leftWidth < 200) {
                    leftWidth = 200;
                  } else if (leftWidth > 800) {
                    leftWidth = 800;
                  }
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: SizedBox(
                  width: 8,
                  child: Center(
                    child: VerticalDivider(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            buildRightWidget(),
            if (rightWidget != null)
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    rightWidth += details.delta.dx;
                    if (rightWidth < 200) {
                      rightWidth = 200;
                    } else if (rightWidth > 800) {
                      rightWidth = 800;
                    }
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: SizedBox(
                    width: 8,
                    child: Center(
                      child: VerticalDivider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  Widget buildRightWidget() {
    return SizedBox(
      width: rightWidth,
      child: rightWidget ?? const SizedBox.shrink(),
    );
  }

  Widget buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addFeed),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          children: [
            TextField(
              autofocus: true,
              controller: _urlController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context)!.enterFeedUrl,
                labelText: AppLocalizations.of(context)!.feedUrl,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    /* 从剪贴板获取订阅源地址，光标移到末尾 */
                    Clipboard.getData('text/plain').then(
                      (value) {
                        if (value != null) {
                          _urlController.text = value.text!;
                          _urlController.selection = TextSelection.fromPosition(
                            TextPosition(offset: value.text!.length),
                          );
                        }
                      },
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.paste),
                ),
                const SizedBox(width: 24),
                TextButton(
                  onPressed: () async {
                    // 收起键盘
                    FocusScope.of(context).requestFocus(FocusNode());
                    /* 解析订阅源地址 */
                    if (await Feed.isExist(_urlController.text)) {
                      if (!mounted) return;
                      showToastOrSnackBar(
                        context,
                        AppLocalizations.of(context)!.feedAlreadyExists,
                      );
                    } else {
                      Feed? feed = await parseFeed(_urlController.text);
                      if (feed != null) {
                        setState(() {
                          _feedWidget = Card(
                            elevation: 0,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: ListTile(
                              title: Text(feed.name),
                              subtitle: Text(
                                feed.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              minVerticalPadding: 12,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              onTap: () {
                                // 打开编辑页面
                                if (Platform.isAndroid) {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          EditFeedPage(feed: feed),
                                    ),
                                  ).then(
                                    (value) => Navigator.pop(context),
                                  );
                                } else {
                                  setState(() {
                                    rightWidget = EditFeedPage(
                                      feed: feed,
                                      needLeading: false,
                                      fromAddPage: true,
                                    );
                                  });
                                }
                              },
                            ),
                          );
                        });
                      } else {
                        if (!mounted) return;
                        showToastOrSnackBar(
                          context,
                          AppLocalizations.of(context)!.unableToParseFeed,
                        );
                      }
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.parse),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _feedWidget,
            ),
          ],
        ),
      ),
    );
  }
}
