import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:posix/posix.dart';
import 'package:posix/src/string/string.dart';
import 'package:posix/src/util/conversions.dart';

import '../libc.dart';

/// Test for access to NAME using the real UID and real GID.
int access(
  String name, // ffi.Pointer<Utf8> name,
  int type,
) {
  _access ??= Libc().dylib.lookupFunction<_c_access, _dart_access>('access');

  var c_name = name.toNativeUtf8();
  var result = _access!(
    c_name,
    type,
  );

  malloc.free(c_name);

  return result;
}

_dart_access? _access;

/// Test for access to FILE relative to the directory FD is open on.
/// If AT_EACCESS is set in FLAG, then use effective IDs like `eaccess',
/// otherwise use real IDs like `access'.
int faccessat(
  int fd,
  String filename, // ffi.Pointer<Utf8> file,
  int type,
  int flag,
) {
  _faccessat ??=
      Libc().dylib.lookupFunction<_c_faccessat, _dart_faccessat>('faccessat');

  var c_filename = filename.toNativeUtf8();
  var result = _faccessat!(
    fd,
    c_filename,
    type,
    flag,
  );

  malloc.free(c_filename);

  return result;
}

_dart_faccessat? _faccessat;

int lseek(
  int fd,
  int offset,
  int whence,
) {
  _lseek ??= Libc().dylib.lookupFunction<_c_lseek, _dart_lseek>('lseek');
  return _lseek!(
    fd,
    offset,
    whence,
  );
}

_dart_lseek? _lseek;

/// Close the file descriptor FD.
///
/// This function is a cancellation point and therefore not marked with
/// __THROW.
int close(
  int fd,
) {
  _close ??= Libc().dylib.lookupFunction<_c_close, _dart_close>('close');
  return _close!(
    fd,
  );
}

_dart_close? _close;

/// Read NBYTES  from FD.  Returning the bytes read.
///
/// The returned array will be empty if EOF was reached.
///
/// Throws a [PosixException] if an error occurs.
///
/// This function is a cancellation point and therefore not marked with
/// __THROW.
List<int> read(
  int fd,
  int nbytes,
) {
  var c_buf = malloc.allocate<ffi.Int8>(nbytes);

  _read ??= Libc().dylib.lookupFunction<_c_read, _dart_read>('read');
  var result = _read!(
    fd,
    c_buf,
    nbytes,
  );

  _throwIfErrno('read', result, c_buf);

  var buf = c_buf.asTypedList(result);
  malloc.free(c_buf);

  return buf;
}

_dart_read? _read;

/// Writes [buf] to FD.  Return the number of bytes written;
///
/// Throws a [PosixException] if an error occurs.
///
int write(
  int fd,
  List<int> buf, // ffi.Pointer<ffi.Void> buf,
) {
  var c_buf = copyDartListToCBuff(buf);

  _write ??= Libc().dylib.lookupFunction<_c_write, _dart_write>('write');
  var written = _write!(
    fd,
    c_buf,
    buf.length,
  );

  _throwIfErrno('pwrite', written, c_buf);

  malloc.free(c_buf);

  return written;
}

_dart_write? _write;

/// Read NBYTES and returns 'nbytes' from FD at the given position OFFSET without
/// changing the file pointer.
///
/// Returns a List<int> with the results. The length of the array will be
/// the number of bytes read which may be less than 'nbytes' if we hit the
/// end of the file when reading.
///
/// Throws: [PosixException] if an error occurs reading the data.
List<int> pread(
  int fd,
  int nbytes,
  int offset,
) {
  var c_buf = malloc.allocate<ffi.Int8>(nbytes);
  _pread ??= Libc().dylib.lookupFunction<_c_pread, _dart_pread>('pread');
  var read = _pread!(
    fd,
    c_buf,
    nbytes,
    offset,
  );

  _throwIfErrno('pread', read, c_buf);

  var buf = c_buf.asTypedList(read);
  malloc.free(c_buf);

  return buf;
}

_dart_pread? _pread;

/// Write N bytes of BUF to FD at the given position OFFSET without
/// changing the file pointer.  Return the number of bytes written
///
/// Throws a [PosixException] if an error occurs.
int pwrite(
  int fd,
  List<int> buf, // ffi.Pointer<ffi.Void> buf,
  int offset,
) {
  var c_buf = copyDartListToCBuff(buf);

  _pwrite ??= Libc().dylib.lookupFunction<_c_pwrite, _dart_pwrite>('pwrite');
  var written = _pwrite!(
    fd,
    c_buf,
    buf.length,
    offset,
  );

  _throwIfErrno('pwrite', written, c_buf);

  malloc.free(c_buf);

  return written;
}

_dart_pwrite? _pwrite;

/// Create a one-way communication channel (pipe).
/// If successful, two file descriptors are stored in PIPEDES;
/// bytes written on PIPEDES[1] can be read from PIPEDES[0].
/// Returns 0 if successful, -1 if not.
List<int> native_pipe(
  ffi.Pointer<ffi.Int32> __pipedes,
) {
  var c_pipedes = malloc.allocate<ffi.Int32>(2);
  _pipe ??= Libc().dylib.lookupFunction<_c_pipe, _dart_pipe>('pipe');
  var result = _pipe!(
    c_pipedes,
  );

  _throwIfErrno('pipe', result, c_pipedes);

  var pipedes = c_pipedes.asTypedList(2);

  malloc.free(c_pipedes);

  return pipedes;
}

_dart_pipe? _pipe;

/// Schedule an alarm.  In SECONDS seconds, the process will get a SIGALRM.
/// If SECONDS is zero, any currently scheduled alarm will be cancelled.
/// The function returns the number of seconds remaining until the last
/// alarm scheduled would have signaled, or zero if there wasn't one.
/// There is no return value to indicate an error, but you can set `errno'
/// to 0 and check its value after calling `alarm', and this might tell you.
/// The signal may come late due to processor scheduling.
int alarm(
  int seconds,
) {
  clear_errno();
  _alarm ??= Libc().dylib.lookupFunction<_c_alarm, _dart_alarm>('alarm');
  return _alarm!(
    seconds,
  );
}

_dart_alarm? _alarm;

/// Make the process sleep for SECONDS seconds, or until a signal arrives
/// and is not ignored.  The function returns the number of seconds less
/// than SECONDS which it actually slept (thus zero if it slept the full time).
/// If a signal handler does a `longjmp' or modifies the handling of the
/// SIGALRM signal while inside `sleep' call, the handling of the SIGALRM
/// signal afterwards is undefined.  There is no return value to indicate
/// error, but if `sleep' returns SECONDS, it probably didn't work.
///
/// This function is a cancellation point and therefore not marked with
/// __THROW.
int sleep(
  int seconds,
) {
  _sleep ??= Libc().dylib.lookupFunction<_c_sleep, _dart_sleep>('sleep');
  return _sleep!(
    seconds,
  );
}

_dart_sleep? _sleep;

/// Set an alarm to go off (generating a SIGALRM signal) in VALUE
/// microseconds.  If INTERVAL is nonzero, when the alarm goes off, the
/// timer is reset to go off every INTERVAL microseconds thereafter.
/// Returns the number of microseconds remaining before the alarm.
int ualarm(
  int value,
  int interval,
) {
  _ualarm ??= Libc().dylib.lookupFunction<_c_ualarm, _dart_ualarm>('ualarm');
  return _ualarm!(
    value,
    interval,
  );
}

_dart_ualarm? _ualarm;

/// Sleep USECONDS microseconds, or until a signal arrives that is not blocked
/// or ignored.
///
/// This function is a cancellation point and therefore not marked with
/// __THROW.
int usleep(
  int useconds,
) {
  _usleep ??= Libc().dylib.lookupFunction<_c_usleep, _dart_usleep>('usleep');
  return _usleep!(
    useconds,
  );
}

_dart_usleep? _usleep;

/// Suspend the process until a signal arrives.
/// This always returns -1 and sets `errno' to EINTR.
///
/// This function is a cancellation point and therefore not marked with
/// __THROW.
int pause() {
  _pause ??= Libc().dylib.lookupFunction<_c_pause, _dart_pause>('pause');
  return _pause!();
}

_dart_pause? _pause;

/// Change the owner and group of FILE.
///
/// If the owner or group is specified as -1, then that ID is not
/// changed.
///
/// If the call fails a [PosixException] is thrown with the value of
/// errno.
void chown(
  String filename,
  int owner,
  int group,
) {
  var c_filename = filename.toNativeUtf8();

  clear_errno();

  _chown ??= Libc().dylib.lookupFunction<_c_chown, _dart_chown>('chown');
  var results = _chown!(
    c_filename,
    owner,
    group,
  );
  malloc.free(c_filename);

  if (results != 0) {
    final error = errno();
    throw PosixException('chmod failed error: ${strerror(error)}', error);
  }
}

_dart_chown? _chown;

/// Change the owner and group of the file that FD is open on.
int fchown(
  int fd,
  int owner,
  int group,
) {
  _fchown ??= Libc().dylib.lookupFunction<_c_fchown, _dart_fchown>('fchown');
  return _fchown!(
    fd,
    owner,
    group,
  );
}

