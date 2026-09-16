/// Algorithm vocabulary, independent of widgets, timers and animations.
enum TreeStepType {
  visitNode,
  compare,
  moveLeft,
  moveRight,
  insertionPointFound,
  insert,
  duplicateFound,
  checkParentColor,
  checkUncleColor,
  recolor,
  rotateLeft,
  rotateRight,
  searchComplete,
  findSuccessor,
  successorFound,
  replaceNode,
  remove,
  checkRemovedColor,
  doubleBlack,
  checkSibling,
  checkNephewColors,
  resolveDoubleBlack,
  checkRootColor,
  operationComplete,
}

enum TreeColor { red, black }

enum TreeOperationType { insert, search, delete }

enum TreeOperationResult { inserted, duplicate, found, notFound, deleted }

/// Stable IDs distinguish a node's identity from its position in the tree.
class TreeNodeSnapshot {
  const TreeNodeSnapshot({
    required this.id,
    required this.value,
    required this.color,
    required this.parentId,
    required this.leftId,
    required this.rightId,
  });

  final int id;
  final int value;
  final TreeColor color;
  final int? parentId;
  final int? leftId;
  final int? rightId;
}

/// Null links represent black NIL leaves. No mutable nodes escape the tree.
class TreeSnapshot {
  TreeSnapshot({
    required this.rootId,
    required Map<int, TreeNodeSnapshot> nodes,
  }) : nodes = Map.unmodifiable(nodes);

  final int? rootId;
  final Map<int, TreeNodeSnapshot> nodes;
}

/// A completed micro-step and the tree immediately after it.
///
/// [nodeId] is the focus; [relatedNodeId] is the other participant (possibly
/// NIL). Comparison events include [targetValue], the focused node's value in
/// [snapshot], and the comparator's [comparison] (-1, 0, 1).
///
/// For a NIL double-black focus, [parentId] and [isLeftChild] identify its edge.
/// Snapshots can temporarily violate RB invariants during fix-up. Retain the
/// operation's initial snapshot and emitted steps for visual replay; replay
/// does not rewind or mutate the live tree.
class TreeStep {
  const TreeStep({
    required this.type,
    required this.operation,
    required this.targetValue,
    required this.snapshot,
    required this.description,
    this.nodeId,
    this.relatedNodeId,
    this.parentId,
    this.isLeftChild,
    this.comparison,
    this.oldColor,
    this.newColor,
    this.result,
  });

  final TreeStepType type;
  final TreeOperationType operation;
  final int targetValue;
  final TreeSnapshot snapshot;
  final String description;
  final int? nodeId;
  final int? relatedNodeId;
  final int? parentId;
  final bool? isLeftChild;
  final int? comparison;
  final TreeColor? oldColor;
  final TreeColor? newColor;
  final TreeOperationResult? result;
}
