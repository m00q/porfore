import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:porfore/pokelab/red_black_tree.dart';

List<int> validate(TreeSnapshot tree, {bool balanced = true}) {
  final visited = <int>{};
  final values = <int>[];
  int walk(int? id, int? parent, int? min, int? max) {
    if (id == null) return 1;
    expect(visited.add(id), isTrue, reason: 'Cycle or shared child');
    final node = tree.nodes[id]!;
    expect(node.parentId, parent);
    if (min != null) expect(node.value, greaterThan(min));
    if (max != null) expect(node.value, lessThan(max));
    if (balanced && node.color == TreeColor.red) {
      expect(tree.nodes[node.leftId]?.color, isNot(TreeColor.red));
      expect(tree.nodes[node.rightId]?.color, isNot(TreeColor.red));
    }
    final left = walk(node.leftId, id, min, node.value);
    values.add(node.value);
    final right = walk(node.rightId, id, node.value, max);
    if (balanced) expect(left, right, reason: 'Black heights at ${node.value}');
    return left + (node.color == TreeColor.black ? 1 : 0);
  }

  if (balanced && tree.rootId != null) {
    expect(tree.nodes[tree.rootId]!.color, TreeColor.black);
  }
  walk(tree.rootId, null, null, null);
  expect(visited, tree.nodes.keys.toSet());
  return values;
}

Object encode(TreeSnapshot tree) => [
  tree.rootId,
  for (final node in tree.nodes.values)
    [node.id, node.value, node.color, node.parentId, node.leftId, node.rightId],
];

List<TreeStep> finish(TreeOperation operation) {
  final steps = <TreeStep>[];
  TreeStep? step;
  while ((step = operation.nextStep()) != null) {
    steps.add(step!);
    validate(step.snapshot, balanced: false);
    expect(steps.length, lessThan(1000), reason: 'Operation must terminate');
  }
  expect(operation.isComplete, isTrue);
  expect(steps.last.type, TreeStepType.operationComplete);
  expect(
    steps.where((s) => s.type == TreeStepType.operationComplete),
    hasLength(1),
  );
  validate(steps.last.snapshot);
  return steps;
}

Iterable<List<int>> permutations(List<int> values) sync* {
  if (values.isEmpty) {
    yield [];
    return;
  }
  for (final value in values) {
    for (final rest in permutations([...values]..remove(value))) {
      yield [value, ...rest];
    }
  }
}