_dart_fchown? _fchown;

/// Change owner and group of FILE, if it is a symbolic
/// link the ownership of the symbolic link is changed.
int lchown(
  String filename, // ffi.Pointer<Utf8> file,
  int owner,
  int group,
) {
  var c_filename = filename.toNativeUtf8();

  _lchown ??= Libc().dylib.lookupFunction<_c_lchown, _dart_lchown>('lchown');
  var result = _lchown!(
    c_filename,
    owner,
    group,
  );

  malloc.free(c_filename);
  return result;
}

_dart_lchown? _lchown;

/// Change the owner and group of FILE relative to the directory FD is open
/// on.
int fchownat(
  int fd,
  String filename, // ffi.Pointer<Utf8> file,
  int owner,
  int group,
  int flag,
) {
  _fchownat ??=
      Libc().dylib.lookupFunction<_c_fchownat, _dart_fchownat>('fchownat');

  var c_filename = filename.toNativeUtf8();
  var result = _fchownat!(
    fd,
    c_filename,
    owner,
    group,
    flag,
  );

  malloc.free(c_filename);
  return result;
}

_dart_fchownat? _fchownat;

/// Change the process's working directory to PATH.
int chdir(String path // ffi.Pointer<Utf8> __path,
    ) {
  var c_path = path.toNativeUtf8();
  _chdir ??= Libc().dylib.lookupFunction<_c_chdir, _dart_chdir>('chdir');
  var result = _chdir!(
    c_path,
  );

  malloc.free(c_path);
  return result;
}

_dart_chdir? _chdir;

/// Change the process's working directory to the one FD is open on.
int fchdir(
  int fd,
) {
  _fchdir ??= Libc().dylib.lookupFunction<_c_fchdir, _dart_fchdir>('fchdir');
  return _fchdir!(
    fd,
  );
}

_dart_fchdir? _fchdir;

/// Get the pathname of the current working directory,
/// and put it in SIZE bytes of BUF.  Returns NULL if the
/// directory couldn't be determined or SIZE was too small.
/// If successful, returns BUF.  In GNU, if BUF is NULL,
/// an array is allocated with `malloc'; the array is SIZE
/// bytes long, unless SIZE == 0, in which case it is as
/// big as necessary.
ffi.Pointer<ffi.Int8> native_getcwd(
  ffi.Pointer<ffi.Int8> buf,
  int size,
) {
  _getcwd ??= Libc().dylib.lookupFunction<_c_getcwd, _dart_getcwd>('getcwd');
  return _getcwd!(
    buf,
    size,
  );
}

_dart_getcwd? _getcwd;

/// Put the absolute pathname of the current working directory in BUF.
/// If successful, return BUF.  If not, put an error message in
/// BUF and return NULL.  BUF should be at least PATH_MAX bytes long.
ffi.Pointer<ffi.Int8> native_getwd(ffi.Pointer<ffi.Int8> buf) {
  _getwd ??= Libc().dylib.lookupFunction<_c_getwd, _dart_getwd>('getwd');
  return _getwd!(
    buf,
  );
}

_dart_getwd? _getwd;

/// Duplicate FD, returning a new file descriptor on the same file.
int dup(
  int fd,
) {
  _dup ??= Libc().dylib.lookupFunction<_c_dup, _dart_dup>('dup');
  return _dup!(
    fd,
  );
}

_dart_dup? _dup;

/// Duplicate FD to FD2, closing FD2 and making it open on the same file.
int dup2(
  int fd,
  int fd2,
) {
  _dup2 ??= Libc().dylib.lookupFunction<_c_dup2, _dart_dup2>('dup2');
  return _dup2!(
    fd,
    fd2,
  );
}

_dart_dup2? _dup2;

/// Replace the current process, executing PATH with arguments ARGV and
/// environment ENVP.  ARGV and ENVP are terminated by NULL pointers.
int native_execve(
  String path, // ffi.Pointer<Utf8> __path,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
  ffi.Pointer<ffi.Pointer<Utf8>> __envp,
) {
  var c_path = path.toNativeUtf8();

  _execve ??= Libc().dylib.lookupFunction<_c_execve, _dart_execve>('execve');
  var result = _execve!(
    c_path,
    __argv,
    __envp,
  );

  malloc.free(c_path);

  return result;
}

_dart_execve? _execve;

/// Execute the file FD refers to, overlaying the running program image.
/// ARGV and ENVP are passed to the new program, as for `execve'.
int native_fexecve(
  int fd,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
  ffi.Pointer<ffi.Pointer<Utf8>> __envp,
) {
  _fexecve ??=
      Libc().dylib.lookupFunction<_c_fexecve, _dart_fexecve>('fexecve');
  return _fexecve!(
    fd,
    __argv,
    __envp,
  );
}

_dart_fexecve? _fexecve;

/// Execute PATH with arguments ARGV and environment from `environ'.
int native_execv(
  String path, // ffi.Pointer<Utf8> __path,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
) {
  var c_path = path.toNativeUtf8();

  _execv ??= Libc().dylib.lookupFunction<_c_execv, _dart_execv>('execv');
  var result = _execv!(
    c_path,
    __argv,
  );

  malloc.free(c_path);

  return result;
}

_dart_execv? _execv;

/// Execute PATH with all arguments after PATH until a NULL pointer,
/// and the argument after that for environment.
int execle(
  String path, // ffi.Pointer<Utf8> __path,
  String arg, // ffi.Pointer<Utf8> __arg,
) {
  var c_path = path.toNativeUtf8();

  var c_arg = arg.toNativeUtf8();

  _execle ??= Libc().dylib.lookupFunction<_c_execle, _dart_execle>('execle');
  var result = _execle!(
    c_path,
    c_arg,
  );

  malloc.free(c_path);
  malloc.free(c_arg);

  return result;
}

_dart_execle? _execle;

/// Execute PATH with all arguments after PATH until
/// a NULL pointer and environment from `environ'.
int execl(
  String path, // ffi.Pointer<Utf8> __path,
  String arg, // ffi.Pointer<Utf8> __arg,
) {
  var c_path = path.toNativeUtf8();

  var c_arg = arg.toNativeUtf8();

  _execl ??= Libc().dylib.lookupFunction<_c_execl, _dart_execl>('execl');
  var result = _execl!(
    c_path,
    c_arg,
  );

  malloc.free(c_path);
  malloc.free(c_arg);

  return result;
}

_dart_execl? _execl;

/// Execute FILE, searching in the `PATH' environment variable if it contains
/// no slashes, with arguments ARGV and environment from `environ'.
int native_execvp(
  String file, // ffi.Pointer<Utf8> file,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
) {
  var c_file = file.toNativeUtf8();

  _execvp ??= Libc().dylib.lookupFunction<_c_execvp, _dart_execvp>('execvp');
  var result = _execvp!(
    c_file,
    __argv,
  );

  malloc.free(c_file);

  return result;
}

_dart_execvp? _execvp;

/// Execute FILE, searching in the `PATH' environment variable if
/// it contains no slashes, with all arguments after FILE until a
/// NULL pointer and environment from `environ'.
int execlp(
  String file, // ffi.Pointer<Utf8> file,
  String arg, // ffi.Pointer<Utf8> __arg,
) {
  var c_file = file.toNativeUtf8();

  var c_arg = arg.toNativeUtf8();

  _execlp ??= Libc().dylib.lookupFunction<_c_execlp, _dart_execlp>('execlp');
  var result = _execlp!(
    c_file,
    c_arg,
  );
  malloc.free(c_file);
  malloc.free(c_arg);

  return result;
}

_dart_execlp? _execlp;

/// Add [increment]] to priority of the current process
/// and returns the new process priority.
int nice(
  int increment,
) {
  _nice ??= Libc().dylib.lookupFunction<_c_nice, _dart_nice>('nice');
  return _nice!(
    increment,
  );
}

_dart_nice? _nice;

/// Terminate program execution with the low-order 8 bits of STATUS.
void exit(
  int status,
) {
  __exit ??= Libc().dylib.lookupFunction<_c__exit, _dart__exit>('_exit');
  return __exit!(
    status,
  );
}

_dart__exit? __exit;

/// Get file-specific configuration information about PATH.
int pathconf(
  String path, // ffi.Pointer<Utf8> __path,
  int name,
) {
  var c_path = path.toNativeUtf8();
  _pathconf ??=
      Libc().dylib.lookupFunction<_c_pathconf, _dart_pathconf>('pathconf');
  var result = _pathconf!(
    c_path,
    name,
  );

  malloc.free(c_path);
  return result;
}

_dart_pathconf? _pathconf;

/// Get file-specific configuration about descriptor FD.
int fpathconf(
  int fd,
  int name,
) {
  _fpathconf ??=
      Libc().dylib.lookupFunction<_c_fpathconf, _dart_fpathconf>('fpathconf');
  return _fpathconf!(
    fd,
    name,
  );
}

