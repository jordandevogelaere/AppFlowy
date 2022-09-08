import 'package:appflowy_editor/src/document/node.dart';
import 'package:appflowy_editor/src/operation/transaction_builder.dart';
import 'package:appflowy_editor/src/service/render_plugin_service.dart';
import 'package:flutter/material.dart';

import 'whatsapp_node_widget.dart';

class WhatsappNodeBuilder extends NodeWidgetBuilder<Node> {
  @override
  Widget build(NodeWidgetContext<Node> context) {
    String? whatsappNumber;
    if (context.node.attributes.containsKey('whatsapp_number')) {
      whatsappNumber = context.node.attributes['whatsapp_number'];
    }
    final align = context.node.attributes['align'];
    double? width;
    if (context.node.attributes.containsKey('width')) {
      width = context.node.attributes['width'].toDouble();
    }
    return WhatsAppNodeWidget(
      key: context.node.key,
      node: context.node,
      config: WhatsappConfig(whatsappNumber ?? "", "Send this message"),
      width: width,
      alignment: _textToAlignment(align),
      onEdit: () {
        print("Edit config in popup");
      },
      onDelete: () {
        TransactionBuilder(context.editorState)
          ..deleteNode(context.node)
          ..commit();
      },
      onAlign: (alignment) {
        TransactionBuilder(context.editorState)
          ..updateNode(context.node, {
            'align': _alignmentToText(alignment),
          })
          ..commit();
      },
      onResize: (width) {
        TransactionBuilder(context.editorState)
          ..updateNode(context.node, {
            'width': width,
          })
          ..commit();
      },
    );
  }

  @override
  NodeValidator<Node> get nodeValidator => ((node) {
        return node.type == 'whatsapp';
      });

  Alignment _textToAlignment(String text) {
    if (text == 'left') {
      return Alignment.centerLeft;
    } else if (text == 'right') {
      return Alignment.centerRight;
    }
    return Alignment.center;
  }

  String _alignmentToText(Alignment alignment) {
    if (alignment == Alignment.centerLeft) {
      return 'left';
    } else if (alignment == Alignment.centerRight) {
      return 'right';
    }
    return 'center';
  }
}
