import 'tree_step.dart';

export 'tree_step.dart';

/// A pull-driven integer set. Creating an operation does not execute it.
///
/// Only one operation may be active, including searches. Finish it or call
/// [TreeOperation.cancel] before starting another. Every mutation is followed
/// by a yield, so a paused tree never runs ahead of its consumer.
class RedBlackTree {
  RedBlackTree() {
    _nil.left = _nil.right = _nil.parent = _nil;
    _root = _nil;
  }

  final _Node _nil = _Node(0, 0, TreeColor.black);
  late _Node _root;
  int _nextId = 1;
  TreeOperation? _active;

  bool get hasActiveOperation => _active != null;

  TreeSnapshot get snapshot {
    final nodes = <int, TreeNodeSnapshot>{};
    void visit(_Node node) {
      if (node == _nil) return;
      nodes[node.id] = TreeNodeSnapshot(
        id: node.id,
        value: node.value,
        color: node.color,
        parentId: _id(node.parent),
        leftId: _id(node.left),
        rightId: _id(node.right),
      );
      visit(node.left);
      visit(node.right);
    }

    visit(_root);
    return TreeSnapshot(rootId: _id(_root), nodes: nodes);
  }

  TreeOperation insert(int value) => _begin(TreeOperationType.insert, value);
  TreeOperation search(int value) => _begin(TreeOperationType.search, value);
  TreeOperation delete(int value) => _begin(TreeOperationType.delete, value);

  TreeOperation _begin(TreeOperationType type, int value) {
    if (_active != null) {
      throw StateError('Finish or cancel the active tree operation first.');
    }
    final operation = TreeOperation._(this, type, value, snapshot);
    _active = operation;
    operation._iterator = _run(type, value).iterator;
    return operation;
  }

  int? _id(_Node node) => node == _nil ? null : node.id;

  TreeStep _step(
    TreeStepType type,
    String description, {
    _Node? node,
    _Node? related,
    _Node? parent,
    bool? isLeft,
    int? comparison,
    TreeColor? oldColor,
    TreeColor? newColor,
    TreeOperationResult? result,
  }) => TreeStep(
    type: type,
    operation: _active!.type,
    targetValue: _active!.value,
    snapshot: snapshot,
    description: description,
    nodeId: node == null ? null : _id(node),
    relatedNodeId: related == null ? null : _id(related),
    parentId: parent == null ? null : _id(parent),
    isLeftChild: isLeft,
    comparison: comparison,
    oldColor: oldColor,
    newColor: newColor,
    result: result,
  );

  Iterable<TreeStep> _run(TreeOperationType type, int value) sync* {
    var node = _root;
    var parent = _nil;
    var comparison = 0;
    while (node != _nil) {
      yield _step(TreeStepType.visitNode, '현재 노드를 확인합니다.', node: node);
      comparison = value.compareTo(node.value);
      yield _step(
        TreeStepType.compare,
        '대상 값과 현재 노드의 값을 비교합니다.',
        node: node,
        comparison: comparison,
      );
      if (comparison == 0) break;
      parent = node;
      final next = comparison < 0 ? node.left : node.right;
      yield _step(
        comparison < 0 ? TreeStepType.moveLeft : TreeStepType.moveRight,
        comparison < 0 ? '왼쪽 자식으로 이동합니다.' : '오른쪽 자식으로 이동합니다.',
        node: node,
        related: next,
      );
      node = next;
    }

    if (type != TreeOperationType.insert) {
      yield _step(
        TreeStepType.searchComplete,
        node == _nil ? '대상 값을 찾지 못했습니다.' : '대상 값을 찾았습니다.',
        node: node,
        result: node == _nil
            ? TreeOperationResult.notFound
            : TreeOperationResult.found,
      );
    }
    if (type == TreeOperationType.search ||
        (type == TreeOperationType.delete && node == _nil)) {
      yield _complete(
        node == _nil ? TreeOperationResult.notFound : TreeOperationResult.found,
      );
      return;
    }
    if (type == TreeOperationType.insert) {
      if (node != _nil) {
        yield _step(
          TreeStepType.duplicateFound,
          '같은 값이 있어 삽입하지 않습니다.',
          node: node,
        );
        yield _complete(TreeOperationResult.duplicate);
        return;
      }
      yield _step(
        TreeStepType.insertionPointFound,
        '삽입할 위치를 찾았습니다.',
        parent: parent,
        isLeft: parent == _nil ? null : comparison < 0,
      );
      node = _Node(_nextId++, value, TreeColor.red);
      node.left = node.right = _nil;
      node.parent = parent;
      if (parent == _nil) {
        _root = node;
      } else if (comparison < 0) {
        parent.left = node;
      } else {
        parent.right = node;
      }
      yield _step(TreeStepType.insert, '빨간 노드를 삽입합니다.', node: node);
      yield* _fixInsert(node);
      yield _complete(TreeOperationResult.inserted);
    } else {
      yield* _delete(node);
      yield _complete(TreeOperationResult.deleted);
    }
  }

