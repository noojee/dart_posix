import 'package:dcli/dcli.dart' as dcli;
import 'package:posix/src/stat.dart';
import 'package:test/test.dart';

void main() {
  test('stat ...', () async {
    var tempDir = dcli.createTempDir();
    var testFile = dcli.join(tempDir, 'test.txt');
    dcli.touch(testFile, create: true);

    print('$testFile');
    var struct = stat(testFile);
    var line = 'stat --format="%d,%i,%h,%u,%g,%s,%B,%b,%X,%Y,%Z,%a" $testFile '
        .firstLine!;

    var parts = line.split(',');
    var deviceId = parts[0];
    var inode = parts[1];
    var nlink = parts[2];
    var uid = parts[3];
    var gid = parts[4];
    var size = parts[5];
    // var blockSize = parts[6];
    var blocks = parts[7];
    var lastAccess = parts[8];
    var lastModified = parts[9];
    var lastStatusChange = parts[10];
    var mode = parts[11];
    var userMode = mode[0];
    var groupMode = mode[1];
    var otherMode = mode[2];

    // rwx
    expect(userMode, equals('6'));
    expect(groupMode, equals('6'));
    expect(otherMode, equals('4'));

    expect(struct.mode, isNotNull);

    expect(struct.mode.isOwnerReadable, isTrue);
    expect(struct.mode.isOwnerWritable, isTrue);
    expect(struct.mode.isOwnerExecutable, isFalse);

    expect(struct.mode.isGroupReadable, isTrue);
    expect(struct.mode.isGroupWritable, isTrue);
    expect(struct.mode.isGroupExecutable, isFalse);

    expect(struct.mode.isOtherReadable, isTrue);
    expect(struct.mode.isOtherWritable, isFalse);
    expect(struct.mode.isOtherExecutable, isFalse);

    expect('${struct.deviceId}', equals(deviceId));
    expect('${struct.inode}', equals(inode));
    expect('${struct.nlink}', equals(nlink));
    expect('${struct.uid}', equals(uid));
    expect('${struct.gid}', equals(gid));
    expect('${struct.size}', equals(size));

    expect('${struct.blocks}', equals(blocks));
    expect(struct.lastAccess, equals(toDateTime(lastAccess)));
    expect(struct.lastModified, equals(toDateTime(lastModified)));
    expect(struct.lastStatusChange, equals(toDateTime(lastStatusChange)));

    /// we don't check the blocksize as the stat command appears to always
    /// report 512 even if the system block size is something else.
    /// expect('${struct.blockSize}', equals(blockSize));
  });

  test('memory corruption ...', () async {
    var tempDir = dcli.createTempDir();
    var testFile = dcli.join(tempDir, 'test.txt');
    dcli.touch(testFile, create: true);

    print('$testFile');

    for (var i = 0; i < 1000; i++) {
      var struct = stat(testFile);

      expect(struct.mode, isNotNull);

      expect(struct.mode.isOwnerReadable, isTrue);
      expect(struct.mode.isOwnerWritable, isTrue);
      expect(struct.mode.isOwnerExecutable, isFalse);

      expect(struct.mode.isGroupReadable, isTrue);
      expect(struct.mode.isGroupWritable, isTrue);
      expect(struct.mode.isGroupExecutable, isFalse);

      expect(struct.mode.isOtherReadable, isTrue);
      expect(struct.mode.isOtherWritable, isFalse);
      expect(struct.mode.isOtherExecutable, isFalse);
    }

    /// we don't check the blocksize as the stat command appears to always
    /// report 512 even if the system block size is something else.
    /// expect('${struct.blockSize}', equals(blockSize));
  });
}

DateTime toDateTime(String secondsSinceEpoc) =>
    DateTime.fromMillisecondsSinceEpoch(int.parse(secondsSinceEpoc) * 1000);