_dart_fpathconf? _fpathconf;

/// Get the value of the system variable NAME.
int sysconf(
  int name,
) {
  _sysconf ??=
      Libc().dylib.lookupFunction<_c_sysconf, _dart_sysconf>('sysconf');
  return _sysconf!(
    name,
  );
}

_dart_sysconf? _sysconf;

/// Get the value of the string-valued system variable NAME.
String confstr(
  int name,
) {
  _confstr ??=
      Libc().dylib.lookupFunction<_c_confstr, _dart_confstr>('confstr');
  var len = _confstr!(
    name,
    ffi.nullptr,
    0,
  );

  if (len == 0) {
    throw PosixException(strerror(errno()), errno());
  }

  var c_buf = malloc.allocate<ffi.Void>(len);

  var result = _confstr!(
    name,
    c_buf,
    len,
  );

  if (result == 0) {
    throw PosixException(strerror(errno()), errno());
  }

  return copyCBuffToDartString(c_buf);
}

_dart_confstr? _confstr;

/// Get the process ID of the calling process.
int getpid() {
  _getpid ??= Libc().dylib.lookupFunction<_c_getpid, _dart_getpid>('getpid');
  return _getpid!();
}

_dart_getpid? _getpid;

/// Get the process ID of the calling process's parent.
int getppid() {
  _getppid ??=
      Libc().dylib.lookupFunction<_c_getppid, _dart_getppid>('getppid');
  return _getppid!();
}

_dart_getppid? _getppid;

/// Get the process group ID of the calling process.
int getpgrp() {
  _getpgrp ??=
      Libc().dylib.lookupFunction<_c_getpgrp, _dart_getpgrp>('getpgrp');
  return _getpgrp!();
}

_dart_getpgrp? _getpgrp;

int getpgid(
  int pid,
) {
  _getpgid ??=
      Libc().dylib.lookupFunction<_c_getpgid, _dart_getpgid>('getpgid');
  return _getpgid!(
    pid,
  );
}

_dart_getpgid? _getpgid;

/// Set the process group ID of the process matching PID to PGID.
/// If PID is zero, the current process's process group ID is set.
/// If PGID is zero, the process ID of the process is used.
int setpgid(
  int pid,
  int pgid,
) {
  _setpgid ??=
      Libc().dylib.lookupFunction<_c_setpgid, _dart_setpgid>('setpgid');
  return _setpgid!(
    pid,
    pgid,
  );
}

_dart_setpgid? _setpgid;

/// Set the process group ID of the calling process to its own PID.
/// This is exactly the same as `setpgid (0, 0)'.
int setpgrp() {
  _setpgrp ??=
      Libc().dylib.lookupFunction<_c_setpgrp, _dart_setpgrp>('setpgrp');
  return _setpgrp!();
}

_dart_setpgrp? _setpgrp;

/// Create a new session with the calling process as its leader.
/// The process group IDs of the session and the calling process
/// are set to the process ID of the calling process, which is returned.
int setsid() {
  _setsid ??= Libc().dylib.lookupFunction<_c_setsid, _dart_setsid>('setsid');
  return _setsid!();
}

_dart_setsid? _setsid;

/// Return the session ID of the given process.
int native_getsid(
  int pid,
) {
  _getsid ??= Libc().dylib.lookupFunction<_c_getsid, _dart_getsid>('getsid');
  return _getsid!(
    pid,
  );
}

_dart_getsid? _getsid;

/// Get the real user ID of the calling process.
int getuid() {
  _getuid ??= Libc().dylib.lookupFunction<_c_getuid, _dart_getuid>('getuid');
  return _getuid!();
}

_dart_getuid? _getuid;

/// Get the effective user ID of the calling process.
int geteuid() {
  _geteuid ??=
      Libc().dylib.lookupFunction<_c_geteuid, _dart_geteuid>('geteuid');
  return _geteuid!();
}

_dart_geteuid? _geteuid;

/// Get the real group ID of the calling process.
int getgid() {
  _getgid ??= Libc().dylib.lookupFunction<_c_getgid, _dart_getgid>('getgid');
  return _getgid!();
}

_dart_getgid? _getgid;

/// Get the effective group ID of the calling process.
int getegid() {
  _getegid ??=
      Libc().dylib.lookupFunction<_c_getegid, _dart_getegid>('getegid');
  return _getegid!();
}

_dart_getegid? _getegid;

/// If SIZE is zero, return the number of supplementary groups
/// the calling process is in.  Otherwise, fill in the group IDs
/// of its supplementary groups in LIST and return the number written.
int getgroups(
  int size,
  ffi.Pointer<ffi.Uint32> __list,
) {
  _getgroups ??=
      Libc().dylib.lookupFunction<_c_getgroups, _dart_getgroups>('getgroups');
  return _getgroups!(
    size,
    __list,
  );
}

_dart_getgroups? _getgroups;

/// Set the user ID of the calling process to UID.
/// If the calling process is the super-user, set the real
/// and effective user IDs, and the saved set-user-ID to UID;
/// if not, the effective user ID is set to UID.
void setuid(
  int uid,
) {
  _setuid ??= Libc().dylib.lookupFunction<_c_setuid, _dart_setuid>('setuid');
  var result = _setuid!(
    uid,
  );

  _throwIfError('setuid', result);
}

_dart_setuid? _setuid;

/// Set the real user ID of the calling process to RUID,
/// and the effective user ID of the calling process to EUID.
/// Throws [PosixException] if the operation fails.
void setreuid(
  int ruid,
  int euid,
) {
  _setreuid ??=
      Libc().dylib.lookupFunction<_c_setreuid, _dart_setreuid>('setreuid');
  var result = _setreuid!(
    ruid,
    euid,
  );

  _throwIfError('setreuid', result);
}

_dart_setreuid? _setreuid;

/// Set the effective user ID of the calling process to UID.
void seteuid(
  int uid,
) {
  _seteuid ??=
      Libc().dylib.lookupFunction<_c_seteuid, _dart_seteuid>('seteuid');
  var result = _seteuid!(
    uid,
  );

  _throwIfError('seteuid', result);
}

_dart_seteuid? _seteuid;

/// Set the group ID of the calling process to GID.
/// If the calling process is the super-user, set the real
/// and effective group IDs, and the saved set-group-ID to GID;
/// if not, the effective group ID is set to GID.
/// Throws [PosixException] if the operation fails.
void setgid(
  int gid,
) {
  _setgid ??= Libc().dylib.lookupFunction<_c_setgid, _dart_setgid>('setgid');
  var result = _setgid!(
    gid,
  );

  _throwIfErrno('setregid', result);
}

_dart_setgid? _setgid;

/// Set the real group ID of the calling process to RGID,
/// and the effective group ID of the calling process to EGID.
/// Throws [PosixException] if the operation fails.
void native_setregid(
  int rgid,
  int egid,
) {
  _setregid ??=
      Libc().dylib.lookupFunction<_c_setregid, _dart_setregid>('setregid');
  var result = _setregid!(
    rgid,
    egid,
  );

  _throwIfErrno('setregid', result);
}

_dart_setregid? _setregid;

/// Set the effective group ID of the calling process to GID.
/// Throws [PosixException] if the operation fails.
void setegid(
  int gid,
) {
  _setegid ??=
      Libc().dylib.lookupFunction<_c_setegid, _dart_setegid>('setegid');
  var result = _setegid!(
    gid,
  );

  _throwIfErrno('setegid', result);
}

_dart_setegid? _setegid;

/// Clone the calling process, creating an exact copy.
/// Return  0 to the new process,
/// and the process ID of the new process to the old process.
///
/// I have no idea what this will do to a dart process.
///
/// Throws [PosixException] if the operation fails.
int fork() {
  _fork ??= Libc().dylib.lookupFunction<_c_fork, _dart_fork>('fork');

  var result = _fork!();

  _throwIfErrno('fork', result);

  return result;
}

_dart_fork? _fork;

/// Clone the calling process, but without copying the whole address space.
/// The calling process is suspended until the new process exits or is
/// replaced by a call to `execve'.
/// Return 0 to the new child process,
/// Returns the process ID of the new process to the parent process.
///
/// I have no idea what this will do to a dart process.
///
/// Throws [PosixException] if the operation fails.
int vfork() {
  _vfork ??= Libc().dylib.lookupFunction<_c_vfork, _dart_vfork>('vfork');

  var result = _vfork!();

  _throwIfErrno('vfork', result);

  return result;
}

_dart_vfork? _vfork;

/// Return the pathname of the terminal associate with the [fd] or
/// null if no terminal is associated with the [fd]
///
/// Throws a [PosixException] if an error occurs.
///
/// This method is not thread safe.
ffi.Pointer<Utf8> native_ttyname(
  int fd,
) {
  _ttyname ??=
      Libc().dylib.lookupFunction<_c_ttyname, _dart_ttyname>('ttyname');
  var c_name = _ttyname!(
    fd,
  );

  if (c_name == ffi.nullptr) {
    _throwIfErrno('ttyname', -1);
  }

  return c_name;
}