void main() {
  test('Creation and each pull stop before the next action', () {
    final tree = RedBlackTree();
    final operation = tree.insert(10);
    expect(tree.snapshot.nodes, isEmpty);
    expect(operation.nextStep()!.type, TreeStepType.insertionPointFound);
    expect(tree.snapshot.nodes, isEmpty);
    final inserted = operation.nextStep()!;
    expect(inserted.type, TreeStepType.insert);
    expect(tree.snapshot.nodes.values.single.color, TreeColor.red);
    expect(operation.nextStep()!.type, TreeStepType.checkParentColor);
    expect(tree.snapshot.nodes.values.single.color, TreeColor.red);
    expect(operation.nextStep()!.type, TreeStepType.checkRootColor);
    final recolor = operation.nextStep()!;
    expect(recolor.type, TreeStepType.recolor);
    expect(recolor.oldColor, TreeColor.red);
    expect(recolor.newColor, TreeColor.black);
    expect(inserted.snapshot.nodes.values.single.color, TreeColor.red);
    expect(() => inserted.snapshot.nodes.clear(), throwsUnsupportedError);
    expect(operation.nextStep()!.type, TreeStepType.operationComplete);
    expect(tree.hasActiveOperation, isFalse);
    expect(operation.nextStep(), isNull);
    finish(tree.search(10));
  });

  test('Search steps expose comparisons, directions and outcomes', () {
    final tree = RedBlackTree();
    for (final value in [20, 10, 30]) {
      finish(tree.insert(value));
    }
    final original = encode(tree.snapshot);
    final steps = finish(tree.search(10));
    expect(steps.map((s) => s.type), [
      TreeStepType.visitNode,
      TreeStepType.compare,
      TreeStepType.moveLeft,
      TreeStepType.visitNode,
      TreeStepType.compare,
      TreeStepType.searchComplete,
      TreeStepType.operationComplete,
    ]);
    expect(steps[1].targetValue, 10);
    expect(steps[1].snapshot.nodes[steps[1].nodeId]!.value, 20);
    expect(steps[1].comparison, -1);
    expect(steps[4].comparison, 0);
    expect(steps.last.result, TreeOperationResult.found);
    final missing = finish(tree.search(35));
    expect(
      missing.where((s) => s.type == TreeStepType.moveRight),
      hasLength(2),
    );
    expect(missing.last.result, TreeOperationResult.notFound);
    expect(encode(tree.snapshot), original);
    expect(finish(tree.insert(20)).last.result, TreeOperationResult.duplicate);
    expect(finish(tree.delete(-1)).last.result, TreeOperationResult.notFound);
    expect(encode(tree.snapshot), original);
  });

  test('Empty tree, root removal and operations at integer extremes', () {
    final tree = RedBlackTree();
    expect(finish(tree.search(1)).last.result, TreeOperationResult.notFound);
    expect(finish(tree.delete(1)).last.result, TreeOperationResult.notFound);
    for (final value in [0, -9007199254740991, 9007199254740991]) {
      finish(tree.insert(value));
      expect(
        finish(tree.delete(value)).last.result,
        TreeOperationResult.deleted,
      );
      expect(tree.snapshot.rootId, isNull);
    }
  });

  test('Insertion rotations cover both straight and triangle cases', () {
    for (final values in [
      [3, 2, 1],
      [1, 2, 3],
      [3, 1, 2],
      [1, 3, 2],
    ]) {
      final tree = RedBlackTree();
      final steps = <TreeStep>[];
      for (final value in values) {
        steps.addAll(finish(tree.insert(value)));
      }
      expect(tree.snapshot.nodes[tree.snapshot.rootId]!.value, 2);
      final rotations = steps.where(
        (s) =>
            s.type == TreeStepType.rotateLeft ||
            s.type == TreeStepType.rotateRight,
      );
      expect(rotations.length, values[1] == 2 ? 1 : 2);
      for (final rotation in rotations) {
        expect(
          rotation.snapshot.nodes[rotation.nodeId]!.parentId,
          rotation.relatedNodeId,
        );
      }
    }
  });

  test(
    'Every insertion and deletion permutation of four keys stays balanced',
    () {
      final orders = permutations([1, 2, 3, 4]).toList();
      for (final insertOrder in orders) {
        for (final deleteOrder in orders) {
          final tree = RedBlackTree();
          final expected = <int>{};
          for (final value in insertOrder) {
            finish(tree.insert(value));
            expected.add(value);
            expect(validate(tree.snapshot), expected.toList()..sort());
          }
          for (final value in deleteOrder) {
            finish(tree.delete(value));
            expected.remove(value);
            expect(validate(tree.snapshot), expected.toList()..sort());
          }
        }
      }
    },
  );

  test(
    'Seeded mixed operations match a set and expose deletion repair steps',
    () {
      final types = <TreeStepType>{};
      final deletionRotations = <TreeStepType>{};
      var sawNilGap = false;
      for (var seed = 0; seed < 10; seed++) {
        final random = Random(seed);
        final tree = RedBlackTree();
        final expected = <int>{};
        for (var i = 0; i < 350; i++) {
          final value = random.nextInt(100) - 50;
          final action = random.nextInt(3);
          final TreeOperation operation;
          final TreeOperationResult result;
          if (action == 0) {
            operation = tree.insert(value);
            result = expected.add(value)
                ? TreeOperationResult.inserted
                : TreeOperationResult.duplicate;
          } else if (action == 1) {
            operation = tree.delete(value);
            result = expected.remove(value)
                ? TreeOperationResult.deleted
                : TreeOperationResult.notFound;
          } else {
            operation = tree.search(value);
            result = expected.contains(value)
                ? TreeOperationResult.found
                : TreeOperationResult.notFound;
          }
          final steps = finish(operation);
          expect(steps.last.result, result);
          for (final step in steps) {
            types.add(step.type);
            if (action == 1 &&
                [
                  TreeStepType.rotateLeft,
                  TreeStepType.rotateRight,
                ].contains(step.type)) {
              deletionRotations.add(step.type);
            }
            if (step.type == TreeStepType.doubleBlack && step.nodeId == null) {
              sawNilGap = true;
              expect(step.parentId, isNotNull);
              expect(step.isLeftChild, isNotNull);
            }
          }
          expect(validate(tree.snapshot), expected.toList()..sort());
        }
        for (final value in expected.toList()..shuffle(random)) {
          finish(tree.delete(value));
        }
        expect(tree.snapshot.nodes, isEmpty);
      }
      expect(types, containsAll(TreeStepType.values));
      expect(deletionRotations, {
        TreeStepType.rotateLeft,
        TreeStepType.rotateRight,
      });
      expect(sawNilGap, isTrue);
    },
  );

  test('Cancelling at every boundary restores state and releases the lock', () {
    const initial = [20, 10, 40, 30, 50, 25, 35, 5, 15];
    for (final type in TreeOperationType.values) {
      for (final value in [1, 20, 40, 50, 999]) {
        for (var boundary = 0; ; boundary++) {
          final tree = RedBlackTree();
          for (final key in initial) {
            finish(tree.insert(key));
          }
          final original = encode(tree.snapshot);
          final operation = switch (type) {
            TreeOperationType.insert => tree.insert(value),
            TreeOperationType.search => tree.search(value),
            TreeOperationType.delete => tree.delete(value),
          };
          expect(() => tree.insert(100), throwsStateError);
          expect(() => tree.search(100), throwsStateError);
          expect(() => tree.delete(100), throwsStateError);
          for (var i = 0; i < boundary; i++) {
            operation.nextStep();
          }
          if (operation.isComplete) break;
          operation.cancel();
          operation.cancel();
          expect(operation.isCancelled, isTrue);
          expect(operation.nextStep(), isNull);
          expect(tree.hasActiveOperation, isFalse);
          expect(encode(tree.snapshot), original);
          validate(tree.snapshot);
          finish(tree.insert(100));
        }
      }
    }
  });

  test(
    'Old snapshots and node IDs survive later rotations and replacements',
    () {
      final tree = RedBlackTree();
      for (final value in [20, 10, 40, 30, 50, 25]) {
        finish(tree.insert(value));
      }
      final saved = tree.snapshot;
      final savedEncoding = encode(saved);
      final ids = {for (final node in saved.nodes.values) node.value: node.id};
      finish(tree.delete(20));
      finish(tree.insert(60));
      for (final node in tree.snapshot.nodes.values) {
        if (ids.containsKey(node.value)) expect(node.id, ids[node.value]);
      }
      expect(encode(saved), savedEncoding);
      final cancelled = tree.insert(100);
      TreeStep? step;
      do {
        step = cancelled.nextStep();
      } while (step!.type != TreeStepType.insert);
      final cancelledId = step.nodeId;
      cancelled.cancel();
      final inserted = finish(tree.insert(100))
          .singleWhere((s) => s.type == TreeStepType.insert);
      expect(inserted.nodeId, isNot(cancelledId));
    },
  );
}
