/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import 'delete.dart';
import 'is.dart';
import 'touch.dart';
import 'utility.dart';
import 'verbose.dart';

/// Opens a File and calls [action] passing in the open file.
/// When action completes the file is closed.
/// Use this method in preference to directly callling [FileSync()]
Future<R> withOpenFile<R>(
  String pathToFile,
  R Function(RandomAccessFile) action, {
  FileMode fileMode = FileMode.writeOnlyAppend,
}) async {
  final raf = File(pathToFile).openSync(mode: fileMode);

  R result;
  try {
    result = action(raf);
  } finally {
    await raf.close();
  }
  return result;
}

///
/// Creates a link at [linkPath] which points to an
/// existing file or directory at [existingPath]
///
/// On Windows you need to be in developer mode or running as an Administrator
/// to create a symlink.
///
/// To enable developer mode see:
/// https://dcli.onepub.dev/getting-started/installing-on-windows
///
/// To check if your script is running as an administrator use:
///
/// [Shell.current.isPrivileged]
///
Future<void> symlink(
  String existingPath,
  String linkPath,
) async {
  verbose(() => 'symlink existingPath: $existingPath linkPath $linkPath');
  await Link(linkPath).create(existingPath);
}

///
/// Deletes the symlink at [linkPath]
///
/// On Windows you need to be in developer mode or running as an Administrator
/// to delete a symlink.
///
/// To enable developer mode see:
/// https://dcli.onepub.dev/getting-started/installing-on-windows
///
/// To check if your script is running as an administrator use:
///
/// [Shell.current.isPrivileged]
///
Future<void> deleteSymlink(String linkPath) async {
  verbose(() => 'deleteSymlink linkPath: $linkPath');
  await Link(linkPath).delete();
}

///
/// Resolves the a symbolic link [pathToLink]
/// to the ultimate target path.
///
/// The return path will be canonicalized.
///
/// e.g.
/// ```dart
/// resolveSymLink('/usr/bin/dart) == '/usr/lib/bin/dart'
/// ```
///
/// throws a FileSystemException if the target path does not exist.
Future<String> resolveSymLink(String pathToLink) async {
  final normalised = canonicalize(pathToLink);

  String resolved;
  if (isDirectory(normalised)) {
    resolved = Directory(normalised).resolveSymbolicLinksSync();
  } else {
    resolved = canonicalize(File(normalised).resolveSymbolicLinksSync());
  }

  verbose(() => 'resolveSymLink $pathToLink resolved: $resolved');
  return resolved;
}

///
///
/// Returns a FileStat instance describing the
/// file or directory located by [path].
///
FileStat stat(String path) => File(path).statSync();

/// Generates a temporary filename in [pathToTempDir]
/// or if inTempDir os not passed then in
/// the system temp directory.
/// The generated filename is is guaranteed to be globally unique.
///
/// This method does NOT create the file.
///
/// The temp file name will be <uuid>.tmp
/// unless you provide a [suffix] in which
/// case the file name will be <uuid>.<suffix>
String createTempFilename({String? suffix, String? pathToTempDir}) {
  var finalsuffix = suffix ?? 'tmp';

  if (!finalsuffix.startsWith('.')) {
    finalsuffix = '.$finalsuffix';
  }
  pathToTempDir ??= Directory.systemTemp.path;
  const uuid = Uuid();
  return '${join(pathToTempDir, uuid.v4())}$finalsuffix';
}

/// Generates a temporary filename in the system temp directory
/// that is guaranteed to be unique.
///
/// This method does not create the file.
///
/// The temp file name will be <uuid>.tmp
/// unless you provide a [suffix] in which
/// case the file name will be <uuid>.<suffix>
Future<String> createTempFile({String? suffix}) async {
  final filename = createTempFilename(suffix: suffix);
  touch(filename, create: true);
  return filename;
}

/// Returns the length of the file at [pathToFile] in bytes.
Future<int> fileLength(String pathToFile) => File(pathToFile).length();

/// Creates a temp file and then calls [action].
///
/// Once [action] completes the temporary file will be deleted.
///
/// The [action]s return value [R] is returned from the [withTempFile]
/// function.
///
/// If [create] is true (default true) then the temp file will be
/// created. If [create] is false then just the name will be
/// generated.
///
/// if [pathToTempDir] is passed then the file will be created in that
/// directory otherwise the file will be created in the system
/// temp directory.
///
/// The temp file name will be <uuid>.tmp
/// unless you provide a [suffix] in which
/// case the file name will be <uuid>.<suffix>
Future<R> withTempFile<R>(
  Future<R> Function(String tempFile) action, {
  String? suffix,
  String? pathToTempDir,
  bool create = true,
  bool keep = false,
}) async {
  final tmp = createTempFilename(suffix: suffix, pathToTempDir: pathToTempDir);
  if (create) {
    touch(tmp, create: true);
  }

  R result;
  try {
    result = await action(tmp);
  } finally {
    if (exists(tmp) && !keep) {
      delete(tmp);
    }
  }
  return result;
}

/// Thrown when a file doesn't exist
class FileNotFoundException extends DCliException {
  /// Thrown when a file doesn't exist
  FileNotFoundException(String path)
      : super('The file ${truepath(path)} does not exist.');
}

/// Thrown when a path is not a file.
class NotAFileException extends DCliException {
  /// Thrown when a path is not a file.
  NotAFileException(String path)
      : super('The path ${truepath(path)} is not a file.');
}
