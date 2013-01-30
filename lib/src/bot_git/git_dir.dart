part of bot_git;

// TODO: Future<bool> isGitDir

class GitDir {
  static final RegExp _shaRegExp = new RegExp(r'^[a-f0-9]{40}$');

  final Path _path;

  factory GitDir(String path) {
    return new GitDir.fromPath(new Path(path));
  }

  GitDir.fromPath(Path path) :
    this._path = path.canonicalize() {
    assert(new Directory.fromPath(_path).existsSync());
  }

  Path get path => _path;

  Future<List<String>> getBranches() {
    return Git.runGit(['ls-remote', _path.toNativePath()])
        .then((ProcessResult pr) {
          assert(pr.exitCode == 0);

          // TODO: not working *at all* yet.
          return [];
        });
  }

  Future<Map<String, String>> writeObject(List<String> paths) {
    final args = ['hash-object', '-t', 'blob', '-w', '--no-filters', '--'];
    args.addAll(paths);
    return runCommand(args)
        .then((ProcessResult pr) {
          final val = pr.stdout.trim();
          final shas = val.split(new RegExp(r'\s+'));
          assert(shas.length == paths.length);
          assert(shas.every((sha) => _shaRegExp.hasMatch(sha)));
          final map = new Map<String, String>();
          for(var i = 0; i < shas.length; i++) {
            map[paths[i]] = shas[i];
          }
          return map;
        });
  }

  Future<ProcessResult> runCommand(List<String> args, [bool throwOnError = true]) {
    var allArgs = ['--git-dir', _gitDirPath]
      ..addAll(args);
    return Git.runGit(allArgs, throwOnError);
  }

  String get _gitDirPath => _path.append('.git').toNativePath();

  /**
   * [allowContent] if true, doesn't check to see if the directory is empty
   * init will still succeed, even if the directory already has a git repository.
   */
  static Future<GitDir> init(Directory source, {bool allowContent: false}) {
    assert(source.existsSync());

    if(allowContent == true) {
      return _init(source);
    }

    // else, verify it's empty
    return IoHelpers.isEmpty(source)
        .then((bool isEmpty) {
          if(!isEmpty) {
            throw 'source Directory is not empty';
          }
          return _init(source);
        });
  }

  static Future<GitDir> _init(Directory source) {
    return Git.runGit(['init', source.path])
        .then((ProcessResult pr) {
          return new GitDir(source.path);
        });
  }
}