_dart_ttyname? _ttyname;

/// Store at most BUFLEN characters of the pathname of the terminal FD is
/// open on in BUF.  Return 0 on success, otherwise an error number.
int native_ttyname_r(
  int fd,
  ffi.Pointer<Utf8> buf,
  int buflen,
) {
  _ttyname_r ??=
      Libc().dylib.lookupFunction<_c_ttyname_r, _dart_ttyname_r>('ttyname_r');
  return _ttyname_r!(
    fd,
    buf,
    buflen,
  );
}

_dart_ttyname_r? _ttyname_r;

/// Return 1 if FD is a valid descriptor associated
/// with a terminal, zero if not.
int isatty(
  int fd,
) {
  _isatty ??= Libc().dylib.lookupFunction<_c_isatty, _dart_isatty>('isatty');
  return _isatty!(
    fd,
  );
}

_dart_isatty? _isatty;

/// Return the index into the active-logins file (utmp) for
/// the controlling terminal.
int ttyslot() {
  _ttyslot ??=
      Libc().dylib.lookupFunction<_c_ttyslot, _dart_ttyslot>('ttyslot');
  return _ttyslot!();
}

_dart_ttyslot? _ttyslot;

/// Make a link to FROM named TO.
///
/// Throws a [PosixException] if an error occurs.
void link(
  String from,
  String to,
) {
  var c_from = from.toNativeUtf8();
  var c_to = to.toNativeUtf8();

  _link ??= Libc().dylib.lookupFunction<_c_link, _dart_link>('link');
  var result = _link!(
    c_from,
    c_to,
  );

  _throwIfErrno('symlink', result, c_from, c_to);

  malloc.free(c_from);
  malloc.free(c_to);
}

_dart_link? _link;

/// Like link but relative paths in TO and FROM are interpreted relative
/// to FROMFD and TOFD respectively.
///
/// Throws a [PosixException] if an error occurs.
void linkat(
  int __fromfd,
  String from,
  int __tofd,
  String to,
  int flags,
) {
  var c_from = from.toNativeUtf8();
  var c_to = to.toNativeUtf8();

  _linkat ??= Libc().dylib.lookupFunction<_c_linkat, _dart_linkat>('linkat');
  var result = _linkat!(
    __fromfd,
    c_from,
    __tofd,
    c_to,
    flags,
  );

  _throwIfErrno('symlink', result, c_from, c_to);

  malloc.free(c_from);
  malloc.free(c_to);
}

_dart_linkat? _linkat;

/// Make a symbolic link to FROM named TO.
///
/// Throws a [PosixException] if an error occurs.
void symlink(
  String from,
  String to,
) {
  var c_from = from.toNativeUtf8();
  var c_to = to.toNativeUtf8();

  _symlink ??=
      Libc().dylib.lookupFunction<_c_symlink, _dart_symlink>('symlink');
  var result = _symlink!(
    c_from,
    c_to,
  );

  _throwIfErrno('symlink', result, c_from, c_to);

  malloc.free(c_from);
  malloc.free(c_to);
}

_dart_symlink? _symlink;

/// Read the contents of the symbolic link PATH into no more than
/// LEN bytes of BUF.  The contents are not null-terminated.
/// Returns the number of characters read, or -1 for errors.
int native_readlink(
  String path,
  ffi.Pointer<Utf8> buf,
  int len,
) {
  var c_path = path.toNativeUtf8();

  _readlink ??=
      Libc().dylib.lookupFunction<_c_readlink, _dart_readlink>('readlink');
  var read = _readlink!(
    c_path,
    buf,
    len,
  );

  if (read == -1) _throwIfErrno('readlink', read, c_path);

  malloc.free(c_path);

  return read;
}

_dart_readlink? _readlink;

/// Like symlink but a relative path in TO is interpreted relative to TOFD.
///
/// Throws a [PosxException] if the symlink failed.
void symlinkat(
  String from,
  int tofd,
  String to,
) {
  var c_from = from.toNativeUtf8();
  var c_to = to.toNativeUtf8();
  _symlinkat ??=
      Libc().dylib.lookupFunction<_c_symlinkat, _dart_symlinkat>('symlinkat');
  var result = _symlinkat!(
    c_from,
    tofd,
    c_to,
  );

  _throwIfErrno('symlinkat', result, c_from, c_to);

  malloc.free(c_from);
  malloc.free(c_to);
}

_dart_symlinkat? _symlinkat;

/// Like readlink but a relative PATH is interpreted relative to FD.
void native_readlinkat(
  int fd,
  String path,
  ffi.Pointer<Utf8> buf,
  int len,
) {
  var c_path = path.toNativeUtf8();

  _readlinkat ??= Libc()
      .dylib
      .lookupFunction<_c_readlinkat, _dart_readlinkat>('readlinkat');
  var result = _readlinkat!(
    fd,
    c_path,
    buf,
    len,
  );

  _throwIfErrno('readlinkat', result, c_path);

  malloc.free(c_path);
}

_dart_readlinkat? _readlinkat;

/// Remove the link NAME.
void unlink(
  String name,
) {
  var c_name = name.toNativeUtf8();

  _unlink ??= Libc().dylib.lookupFunction<_c_unlink, _dart_unlink>('unlink');
  var result = _unlink!(
    c_name,
  );

  _throwIfErrno('unlink', result, c_name);

  malloc.free(c_name);
}

_dart_unlink? _unlink;

/// Remove the link NAME relative to FD.
///
/// Throws a [PosixException] if the unlink failed.
void unlinkat(
  int fd,
  String name,
  int flag,
) {
  var c_name = name.toNativeUtf8();
  _unlinkat ??=
      Libc().dylib.lookupFunction<_c_unlinkat, _dart_unlinkat>('unlinkat');
  var result = _unlinkat!(
    fd,
    c_name,
    flag,
  );
  _throwIfErrno('unlinkat', result, c_name);

  malloc.free(c_name);
}

_dart_unlinkat? _unlinkat;

/// Remove the directory PATH.
///
/// Throws a [PosixException] if the delete fails.
void rmdir(String path) {
  var c_path = path.toNativeUtf8();
  _rmdir ??= Libc().dylib.lookupFunction<_c_rmdir, _dart_rmdir>('rmdir');
  var result = _rmdir!(
    c_path,
  );

  _throwIfErrno('rmdir', result, c_path);

  malloc.free(c_path);
}

_dart_rmdir? _rmdir;

/// Return the foreground process group ID of FD.
int tcgetpgrp(
  int fd,
) {
  _tcgetpgrp ??=
      Libc().dylib.lookupFunction<_c_tcgetpgrp, _dart_tcgetpgrp>('tcgetpgrp');
  return _tcgetpgrp!(
    fd,
  );
}

_dart_tcgetpgrp? _tcgetpgrp;

/// Set the foreground process group ID of FD set PGRP_ID.
int tcsetpgrp(
  int fd,
  int pgrp_id,
) {
  _tcsetpgrp ??=
      Libc().dylib.lookupFunction<_c_tcsetpgrp, _dart_tcsetpgrp>('tcsetpgrp');
  return _tcsetpgrp!(
    fd,
    pgrp_id,
  );
}

_dart_tcsetpgrp? _tcsetpgrp;

/// Return the login name of the user.
///
/// If there is no login name then null is returned.
///
/// If an error occures a [PosixException] is thrown.
///
/// This method is not thread safe.
///
String? getlogin() {
  _getlogin ??=
      Libc().dylib.lookupFunction<_c_getlogin, _dart_getlogin>('getlogin');
  var c_name = _getlogin!();

  if (c_name == ffi.nullptr) {
    // may be there is no login name or possibly an error occured.

    var error = errno();

    if (error != 0) {
      throw PosixException('Call to getlogin() failed', error,
          posixError: _getLogin_error(error));
    }
  }
  // c_name points to static memory so we don't need to free it.
  var name = c_name == ffi.nullptr ? null : c_name.toDartString();

  return name;
}

String _getLogin_error(int error) {
  String message;

  switch (error) {
    case EMFILE:
      message =
          'The per-process limit on the number of open file descriptors has been reached.';
      break;

    case ENFILE:
      message =
          'The system-wide limit on the total number of open files has been reached.';
      break;

    case ENXIO:
      message = 'The calling process has no controlling terminal.';
      break;
    case ERANGE:
      message =
          "(getlogin_r) The length of the username, including the terminating null byte ('\0'), is larger than bufsize.";
      break;

    case ENOENT:
      message = 'There was no corresponding entry in the utmp-file.';
      break;

    case ENOMEM:
      message = 'Insufficient memory to allocate passwd structure.';
      break;

    case ENOTTY:
      message = "Standard input didn't refer to a terminal.  (See BUGS.)";
      break;

    default:
      message = strerror(error);
  }
  return message;
}

_dart_getlogin? _getlogin;