  TreeStep _complete(TreeOperationResult result) =>
      _step(TreeStepType.operationComplete, '연산을 완료했습니다.', result: result);

  Iterable<TreeStep> _recolor(_Node node, TreeColor color) sync* {
    if (node == _nil || node.color == color) return;
    final old = node.color;
    node.color = color;
    yield _step(
      TreeStepType.recolor,
      '노드의 색상을 변경합니다.',
      node: node,
      oldColor: old,
      newColor: color,
    );
  }

  Iterable<TreeStep> _fixInsert(_Node node) sync* {
    while (true) {
      yield _step(
        TreeStepType.checkParentColor,
        '부모의 색상을 확인합니다.',
        node: node,
        related: node.parent,
      );
      if (node.parent.color == TreeColor.black) break;
      var parent = node.parent;
      var grandparent = parent.parent;
      final left = parent == grandparent.left;
      final uncle = left ? grandparent.right : grandparent.left;
      yield _step(
        TreeStepType.checkUncleColor,
        '삼촌의 색상을 확인합니다.',
        node: node,
        related: uncle,
      );
      if (uncle.color == TreeColor.red) {
        yield* _recolor(parent, TreeColor.black);
        yield* _recolor(uncle, TreeColor.black);
        yield* _recolor(grandparent, TreeColor.red);
        node = grandparent;
      } else {
        if (node == (left ? parent.right : parent.left)) {
          node = parent;
          yield _rotate(node, left: left);
        }
        parent = node.parent;
        grandparent = parent.parent;
        yield* _recolor(parent, TreeColor.black);
        yield* _recolor(grandparent, TreeColor.red);
        yield _rotate(grandparent, left: !left);
      }
    }
    yield _step(TreeStepType.checkRootColor, '루트의 색상을 확인합니다.', node: _root);
    yield* _recolor(_root, TreeColor.black);
  }

  TreeStep _rotate(_Node pivot, {required bool left}) {
    final promoted = left ? pivot.right : pivot.left;
    assert(promoted != _nil);
    final inner = left ? promoted.left : promoted.right;
    if (left) {
      pivot.right = inner;
    } else {
      pivot.left = inner;
    }
    if (inner != _nil) inner.parent = pivot;
    promoted.parent = pivot.parent;
    if (pivot.parent == _nil) {
      _root = promoted;
    } else if (pivot == pivot.parent.left) {
      pivot.parent.left = promoted;
    } else {
      pivot.parent.right = promoted;
    }
    if (left) {
      promoted.left = pivot;
    } else {
      promoted.right = pivot;
    }
    pivot.parent = promoted;
    return _step(
      left ? TreeStepType.rotateLeft : TreeStepType.rotateRight,
      left ? '왼쪽으로 회전합니다.' : '오른쪽으로 회전합니다.',
      node: pivot,
      related: promoted,
    );
  }

