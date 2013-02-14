part of test_hop;

void registerArgTests() {
  group('task arguments', () {
    test('simple args', () {

      final task = _makeSimpleTask();
      _testTask(task, (RunResult result) {
        expect(result, RunResult.SUCCESS);
      }, extraArgs: ['hello', 'args']);
    });
  });
}


Task _makeSimpleTask() {
  return new Task.sync((ctx) {
    final args = ctx.arguments.rest;
    expect(args.length, 2);
    expect(args[0], 'hello');
    expect(args[1], 'args');
    return true;
  });
}

void _testTask(Task sourceTask, Action1<RunResult> completeHandler, {List<String> extraArgs}) {
  final name = 'task_name';
  final tasks = new BaseConfig();
  tasks.addTask(name, sourceTask);
  tasks.freeze();

  final args = [name];
  if(extraArgs != null) {
    args.addAll(extraArgs);
  }

  final runner = new TestRunner(tasks, args);
  runner.run().then(expectAsync1(completeHandler));
}