/// Returns the login name.
///
/// Throws a [PosixException] if the name cannot be retrieved.
String getlogin_r() {
  const max_length = 32 + 1;
  var c_name = malloc.allocate<Utf8>(max_length);
  _getlogin_r ??= Libc()
      .dylib
      .lookupFunction<_c_getlogin_r, _dart_getlogin_r>('getlogin_r');
  var result = _getlogin_r!(
    c_name,
    max_length,
  );

  _throwIfErrno('getlogin_r', result, c_name);

  var name = c_name.toDartString();
  malloc.free(c_name);

  return name;
}

_dart_getlogin_r? _getlogin_r;

/// Set the login name returned by `getlogin'.
/// Throws PosixException if the call fails.
void setlogin(
  String name, // ffi.Pointer<Utf8> name,
) {
  var c_name = name.toNativeUtf8();
  _setlogin ??=
      Libc().dylib.lookupFunction<_c_setlogin, _dart_setlogin>('setlogin');

  var result = _setlogin!(
    c_name,
  );

  _throwIfErrno('setlogin', result, c_name);

  malloc.free(c_name);
}

/// Throws a [PosixException] if [results] == 1
/// retrieving the actual error code from errno().
///
/// if [result] equals zero then the method returns
/// without taking any action.
///
/// If [toFree1] or [toFree2] are passed they will
/// be treated as allocated memory and will be freed
/// if an exception is to be thrown.
void _throwIfErrno<T>(String method, int result,
    [ffi.Pointer<ffi.NativeType>? toFree1,
    ffi.Pointer<ffi.NativeType>? toFree2]) {
  if (result == -1) {
    if (toFree1 != null && toFree1 != ffi.nullptr) malloc.free(toFree1);
    if (toFree2 != null && toFree2 != ffi.nullptr) malloc.free(toFree2);

    var error = errno();

    throw PosixException(
        'An error occured calling $method: ${strerror(error)} ', error);
  }
}

void _throwIfError<T>(String method, int error,
    [ffi.Pointer<ffi.NativeType>? toFree1,
    ffi.Pointer<ffi.NativeType>? toFree2]) {
  if (error != 0) {
    if (toFree1 != null && toFree1 != ffi.nullptr) malloc.free(toFree1);
    if (toFree2 != null && toFree2 != ffi.nullptr) malloc.free(toFree2);
    throw PosixException('An error occured calling $method', error);
  }
}

_dart_setlogin? _setlogin;

int native_getopt(
  int argc,
  ffi.Pointer<ffi.Pointer<Utf8>> ___argv,
  ffi.Pointer<Utf8> __shortopts,
) {
  _getopt ??= Libc().dylib.lookupFunction<_c_getopt, _dart_getopt>('getopt');
  return _getopt!(
    argc,
    ___argv,
    __shortopts,
  );
}

_dart_getopt? _getopt;

/// Get the name of the current host.
///
/// Throws a [PosixException] if an error occurs
/// The result is null-terminated if LEN is large enough for the full
/// name and the terminator.
String gethostname() {
  const buf_size = 64 + 1;
  var c_name = malloc.allocate<Utf8>(buf_size);

  _gethostname ??= Libc()
      .dylib
      .lookupFunction<_c_gethostname, _dart_gethostname>('gethostname');
  var result = _gethostname!(
    c_name,
    buf_size,
  );

  _throwIfErrno('gethostname', result, c_name);

  var hostname = c_name.toDartString();
  malloc.free(c_name);

  return hostname;
}

_dart_gethostname? _gethostname;

/// Set the name of the current host to NAME.
/// This call is restricted to the super-user.
int sethostname(
  String name, // ffi.Pointer<Utf8> name,
) {
  var c_name = name.toNativeUtf8();

  _sethostname ??= Libc()
      .dylib
      .lookupFunction<_c_sethostname, _dart_sethostname>('sethostname');
  var result = _sethostname!(
    c_name,
    name.length,
  );

  _throwIfErrno('gethostname', result, c_name);
  malloc.free(c_name);
  return result;
}

_dart_sethostname? _sethostname;

/// Set the current machine's Internet number to ID.
/// This call is restricted to the super-user.
int sethostid(
  int id,
) {
  _sethostid ??=
      Libc().dylib.lookupFunction<_c_sethostid, _dart_sethostid>('sethostid');
  return _sethostid!(
    id,
  );
}

_dart_sethostid? _sethostid;

/// Get and set the NIS (aka YP) domain name, if any.
/// Called just like `gethostname' and `sethostname'.
/// The NIS domain name is usually the empty string when not using NIS.
int getdomainname(
  String name, // ffi.Pointer<Utf8> name,
  int len,
) {
  var c_name = name.toNativeUtf8();
  _getdomainname ??= Libc()
      .dylib
      .lookupFunction<_c_getdomainname, _dart_getdomainname>('getdomainname');
  var result = _getdomainname!(
    c_name,
    len,
  );

  malloc.free(c_name);
  return result;
}

_dart_getdomainname? _getdomainname;

int setdomainname(
  String name, // ffi.Pointer<Utf8> name,
  int len,
) {
  var c_name = name.toNativeUtf8();

  _setdomainname ??= Libc()
      .dylib
      .lookupFunction<_c_setdomainname, _dart_setdomainname>('setdomainname');
  var result = _setdomainname!(
    c_name,
    len,
  );
  malloc.free(c_name);
  return result;
}

_dart_setdomainname? _setdomainname;

/// Revoke access permissions to all processes currently communicating
/// with the control terminal, and then send a SIGHUP signal to the process
/// group of the control terminal.
int vhangup() {
  _vhangup ??=
      Libc().dylib.lookupFunction<_c_vhangup, _dart_vhangup>('vhangup');
  return _vhangup!();
}

_dart_vhangup? _vhangup;

/// Revoke the access of all descriptors currently open on FILE.
int revoke(
  String filename, // ffi.Pointer<Utf8> file,
) {
  var c_filename = filename.toNativeUtf8();
  _revoke ??= Libc().dylib.lookupFunction<_c_revoke, _dart_revoke>('revoke');
  var result = _revoke!(
    c_filename,
  );

  malloc.free(c_filename);
  return result;
}

_dart_revoke? _revoke;

/// Enable statistical profiling, writing samples of the PC into at most
/// SIZE bytes of SAMPLE_BUFFER; every processor clock tick while profiling
/// is enabled, the system examines the user PC and increments
/// SAMPLE_BUFFER[((PC - OFFSET) / 2) * SCALE / 65536].  If SCALE is zero,
/// disable profiling.  Returns zero on success, -1 on error.
int native_profil(
  ffi.Pointer<ffi.Uint16> __sample_buffer,
  int size,
  int offset,
  int scale,
) {
  _profil ??= Libc().dylib.lookupFunction<_c_profil, _dart_profil>('profil');
  return _profil!(
    __sample_buffer,
    size,
    offset,
    scale,
  );
}

_dart_profil? _profil;

/// Turn accounting on if NAME is an existing file.  The system will then write
/// a record for each process as it terminates, to this file.  If NAME is NULL,
/// turn accounting off.  This call is restricted to the super-user.
int acct(
  String name, // ffi.Pointer<Utf8> name,
) {
  var c_name = name.toNativeUtf8();

  _acct ??= Libc().dylib.lookupFunction<_c_acct, _dart_acct>('acct');
  var result = _acct!(
    c_name,
  );

  malloc.free(c_name);
  return result;
}

_dart_acct? _acct;

/// Successive calls return the shells listed in `/etc/shells'.
ffi.Pointer<Utf8> native_getusershell() {
  _getusershell ??= Libc()
      .dylib
      .lookupFunction<_c_getusershell, _dart_getusershell>('getusershell');
  return _getusershell!();
}

_dart_getusershell? _getusershell;

void endusershell() {
  _endusershell ??= Libc()
      .dylib
      .lookupFunction<_c_endusershell, _dart_endusershell>('endusershell');
  return _endusershell!();
}

_dart_endusershell? _endusershell;

void setusershell() {
  _setusershell ??= Libc()
      .dylib
      .lookupFunction<_c_setusershell, _dart_setusershell>('setusershell');
  return _setusershell!();
}

_dart_setusershell? _setusershell;

/// Put the program in the background, and dissociate from the controlling
/// terminal.  If NOCHDIR is zero, do `chdir ("/")'.  If NOCLOSE is zero,
/// redirects stdin, stdout, and stderr to /dev/null.
int daemon(
  int nochdir,
  int noclose,
) {
  _daemon ??= Libc().dylib.lookupFunction<_c_daemon, _dart_daemon>('daemon');
  return _daemon!(
    nochdir,
    noclose,
  );
}

_dart_daemon? _daemon;

/// Make PATH be the root directory (the starting point for absolute paths).
/// This call is restricted to the super-user.
int chroot(
  String path, // ffi.Pointer<Utf8> __path,
) {
  var c_path = path.toNativeUtf8();
  _chroot ??= Libc().dylib.lookupFunction<_c_chroot, _dart_chroot>('chroot');
  var result = _chroot!(
    c_path,
  );

  malloc.free(c_path);
  return result;
}

_dart_chroot? _chroot;