  void _transplant(_Node old, _Node replacement) {
    if (old.parent == _nil) {
      _root = replacement;
    } else if (old == old.parent.left) {
      old.parent.left = replacement;
    } else {
      old.parent.right = replacement;
    }
    // NIL's parent tracks the deletion gap until fix-up finishes.
    replacement.parent = old.parent;
  }

  Iterable<TreeStep> _delete(_Node target) sync* {
    var removed = target;
    var removedColor = removed.color;
    late _Node gap;
    if (target.left == _nil || target.right == _nil) {
      gap = target.left == _nil ? target.right : target.left;
      _transplant(target, gap);
      yield _step(
        TreeStepType.replaceNode,
        '삭제 대상의 자리를 자식으로 교체합니다.',
        node: target,
        related: gap,
        parent: gap.parent,
      );
    } else {
      yield _step(
        TreeStepType.findSuccessor,
        '오른쪽 서브트리에서 후계자를 찾습니다.',
        node: target,
      );
      removed = target.right;
      yield _step(
        TreeStepType.moveRight,
        '오른쪽 자식으로 이동합니다.',
        node: target,
        related: removed,
      );
      while (true) {
        yield _step(TreeStepType.visitNode, '후계자 후보를 확인합니다.', node: removed);
        if (removed.left == _nil) break;
        yield _step(
          TreeStepType.moveLeft,
          '가장 작은 노드를 향해 왼쪽으로 이동합니다.',
          node: removed,
          related: removed.left,
        );
        removed = removed.left;
      }
      yield _step(TreeStepType.successorFound, '중위 후계자를 찾았습니다.', node: removed);
      removedColor = removed.color;
      gap = removed.right;
      if (removed.parent == target) {
        gap.parent = removed;
      } else {
        _transplant(removed, gap);
        yield _step(
          TreeStepType.replaceNode,
          '후계자의 기존 자리를 오른쪽 자식으로 교체합니다.',
          node: removed,
          related: gap,
          parent: gap.parent,
        );
        removed.right = target.right;
        removed.right.parent = removed;
      }
      _transplant(target, removed);
      removed.left = target.left;
      removed.left.parent = removed;
      yield _step(
        TreeStepType.replaceNode,
        '삭제 대상의 자리를 후계자로 교체합니다.',
        node: target,
        related: removed,
      );
      yield* _recolor(removed, target.color);
    }
    yield _step(TreeStepType.remove, '대상 노드를 제거했습니다.', node: target);
    yield _step(
      TreeStepType.checkRemovedColor,
      '제거된 자리의 원래 색상을 확인합니다.',
      node: removed,
      oldColor: removedColor,
    );
    if (removedColor == TreeColor.black) yield* _fixDelete(gap);
    yield _step(TreeStepType.checkRootColor, '루트의 색상을 확인합니다.', node: _root);
    yield* _recolor(_root, TreeColor.black);
  }

