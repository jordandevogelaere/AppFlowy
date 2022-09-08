import 'dart:collection';

import 'package:appflowy_editor/appflowy_editor.dart';

extension ShowWhatsappNode on EditorState {
  void insertWhatsappNode(String initialWhatsappNumber) {
    final selection = service.selectionService.currentSelection.value;
    if (selection == null) {
      return;
    }
    final imageNode = Node(
      type: 'whatsapp',
      children: LinkedList(),
      attributes: {
        'whatsapp_number': initialWhatsappNumber,
        'align': 'center',
      },
    );
    TransactionBuilder(this)
      ..insertNode(
        selection.start.path,
        imageNode,
      )
      ..commit();
  }
}