/// Prompt with PROMPT and read a string from the terminal without echoing.
/// Uses /dev/tty if possible; otherwise stderr and stdin.
ffi.Pointer<Utf8> native_getpass(
  ffi.Pointer<Utf8> __prompt,
) {
  _getpass ??=
      Libc().dylib.lookupFunction<_c_getpass, _dart_getpass>('getpass');
  return _getpass!(
    __prompt,
  );
}

_dart_getpass? _getpass;

/// Make all changes done to FD actually appear on disk.
///
/// This function is a cancellation point and therefore not marked with
/// __THROW.
int fsync(
  int fd,
) {
  _fsync ??= Libc().dylib.lookupFunction<_c_fsync, _dart_fsync>('fsync');
  return _fsync!(
    fd,
  );
}

_dart_fsync? _fsync;

/// Return identifier for the current host.
int gethostid() {
  _gethostid ??=
      Libc().dylib.lookupFunction<_c_gethostid, _dart_gethostid>('gethostid');
  return _gethostid!();
}

_dart_gethostid? _gethostid;

/// Make all changes done to all files actually appear on disk.
void sync_1() {
  _sync_1 ??= Libc().dylib.lookupFunction<_c_sync_1, _dart_sync_1>('sync');
  return _sync_1!();
}

_dart_sync_1? _sync_1;

/// Return the number of bytes in a page.  This is the system's page size,
/// which is not necessarily the same as the hardware page size.
int getpagesize() {
  _getpagesize ??= Libc()
      .dylib
      .lookupFunction<_c_getpagesize, _dart_getpagesize>('getpagesize');
  return _getpagesize!();
}

_dart_getpagesize? _getpagesize;

/// Return the maximum number of file descriptors
/// the current process could possibly have.
int getdtablesize() {
  _getdtablesize ??= Libc()
      .dylib
      .lookupFunction<_c_getdtablesize, _dart_getdtablesize>('getdtablesize');
  return _getdtablesize!();
}

_dart_getdtablesize? _getdtablesize;

int truncate(
  String filename, // ffi.Pointer<Utf8> file,
  int length,
) {
  var c_filename = filename.toNativeUtf8();
  _truncate ??=
      Libc().dylib.lookupFunction<_c_truncate, _dart_truncate>('truncate');
  var result = _truncate!(
    c_filename,
    length,
  );

  malloc.free(c_filename);
  return result;
}

_dart_truncate? _truncate;

int ftruncate(
  int fd,
  int length,
) {
  _ftruncate ??=
      Libc().dylib.lookupFunction<_c_ftruncate, _dart_ftruncate>('ftruncate');
  return _ftruncate!(
    fd,
    length,
  );
}

_dart_ftruncate? _ftruncate;

/// Set the end of accessible data space (aka "the break") to ADDR.
/// Returns zero on success and -1 for errors (with errno set).
int native_brk(
  ffi.Pointer<ffi.Void> addr,
) {
  _brk ??= Libc().dylib.lookupFunction<_c_brk, _dart_brk>('brk');
  return _brk!(
    addr,
  );
}

_dart_brk? _brk;

/// Increase or decrease the end of accessible data space by DELTA bytes.
/// If successful, returns the address the previous end of data space
/// (i.e. the beginning of the new space, if DELTA > 0);
/// returns (void *) -1 for errors (with errno set).
ffi.Pointer<ffi.Void> sbrk(
  int delta,
) {
  _sbrk ??= Libc().dylib.lookupFunction<_c_sbrk, _dart_sbrk>('sbrk');
  return _sbrk!(
    delta,
  );
}

_dart_sbrk? _sbrk;

/// Invoke `system call' number SYSNO, passing it the remaining arguments.
/// This is completely system-dependent, and not often useful.
///
/// In Unix, `syscall' sets `errno' for all errors and most calls return -1
/// for errors; in many systems you cannot pass arguments or get return
/// values for all system calls (`pipe', `fork', and `getppid' typically
/// among them).
///
/// In Mach, all system calls take normal arguments and always return an
/// error code (zero for success).
int syscall(
  int __sysno,
) {
  _syscall ??=
      Libc().dylib.lookupFunction<_c_syscall, _dart_syscall>('syscall');
  return _syscall!(
    __sysno,
  );
}

_dart_syscall? _syscall;

int lockf(
  int fd,
  int cmd,
  int len,
) {
  _lockf ??= Libc().dylib.lookupFunction<_c_lockf, _dart_lockf>('lockf');
  return _lockf!(
    fd,
    cmd,
    len,
  );
}

_dart_lockf? _lockf;

/// Synchronize at least the data part of a file with the underlying
/// media.
int fdatasync(
  int fildes,
) {
  _fdatasync ??=
      Libc().dylib.lookupFunction<_c_fdatasync, _dart_fdatasync>('fdatasync');
  return _fdatasync!(
    fildes,
  );
}

_dart_fdatasync? _fdatasync;

/// One-way hash PHRASE, returning a string suitable for storage in the
/// user database.  SALT selects the one-way function to use, and
/// ensures that no two users' hashes are the same, even if they use
/// the same passphrase.  The return value points to static storage
/// which will be overwritten by the next call to crypt.
ffi.Pointer<Utf8> native_crypt(
  ffi.Pointer<Utf8> key,
  ffi.Pointer<Utf8> salt,
) {
  _crypt ??= Libc().dylib.lookupFunction<_c_crypt, _dart_crypt>('crypt');
  return _crypt!(
    key,
    salt,
  );
}

_dart_crypt? _crypt;

/// Write LENGTH bytes of randomness starting at BUFFER.  Return 0 on
/// success or -1 on error.
int native_getentropy(
  ffi.Pointer<ffi.Void> buffer,
  int length,
) {
  _getentropy ??= Libc()
      .dylib
      .lookupFunction<_c_getentropy, _dart_getentropy>('getentropy');
  return _getentropy!(
    buffer,
    length,
  );
}

_dart_getentropy? _getentropy;

const int R_OK = 4;

const int W_OK = 2;

const int X_OK = 1;

const int F_OK = 0;

const int SEEK_SET = 0;

const int SEEK_CUR = 1;

const int SEEK_END = 2;

const int L_SET = 0;

const int L_INCR = 1;

const int L_XTND = 2;

const int F_ULOCK = 0;

const int F_LOCK = 1;

const int F_TLOCK = 2;

const int F_TEST = 3;

const int PATH_MAX = 4096;

///////////////////////////////////////////////////////////////////////////
///
/// typedefs
///
///////////////////////////////////////////////////////////////////////////
///
typedef _c_access = ffi.Int32 Function(
  ffi.Pointer<Utf8> name,
  ffi.Int32 __type,
);

typedef _dart_access = int Function(
  ffi.Pointer<Utf8> name,
  int __type,
);

typedef _c_faccessat = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Pointer<Utf8> file,
  ffi.Int32 __type,
  ffi.Int32 flag,
);

typedef _dart_faccessat = int Function(
  int fd,
  ffi.Pointer<Utf8> file,
  int __type,
  int flag,
);

typedef _c_lseek = ffi.Int64 Function(
  ffi.Int32 fd,
  ffi.Int64 offset,
  ffi.Int32 __whence,
);

typedef _dart_lseek = int Function(
  int fd,
  int offset,
  int __whence,
);

typedef _c_close = ffi.Int32 Function(
  ffi.Int32 fd,
);

typedef _dart_close = int Function(
  int fd,
);

typedef _c_read = ffi.Int64 Function(
  ffi.Int32 fd,
  ffi.Pointer<ffi.Int8> buf,
  ffi.Uint64 nbytes,
);

typedef _dart_read = int Function(
  int fd,
  ffi.Pointer<ffi.Int8> buf,
  int nbytes,
);

typedef _c_write = ffi.Int64 Function(
  ffi.Int32 fd,
  ffi.Pointer<ffi.Int8> buf,
  ffi.Uint64 n,
);

typedef _dart_write = int Function(
  int fd,
  ffi.Pointer<ffi.Int8> buf,
  int n,
);

typedef _c_pread = ffi.Int64 Function(
  ffi.Int32 fd,
  ffi.Pointer<ffi.Int8> buf,
  ffi.Uint64 nbytes,
  ffi.Int64 offset,
);

typedef _dart_pread = int Function(
  int fd,
  ffi.Pointer<ffi.Int8> buf,
  int nbytes,
  int offset,
);

typedef _c_pwrite = ffi.Int64 Function(
  ffi.Int32 fd,
  ffi.Pointer<ffi.Int8> buf,
  ffi.Uint64 n,
  ffi.Int64 offset,
);

typedef _dart_pwrite = int Function(
  int fd,
  ffi.Pointer<ffi.Int8> buf,
  int n,
  int offset,
);

typedef _c_pipe = ffi.Int32 Function(
  ffi.Pointer<ffi.Int32> __pipedes,
);

typedef _dart_pipe = int Function(
  ffi.Pointer<ffi.Int32> __pipedes,
);

typedef _c_alarm = ffi.Uint32 Function(
  ffi.Uint32 seconds,
);

