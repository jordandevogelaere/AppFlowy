import 'package:appflowy_editor/src/extensions/object_extensions.dart';
import 'package:appflowy_editor/src/document/node.dart';
import 'package:appflowy_editor/src/document/position.dart';
import 'package:appflowy_editor/src/document/selection.dart';
import 'package:appflowy_editor/src/infra/flowy_svg.dart';
import 'package:appflowy_editor/src/render/selection/selectable.dart';
import 'package:flutter/material.dart';

class WhatsappConfig {
  final String number;
  final String message;

  WhatsappConfig(this.number, this.message);
}

class WhatsAppNodeWidget extends StatefulWidget {
  const WhatsAppNodeWidget({
    Key? key,
    required this.node,
    required this.config,
    this.width,
    required this.alignment,
    required this.onEdit,
    required this.onDelete,
    required this.onAlign,
    required this.onResize,
  }) : super(key: key);

  final Node node;
  final WhatsappConfig config;
  final double? width;
  final Alignment alignment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(Alignment alignment) onAlign;
  final void Function(double width) onResize;

  @override
  State<WhatsAppNodeWidget> createState() => _WhatsAppNodeWidgetState();
}

class _WhatsAppNodeWidgetState extends State<WhatsAppNodeWidget>
    with SelectableMixin {
  final _imageKey = GlobalKey();

  double? _imageWidth;
  double _initial = 0;
  double _distance = 0;
  bool _onFocus = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // only support network image.
    return Container(
      key: _imageKey,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: _buildNetworkImage(context),
    );
  }

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

  Widget _buildNetworkImage(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: MouseRegion(
        onEnter: (event) => setState(() {
          _onFocus = true;
        }),
        onExit: (event) => setState(() {
          _onFocus = false;
        }),
        child: _buildResizableWhatsappButton(context),
      ),
    );
  }

  Widget _buildResizableWhatsappButton(BuildContext context) {
    return Stack(
      children: [
        Padding(
            padding: EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => {},
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
              ),
              child: Text("Whatsapp button"),
            )),
        _buildEdgeGesture(
          context,
          top: 0,
          left: 0,
          bottom: 0,
          width: 5,
          onUpdate: (distance) {
            setState(() {
              _distance = distance;
            });
          },
        ),
        _buildEdgeGesture(
          context,
          top: 0,
          right: 0,
          bottom: 0,
          width: 5,
          onUpdate: (distance) {
            setState(() {
              _distance = -distance;
            });
          },
        ),
        if (_onFocus)
          WhatsAppToolbar(
            top: 8,
            right: 8,
            height: 30,
            alignment: widget.alignment,
            onAlign: widget.onAlign,
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
          )
      ],
    );
  }

  Widget _buildEdgeGesture(
    BuildContext context, {
    double? top,
    double? left,
    double? right,
    double? bottom,
    double? width,
    void Function(double distance)? onUpdate,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      width: width,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          _initial = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          if (onUpdate != null) {
            onUpdate(details.globalPosition.dx - _initial);
          }
        },
        onHorizontalDragEnd: (details) {
          _imageWidth = _imageWidth! - _distance;
          _initial = 0;
          _distance = 0;

          widget.onResize(_imageWidth!);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: _onFocus
              ? Center(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

@visibleForTesting
class WhatsAppToolbar extends StatelessWidget {
  const WhatsAppToolbar({
    Key? key,
    required this.top,
    required this.right,
    required this.height,
    required this.alignment,
    required this.onEdit,
    required this.onDelete,
    required this.onAlign,
  }) : super(key: key);

  final double top;
  final double right;
  final double height;
  final Alignment alignment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(Alignment alignment) onAlign;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              hoverColor: Colors.transparent,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.fromLTRB(6.0, 4.0, 0.0, 4.0),
              icon: FlowySvg(
                name: 'image_toolbar/align_left',
                color: alignment == Alignment.centerLeft
                    ? const Color(0xFF00BCF0)
                    : null,
              ),
              onPressed: () {
                onAlign(Alignment.centerLeft);
              },
            ),
            IconButton(
              hoverColor: Colors.transparent,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
              icon: FlowySvg(
                name: 'image_toolbar/align_center',
                color: alignment == Alignment.center
                    ? const Color(0xFF00BCF0)
                    : null,
              ),
              onPressed: () {
                onAlign(Alignment.center);
              },
            ),
            IconButton(
              hoverColor: Colors.transparent,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.fromLTRB(0.0, 4.0, 4.0, 4.0),
              icon: FlowySvg(
                name: 'image_toolbar/align_right',
                color: alignment == Alignment.centerRight
                    ? const Color(0xFF00BCF0)
                    : null,
              ),
              onPressed: () {
                onAlign(Alignment.centerRight);
              },
            ),
            const Center(
              child: FlowySvg(
                name: 'image_toolbar/divider',
              ),
            ),
            IconButton(
              hoverColor: Colors.transparent,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.fromLTRB(4.0, 4.0, 0.0, 4.0),
              icon: const Icon(Icons.edit),
              onPressed: () {
                onEdit();
              },
            ),
            IconButton(
              hoverColor: Colors.transparent,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.fromLTRB(0.0, 4.0, 6.0, 4.0),
              icon: const FlowySvg(
                name: 'image_toolbar/delete',
              ),
              onPressed: () {
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