  Iterable<TreeStep> _fixDelete(_Node node) sync* {
    while (node != _root && node.color == TreeColor.black) {
      final parent = node.parent;
      final left = node == parent.left;
      yield _step(
        TreeStepType.doubleBlack,
        '검정 높이 부족을 복구합니다.',
        node: node,
        parent: parent,
        isLeft: left,
      );
      var sibling = left ? parent.right : parent.left;
      yield _step(
        TreeStepType.checkSibling,
        '형제 노드의 색상을 확인합니다.',
        node: node,
        related: sibling,
        parent: parent,
        isLeft: left,
      );
      if (sibling.color == TreeColor.red) {
        yield* _recolor(sibling, TreeColor.black);
        yield* _recolor(parent, TreeColor.red);
        yield _rotate(parent, left: left);
        sibling = left ? parent.right : parent.left;
        yield _step(
          TreeStepType.checkSibling,
          '회전 후 새 형제를 확인합니다.',
          node: node,
          related: sibling,
          parent: parent,
          isLeft: left,
        );
      }
      yield _step(
        TreeStepType.checkNephewColors,
        '형제의 두 자식 색상을 확인합니다.',
        node: sibling,
      );
      if (sibling.left.color == TreeColor.black &&
          sibling.right.color == TreeColor.black) {
        yield* _recolor(sibling, TreeColor.red);
        node = parent;
      } else {
        if ((left ? sibling.right : sibling.left).color == TreeColor.black) {
          yield* _recolor(left ? sibling.left : sibling.right, TreeColor.black);
          yield* _recolor(sibling, TreeColor.red);
          yield _rotate(sibling, left: !left);
          sibling = left ? parent.right : parent.left;
          yield _step(
            TreeStepType.checkSibling,
            '회전 후 새 형제를 확인합니다.',
            node: node,
            related: sibling,
            parent: parent,
            isLeft: left,
          );
          yield _step(
            TreeStepType.checkNephewColors,
            '회전 후 형제의 자식 색상을 확인합니다.',
            node: sibling,
          );
        }
        yield* _recolor(sibling, parent.color);
        yield* _recolor(parent, TreeColor.black);
        yield* _recolor(left ? sibling.right : sibling.left, TreeColor.black);
        yield _rotate(parent, left: left);
        node = _root;
      }
    }
    yield* _recolor(node, TreeColor.black);
    yield _step(
      TreeStepType.resolveDoubleBlack,
      '검정 높이 복구를 마쳤습니다.',
      node: node,
    );
  }

  void _restore(TreeSnapshot initial) {
    final nodes = <int, _Node>{
      for (final node in initial.nodes.values)
        node.id: _Node(node.id, node.value, node.color),
    };
    for (final saved in initial.nodes.values) {
      final node = nodes[saved.id]!;
      node.parent = nodes[saved.parentId] ?? _nil;
      node.left = nodes[saved.leftId] ?? _nil;
      node.right = nodes[saved.rightId] ?? _nil;
    }
    _root = nodes[initial.rootId] ?? _nil;
    _nil.parent = _nil;
    _active = null;
  }
}

/// Single-use cursor. The consumer decides when to request each next step.
class TreeOperation {
  TreeOperation._(this._tree, this.type, this.value, this.initialSnapshot);

  final RedBlackTree _tree;
  final TreeOperationType type;
  final int value;
  final TreeSnapshot initialSnapshot;
  Iterator<TreeStep>? _iterator;
  bool _isComplete = false;
  bool _isCancelled = false;

  bool get isComplete => _isComplete;
  bool get isCancelled => _isCancelled;

  /// Returns exactly one step; returns null after completion or cancellation.
  /// The final operationComplete step releases the tree immediately.
  TreeStep? nextStep() {
    if (_isComplete || _isCancelled) return null;
    try {
      if (!_iterator!.moveNext()) {
        throw StateError('Operation ended without an operationComplete step.');
      }
      final step = _iterator!.current;
      if (step.type == TreeStepType.operationComplete) {
        _isComplete = true;
        _tree._nil.parent = _tree._nil;
        _tree._active = null;
        _iterator = null;
      }
      return step;
    } catch (_) {
      cancel();
      rethrow;
    }
  }

  /// Abandons remaining steps and restores the tree before this operation.
  /// The consumer should render initialSnapshot after cancelling.
  /// IDs allocated by cancelled insertions are never reused.
  void cancel() {
    if (_isComplete || _isCancelled) return;
    _tree._restore(initialSnapshot);
    _iterator = null;
    _isCancelled = true;
  }
}

class _Node {
  _Node(this.id, this.value, this.color);

  final int id;
  final int value;
  TreeColor color;
  late _Node parent;
  late _Node left;
  late _Node right;
}