typedef _dart_alarm = int Function(
  int seconds,
);

typedef _c_sleep = ffi.Uint32 Function(
  ffi.Uint32 seconds,
);

typedef _dart_sleep = int Function(
  int seconds,
);

typedef _c_ualarm = ffi.Uint32 Function(
  ffi.Uint32 value,
  ffi.Uint32 interval,
);

typedef _dart_ualarm = int Function(
  int value,
  int interval,
);

typedef _c_usleep = ffi.Int32 Function(
  ffi.Uint32 useconds,
);

typedef _dart_usleep = int Function(
  int useconds,
);

typedef _c_pause = ffi.Int32 Function();

typedef _dart_pause = int Function();

typedef _c_chown = ffi.Int32 Function(
  ffi.Pointer<Utf8> file,
  ffi.Uint32 owner,
  ffi.Uint32 group,
);

typedef _dart_chown = int Function(
  ffi.Pointer<Utf8> file,
  int owner,
  int group,
);

typedef _c_fchown = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Uint32 owner,
  ffi.Uint32 group,
);

typedef _dart_fchown = int Function(
  int fd,
  int owner,
  int group,
);

typedef _c_lchown = ffi.Int32 Function(
  ffi.Pointer<Utf8> file,
  ffi.Uint32 owner,
  ffi.Uint32 group,
);

typedef _dart_lchown = int Function(
  ffi.Pointer<Utf8> file,
  int owner,
  int group,
);

typedef _c_fchownat = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Pointer<Utf8> file,
  ffi.Uint32 owner,
  ffi.Uint32 group,
  ffi.Int32 flag,
);

typedef _dart_fchownat = int Function(
  int fd,
  ffi.Pointer<Utf8> file,
  int owner,
  int group,
  int flag,
);

typedef _c_chdir = ffi.Int32 Function(
  ffi.Pointer<Utf8> __path,
);

typedef _dart_chdir = int Function(
  ffi.Pointer<Utf8> __path,
);

typedef _c_fchdir = ffi.Int32 Function(
  ffi.Int32 fd,
);

typedef _dart_fchdir = int Function(
  int fd,
);

typedef _c_getcwd = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Int8> __buf,
  ffi.Uint64 __size,
);

typedef _dart_getcwd = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Int8> __buf,
  int __size,
);

typedef _c_getwd = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Int8> buf,
);

typedef _dart_getwd = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<ffi.Int8> buf,
);

typedef _c_dup = ffi.Int32 Function(
  ffi.Int32 fd,
);

typedef _dart_dup = int Function(
  int fd,
);

typedef _c_dup2 = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Int32 fd2,
);

typedef _dart_dup2 = int Function(
  int fd,
  int fd2,
);

typedef _c_execve = ffi.Int32 Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
  ffi.Pointer<ffi.Pointer<Utf8>> __envp,
);

typedef _dart_execve = int Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
  ffi.Pointer<ffi.Pointer<Utf8>> __envp,
);

typedef _c_fexecve = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
  ffi.Pointer<ffi.Pointer<Utf8>> __envp,
);

typedef _dart_fexecve = int Function(
  int fd,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
  ffi.Pointer<ffi.Pointer<Utf8>> __envp,
);

typedef _c_execv = ffi.Int32 Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
);

typedef _dart_execv = int Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
);

typedef _c_execle = ffi.Int32 Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<Utf8> __arg,
);

typedef _dart_execle = int Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<Utf8> __arg,
);

typedef _c_execl = ffi.Int32 Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<Utf8> __arg,
);

typedef _dart_execl = int Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<Utf8> __arg,
);

typedef _c_execvp = ffi.Int32 Function(
  ffi.Pointer<Utf8> file,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
);

typedef _dart_execvp = int Function(
  ffi.Pointer<Utf8> file,
  ffi.Pointer<ffi.Pointer<Utf8>> __argv,
);

typedef _c_execlp = ffi.Int32 Function(
  ffi.Pointer<Utf8> file,
  ffi.Pointer<Utf8> __arg,
);

typedef _dart_execlp = int Function(
  ffi.Pointer<Utf8> file,
  ffi.Pointer<Utf8> __arg,
);

typedef _c_nice = ffi.Int32 Function(
  ffi.Int32 __inc,
);

typedef _dart_nice = int Function(
  int __inc,
);

typedef _c__exit = ffi.Void Function(
  ffi.Int32 __status,
);

typedef _dart__exit = void Function(
  int __status,
);

typedef _c_pathconf = ffi.Int64 Function(
  ffi.Pointer<Utf8> __path,
  ffi.Int32 name,
);

typedef _dart_pathconf = int Function(
  ffi.Pointer<Utf8> __path,
  int name,
);

typedef _c_fpathconf = ffi.Int64 Function(
  ffi.Int32 fd,
  ffi.Int32 name,
);

typedef _dart_fpathconf = int Function(
  int fd,
  int name,
);

typedef _c_sysconf = ffi.Int64 Function(
  ffi.Int32 name,
);

typedef _dart_sysconf = int Function(
  int name,
);

typedef _c_confstr = ffi.Uint64 Function(
  ffi.Int32 name,
  ffi.Pointer<ffi.Void> buf,
  ffi.Uint64 len,
);

typedef _dart_confstr = int Function(
  int name,
  ffi.Pointer<ffi.Void> buf,
  int len,
);

typedef _c_getpid = ffi.Int32 Function();

typedef _dart_getpid = int Function();

typedef _c_getppid = ffi.Int32 Function();

typedef _dart_getppid = int Function();

typedef _c_getpgrp = ffi.Int32 Function();

typedef _dart_getpgrp = int Function();

typedef _c_getpgid = ffi.Int32 Function(
  ffi.Int32 pid,
);

typedef _dart_getpgid = int Function(
  int pid,
);

typedef _c_setpgid = ffi.Int32 Function(
  ffi.Int32 pid,
  ffi.Int32 __pgid,
);

typedef _dart_setpgid = int Function(
  int pid,
  int __pgid,
);

typedef _c_setpgrp = ffi.Int32 Function();

typedef _dart_setpgrp = int Function();

typedef _c_setsid = ffi.Int32 Function();

typedef _dart_setsid = int Function();

typedef _c_getsid = ffi.Int32 Function(
  ffi.Int32 pid,
);

typedef _dart_getsid = int Function(
  int pid,
);

typedef _c_getuid = ffi.Uint32 Function();

typedef _dart_getuid = int Function();

typedef _c_geteuid = ffi.Uint32 Function();

typedef _dart_geteuid = int Function();

typedef _c_getgid = ffi.Uint32 Function();

typedef _dart_getgid = int Function();

typedef _c_getegid = ffi.Uint32 Function();

typedef _dart_getegid = int Function();

typedef _c_getgroups = ffi.Int32 Function(
  ffi.Int32 size,
  ffi.Pointer<ffi.Uint32> __list,
);

typedef _dart_getgroups = int Function(
  int size,
  ffi.Pointer<ffi.Uint32> __list,
);

typedef _c_setuid = ffi.Int32 Function(
  ffi.Uint32 uid,
);

typedef _dart_setuid = int Function(
  int uid,
);

typedef _c_setreuid = ffi.Int32 Function(
  ffi.Uint32 ruid,
  ffi.Uint32 euid,
);

typedef _dart_setreuid = int Function(
  int ruid,
  int euid,
);

typedef _c_seteuid = ffi.Int32 Function(
  ffi.Uint32 uid,
);

typedef _dart_seteuid = int Function(
  int uid,
);

typedef _c_setgid = ffi.Int32 Function(
  ffi.Uint32 gid,
);

typedef _dart_setgid = int Function(
  int gid,
);

typedef _c_setregid = ffi.Int32 Function(
  ffi.Uint32 rgid,
  ffi.Uint32 egid,
);

typedef _dart_setregid = int Function(
  int rgid,
  int egid,
);

typedef _c_setegid = ffi.Int32 Function(
  ffi.Uint32 gid,
);

typedef _dart_setegid = int Function(
  int gid,
);

typedef _c_fork = ffi.Int32 Function();

typedef _dart_fork = int Function();

typedef _c_vfork = ffi.Int32 Function();

typedef _dart_vfork = int Function();

typedef _c_ttyname = ffi.Pointer<Utf8> Function(
  ffi.Int32 fd,
);

typedef _dart_ttyname = ffi.Pointer<Utf8> Function(
  int fd,
);

typedef _c_ttyname_r = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Pointer<Utf8> buf,
  ffi.Uint64 buflen,
);

typedef _dart_ttyname_r = int Function(
  int fd,
  ffi.Pointer<Utf8> buf,
  int buflen,
);

typedef _c_isatty = ffi.Int32 Function(
  ffi.Int32 fd,
);

typedef _dart_isatty = int Function(
  int fd,
);

typedef _c_ttyslot = ffi.Int32 Function();

typedef _dart_ttyslot = int Function();

typedef _c_link = ffi.Int32 Function(
  ffi.Pointer<Utf8> __from,
  ffi.Pointer<Utf8> __to,
);

