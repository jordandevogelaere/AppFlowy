import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'dart:collection';


OverlayEntry? _youtubeUploadMenu;
EditorState? _editorState;
void showYoutubeUrl(
    EditorState editorState,
    SelectionMenuService menuService,
    BuildContext context,
    ) {
  menuService.dismiss();

  _youtubeUploadMenu?.remove();
  _youtubeUploadMenu = OverlayEntry(builder: (context) {
    return Positioned(
      top: menuService.topLeft.dy,
      left: menuService.topLeft.dx,
      child: Material(
        child: YoutubeUrlMenu(
          onSubmitted: (text) {
            // _dismissImageUploadMenu();
            editorState.insertYoutubeNode(text);
          },
          onUpload: (text) {
            // _dismissImageUploadMenu();
            editorState.insertYoutubeNode(text);
          },
        ),
      ),
    );
  });

  Overlay.of(context)?.insert(_youtubeUploadMenu!);

  editorState.service.selectionService.currentSelection
      .addListener(_dismissImageUploadMenu);
}

void _dismissImageUploadMenu() {
  _youtubeUploadMenu?.remove();
  _youtubeUploadMenu = null;

  _editorState?.service.selectionService.currentSelection
      .removeListener(_dismissImageUploadMenu);
  _editorState = null;
}

class YoutubeUrlMenu extends StatefulWidget {
  const YoutubeUrlMenu({
    Key? key,
    required this.onSubmitted,
    required this.onUpload,
  }) : super(key: key);

  final void Function(String text) onSubmitted;
  final void Function(String text) onUpload;

  @override
  State<YoutubeUrlMenu> createState() => _YoutubeUrlMenuState();
}

class _YoutubeUrlMenuState extends State<YoutubeUrlMenu> {
  final _textEditingController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16.0),
          _buildInput(),
          const SizedBox(height: 18.0),
          _buildUploadButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Text(
      'Youtube url',
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 14.0,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInput() {
    return TextField(
      focusNode: _focusNode,
      style: const TextStyle(fontSize: 14.0),
      textAlign: TextAlign.left,
      controller: _textEditingController,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: 'URL',
        hintStyle: const TextStyle(fontSize: 14.0),
        contentPadding: const EdgeInsets.all(16.0),
        isDense: true,
        suffixIcon: IconButton(
          padding: const EdgeInsets.all(4.0),
          icon: const FlowySvg(
            name: 'clear',
            width: 24,
            height: 24,
          ),
          onPressed: () {
            _textEditingController.clear();
          },
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: Color(0xFFBDBDBD)),
        ),
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 48,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xFF00BCF0)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        onPressed: () {
          widget.onUpload(_textEditingController.text);
        },
        child: const Text(
          'Upload',
          style: TextStyle(color: Colors.white, fontSize: 14.0),
        ),
      ),
    );
  }
}

extension on EditorState {
  void insertYoutubeNode(String src) {
    final selection = service.selectionService.currentSelection.value;
    if (selection == null) {
      return;
    }
    final youtubeNode = Node(
      type: 'youtube',
      children: LinkedList(),
      attributes: {
        'youtube_link': src,
      },
    );
    TransactionBuilder(this)
      ..insertNode(
        selection.start.path,
        youtubeNode,
      )
      ..commit();
  }
}

class YouTubeLinkNodeBuilder extends NodeWidgetBuilder<Node> {
  @override
  Widget build(NodeWidgetContext<Node> context) {
    return LinkNodeWidget(
      key: context.node.key,
      node: context.node,
      editorState: context.editorState,
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => ((node) {
        return node.type == 'youtube' && node.attributes.containsKey('youtube_link');
      });
}

class LinkNodeWidget extends StatefulWidget {
  final Node node;
  final EditorState editorState;

  const LinkNodeWidget({
    Key? key,
    required this.node,
    required this.editorState,
  }) : super(key: key);

  @override
  State<LinkNodeWidget> createState() => _YouTubeLinkNodeWidgetState();
}

class _YouTubeLinkNodeWidgetState extends State<LinkNodeWidget>
    with SelectableMixin {
  Node get node => widget.node;
  EditorState get editorState => widget.editorState;
  String get src => widget.node.attributes['youtube_link'] as String;

  @override
  Position start() {
    return Position(path: widget.node.path, offset: 0);
  }

  @override
  Position end() {
    return Position(path: widget.node.path, offset: 1);
  }

  @override
  Position getPositionInOffset(Offset start) {
    return end();
  }

  @override
  Rect? getCursorRectInPosition(Position position) {
    return null;
  }

  @override
  List<Rect> getRectsInSelection(Selection selection) {
    final renderBox = context.findRenderObject() as RenderBox;
    return [Offset.zero & renderBox.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) {
    if (start <= end) {
      return Selection(start: this.start(), end: this.end());
    } else {
      return Selection(start: this.end(), end: this.start());
    }
  }

  @override
  Offset localToGlobal(Offset offset) {
    final renderBox = context.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(offset);
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }

  late final PodPlayerController controller;

  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        src,
      ),
    )..initialise();
    super.initState();
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        PodVideoPlayer(controller: controller),
      ],
    );
  }
}
