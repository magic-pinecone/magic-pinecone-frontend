import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:git_hooks/git_hooks.dart';

Future<void> main(List<String> arguments) async {
  final params = <Git, UserBackFun>{
    Git.commitMsg: commitMsg,
    Git.preCommit: preCommit,
  };

  if (arguments.isEmpty) {
    final passed = await preCommit();
    if (!passed) {
      exit(1);
    }
    return;
  }

  GitHooks.call(arguments, params);
}

Future<bool> commitMsg() async {
  return true;
}

Future<bool> preCommit() async {
  final checks = [
    _Check('format', ['dart', 'format', '--set-exit-if-changed', '.']),
    _Check('analyze', ['flutter', 'analyze', '--fatal-infos']),
    _Check('test', ['flutter', 'test']),
  ];

  for (final check in checks) {
    final exitCode = await _run(check);
    if (exitCode != 0) {
      return false;
    }
  }
  return true;
}

Future<int> _run(_Check check) async {
  stdout.writeln('Running ${check.name}...');
  final process = await Process.start(
    check.command.first,
    check.command.skip(1).toList(growable: false),
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}

class _Check {
  const _Check(this.name, this.command);

  final String name;
  final List<String> command;
}