typedef _dart_link = int Function(
  ffi.Pointer<Utf8> __from,
  ffi.Pointer<Utf8> __to,
);

typedef _c_linkat = ffi.Int32 Function(
  ffi.Int32 __fromfd,
  ffi.Pointer<Utf8> __from,
  ffi.Int32 __tofd,
  ffi.Pointer<Utf8> __to,
  ffi.Int32 flags,
);

typedef _dart_linkat = int Function(
  int __fromfd,
  ffi.Pointer<Utf8> __from,
  int __tofd,
  ffi.Pointer<Utf8> __to,
  int flags,
);

typedef _c_symlink = ffi.Int32 Function(
  ffi.Pointer<Utf8> __from,
  ffi.Pointer<Utf8> __to,
);

typedef _dart_symlink = int Function(
  ffi.Pointer<Utf8> __from,
  ffi.Pointer<Utf8> __to,
);

typedef _c_readlink = ffi.Int64 Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<Utf8> buf,
  ffi.Uint64 len,
);

typedef _dart_readlink = int Function(
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<Utf8> buf,
  int len,
);

typedef _c_symlinkat = ffi.Int32 Function(
  ffi.Pointer<Utf8> __from,
  ffi.Int32 __tofd,
  ffi.Pointer<Utf8> __to,
);

typedef _dart_symlinkat = int Function(
  ffi.Pointer<Utf8> __from,
  int __tofd,
  ffi.Pointer<Utf8> __to,
);

typedef _c_readlinkat = ffi.Int64 Function(
  ffi.Int32 fd,
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<Utf8> buf,
  ffi.Uint64 len,
);

typedef _dart_readlinkat = int Function(
  int fd,
  ffi.Pointer<Utf8> __path,
  ffi.Pointer<Utf8> buf,
  int len,
);

typedef _c_unlink = ffi.Int32 Function(
  ffi.Pointer<Utf8> name,
);

typedef _dart_unlink = int Function(
  ffi.Pointer<Utf8> name,
);

typedef _c_unlinkat = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Pointer<Utf8> name,
  ffi.Int32 flag,
);

typedef _dart_unlinkat = int Function(
  int fd,
  ffi.Pointer<Utf8> name,
  int flag,
);

typedef _c_rmdir = ffi.Int32 Function(
  ffi.Pointer<Utf8> __path,
);

typedef _dart_rmdir = int Function(
  ffi.Pointer<Utf8> __path,
);

typedef _c_tcgetpgrp = ffi.Int32 Function(
  ffi.Int32 fd,
);

typedef _dart_tcgetpgrp = int Function(
  int fd,
);

typedef _c_tcsetpgrp = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Int32 pgrp_id,
);

typedef _dart_tcsetpgrp = int Function(
  int fd,
  int pgrp_id,
);

typedef _c_getlogin = ffi.Pointer<Utf8> Function();

typedef _dart_getlogin = ffi.Pointer<Utf8> Function();

typedef _c_getlogin_r = ffi.Int32 Function(
  ffi.Pointer<Utf8> name,
  ffi.Uint64 name_len,
);

typedef _dart_getlogin_r = int Function(
  ffi.Pointer<Utf8> name,
  int name_len,
);

typedef _c_setlogin = ffi.Int32 Function(
  ffi.Pointer<Utf8> name,
);

typedef _dart_setlogin = int Function(
  ffi.Pointer<Utf8> name,
);

typedef _c_getopt = ffi.Int32 Function(
  ffi.Int32 argc,
  ffi.Pointer<ffi.Pointer<Utf8>> ___argv,
  ffi.Pointer<Utf8> __shortopts,
);

typedef _dart_getopt = int Function(
  int argc,
  ffi.Pointer<ffi.Pointer<Utf8>> ___argv,
  ffi.Pointer<Utf8> __shortopts,
);

typedef _c_gethostname = ffi.Int32 Function(
  ffi.Pointer<Utf8> name,
  ffi.Uint64 len,
);

typedef _dart_gethostname = int Function(
  ffi.Pointer<Utf8> name,
  int len,
);

typedef _c_sethostname = ffi.Int32 Function(
  ffi.Pointer<Utf8> name,
  ffi.Uint64 len,
);

typedef _dart_sethostname = int Function(
  ffi.Pointer<Utf8> name,
  int len,
);

typedef _c_sethostid = ffi.Int32 Function(
  ffi.Int64 id,
);

typedef _dart_sethostid = int Function(
  int id,
);

typedef _c_getdomainname = ffi.Int32 Function(
  ffi.Pointer<Utf8> name,
  ffi.Uint64 len,
);

typedef _dart_getdomainname = int Function(
  ffi.Pointer<Utf8> name,
  int len,
);

typedef _c_setdomainname = ffi.Int32 Function(
  ffi.Pointer<Utf8> name,
  ffi.Uint64 len,
);

typedef _dart_setdomainname = int Function(
  ffi.Pointer<Utf8> name,
  int len,
);

typedef _c_vhangup = ffi.Int32 Function();

typedef _dart_vhangup = int Function();

typedef _c_revoke = ffi.Int32 Function(
  ffi.Pointer<Utf8> file,
);

typedef _dart_revoke = int Function(
  ffi.Pointer<Utf8> file,
);

typedef _c_profil = ffi.Int32 Function(
  ffi.Pointer<ffi.Uint16> __sample_buffer,
  ffi.Uint64 size,
  ffi.Uint64 offset,
  ffi.Uint32 scale,
);

typedef _dart_profil = int Function(
  ffi.Pointer<ffi.Uint16> __sample_buffer,
  int size,
  int offset,
  int scale,
);

typedef _c_acct = ffi.Int32 Function(
  ffi.Pointer<Utf8> name,
);

typedef _dart_acct = int Function(
  ffi.Pointer<Utf8> name,
);

typedef _c_getusershell = ffi.Pointer<Utf8> Function();

typedef _dart_getusershell = ffi.Pointer<Utf8> Function();

typedef _c_endusershell = ffi.Void Function();

typedef _dart_endusershell = void Function();

typedef _c_setusershell = ffi.Void Function();

typedef _dart_setusershell = void Function();

typedef _c_daemon = ffi.Int32 Function(
  ffi.Int32 nochdir,
  ffi.Int32 noclose,
);

typedef _dart_daemon = int Function(
  int nochdir,
  int noclose,
);

typedef _c_chroot = ffi.Int32 Function(
  ffi.Pointer<Utf8> __path,
);

typedef _dart_chroot = int Function(
  ffi.Pointer<Utf8> __path,
);

typedef _c_getpass = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> __prompt,
);

typedef _dart_getpass = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> __prompt,
);

typedef _c_fsync = ffi.Int32 Function(
  ffi.Int32 fd,
);

typedef _dart_fsync = int Function(
  int fd,
);

typedef _c_gethostid = ffi.Int64 Function();

typedef _dart_gethostid = int Function();

typedef _c_sync_1 = ffi.Void Function();

typedef _dart_sync_1 = void Function();

typedef _c_getpagesize = ffi.Int32 Function();

typedef _dart_getpagesize = int Function();

typedef _c_getdtablesize = ffi.Int32 Function();

typedef _dart_getdtablesize = int Function();

typedef _c_truncate = ffi.Int32 Function(
  ffi.Pointer<Utf8> file,
  ffi.Int64 length,
);

typedef _dart_truncate = int Function(
  ffi.Pointer<Utf8> file,
  int length,
);

typedef _c_ftruncate = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Int64 length,
);

typedef _dart_ftruncate = int Function(
  int fd,
  int length,
);

typedef _c_brk = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> addr,
);

typedef _dart_brk = int Function(
  ffi.Pointer<ffi.Void> addr,
);

typedef _c_sbrk = ffi.Pointer<ffi.Void> Function(
  ffi.IntPtr delta,
);

typedef _dart_sbrk = ffi.Pointer<ffi.Void> Function(
  int delta,
);

typedef _c_syscall = ffi.Int64 Function(
  ffi.Int64 __sysno,
);

typedef _dart_syscall = int Function(
  int __sysno,
);

typedef _c_lockf = ffi.Int32 Function(
  ffi.Int32 fd,
  ffi.Int32 cmd,
  ffi.Int64 len,
);

typedef _dart_lockf = int Function(
  int fd,
  int cmd,
  int len,
);

typedef _c_fdatasync = ffi.Int32 Function(
  ffi.Int32 fildes,
);

typedef _dart_fdatasync = int Function(
  int fildes,
);

typedef _c_crypt = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> key,
  ffi.Pointer<Utf8> salt,
);

typedef _dart_crypt = ffi.Pointer<Utf8> Function(
  ffi.Pointer<Utf8> key,
  ffi.Pointer<Utf8> salt,
);

typedef _c_getentropy = ffi.Int32 Function(
  ffi.Pointer<ffi.Void> buffer,
  ffi.Uint64 length,
);

typedef _dart_getentropy = int Function(
  ffi.Pointer<ffi.Void> buffer,
  int length,
);
