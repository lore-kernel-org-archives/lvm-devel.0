From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 02 Apr 2009 13:19:07 -0400
Subject: [RFC PATCH 0/7] Introduce metadata cache feature
Message-ID: <49D4F38B.9090705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch set introduces the metadata cache feature to reduce I/Os issued
by lvm commands. This is still prototype and is not even fully tested, but
let me post it to discuss its design and implementation.

Any comments and suggestions are welcome.


PATCH SET
=========

  1/7: remove device scan from _text_create_text_instance
  2/7: rename _has_scanned to _need_scan
  3/7: separate metadata parse and verification
  4/7: support metadata cache feature
  5/7: add metadata cache interface
  6/7: individual lvm command settings
  7/7: introduce metadata cache feature


BACKGROUND
==========

In the current implementation of lvm commands, all devices except for
devices filtered by configuration are scanned every time lvm commands
are executed. Information of physical volume, volume group and logical
volume are stored only in the metadata area on each real devices, and
reading these metadata from devices are required in order to figure out
the lvm structure in the system and to check their consistency. This
implementation provides high reliability.

On the other hand, device scan is done every time lvm commands are
executed, and many "READ I/O" are issued to those devices. This behavior
causes the following problems.

* Command execution time

  Each lvm command scans all devices even though devices don't belong to
  the target logical volume (LV) and volume group (VG) and not related
  to the operation. This may cause a long operation time.

  For example, on the system with 1000 physical volumes (PV) and VG (vg0)
  composed of PV(pv0), the lvm command, 'vgdisplay vg0', scans 1000 PVs
  and issues READ I/Os to all PVs. In this case, accessing only to pv0
  by vgdisplay is desirable.

* Maintenance issues

  Once a device got problems and replied no response, each lvm command
  will be timed-out even if the target devices are not broken, and lvm
  commands take much longer to be completed. This prevents quick system
  maintenance and recovery.

* Blockage of mirrored structure

  Once I/O errors are detected by device-mapper in the kenrnel and are
  noticed to dmeventd, it handles failure recovery. In case of an error
  on mirrored volume, dmeventd calls lvm command (vgreduce) internally
  and tries to remove bad volumes. Here, vgreduce scans all PVs. If
  there is a bad device which is not related to the mirror and causes
  timeout for I/Os, blockage process takes a long time and stops user
  applications during the long recovery.

Accessing only to target devices by lvm commands are strongly required.
This prototype patch solves the first two issues now, but the last issue
has not been covered yet.


DESIGN OVERVIEW
===============

* Fill lvmcache using metadata cache

  In the current lvmcache implementation, device scan is not generally
  triggered when requested information is on lvmcache. To meet this
  condition, metadata cache files are read from cache directory and
  loaded into lvmcache before the command specific functions are
  executed.

  In addition, the CACHE_INVALID flag is set to cache data when metadata
  cache is loaded into lvmcache so that the cache should be verified
  when it is accessed.

* Separate metadata parse and device verification

  In the current implementation, parse and verification process are
  done together in _reav_pv function. When physical volume is parsed
  in the metadata area, devices related physical volumes are accessed
  and verified.

  To utilize the parse functions, _read_vg and _read_pv, by metadata
  cache feature, device verification procedures are removed out of
  metadata parse functions, and merged into post procedures. When parse
  is done, the DEV_NEED_VERIFY flag is set to the device structures
  so that devices will be verified later.

* Use text metadata format as cache file

  lvm commands have already functions to read and write metadata into
  text files in the specified directory, which are used by backup or
  archive. The metadata cache feature handles cache files of the same
  format with these functions.


CONFIG SETTING
==============

The "backup/metadata_cache" parameter is added in the lvm configuration
file, lvm.conf, to enable and disable this metadata cache feature.

* lvm.conf

  backup {
      ....
      metadata_cache = 1   # enable
  }


EXECUTION EXAMPLES
==================

* Test environment

  VG (16 VGs): vg-sd[c-r]
  PV (16 PVs): /dev/sd[c-r]

  # pvs -a
    PV         VG   Fmt  Attr PSize  PFree
    /dev/sdc   vg-sdc lvm2 a-   16.00G 16.00G
    /dev/sdd   vg-sdd lvm2 a-   16.00G 16.00G
    ...
    /dev/sdr   vg-sdr lvm2 a-   16.00G 16.00G

* Example

  This results show how much I/Os are reduced by the metadata cache
  feature.

  a) *without* metadata cache

    # strace -e open,read vgs vg-sdc
    ...
    open("/dev/sdq", O_RDONLY|O_DIRECT|O_LARGEFILE|O_NOATIME) = 4
      <READ IO (4KB) to /dev/sdq: 4 times>
    open("/dev/sdr", O_RDONLY|O_DIRECT|O_LARGEFILE|O_NOATIME) = 4
      <READ IO (4KB) to /dev/sdr: 4 times>
    open("/dev/sdc", O_RDONLY|O_DIRECT|O_LARGEFILE|O_NOATIME) = 4
      <READ IO (4KB) to /dev/sdc: 4 times>
    ....
    open("/dev/sdp", O_RDONLY|O_DIRECT|O_LARGEFILE|O_NOATIME) = 5
      <READ IO (4KB) to /dev/sdp: 4 times>
      <READ IO (4KB) to /dev/sdc: 3 times>

    => Total 67 READ I/Os
        (7 READ I/Os to /dev/sdc and 4 READ I/Os to /dev/sd[d-r])

  b) *with* metadta cache

    # strace -e open,read vgs vg-sdc
    ...
    open("/dev/sdc", O_RDONLY|O_DIRECT|O_LARGEFILE|O_NOATIME) = 4
      <READ IO (4KB) to /dev/sdc: 7 times>

    => Total 7 READ I/Os
        (7 READ I/Os to /dev/sdc)

* I/O statistics

  Here shows an example of the number of I/Os issued by lvm commands.
  (NOTE: The results might be different in the environment.)

                      <WITHOUT metadata cache>  <WITH metadata cache>
                      Total sdc sdd .. sdq sdr  Total sdc sdd .. sdq sdr
  ------------------- ----- ------------------  ----- ------------------
  vgscan                128   8   8 ...  8   8    128   8   8 ...  8   8
  ------------------- ----- ------------------  ----- ------------------
  vgs                   236  14  14 ... 14  11    176  11  11 ...  11 11
  vgs <vg>               67   7   4 ...  4   4      7   7   0 ...   0  0
  ------------------- ----- ------------------- ----- ------------------
  lvs                   236  14  14 ... 14  11    176  11  11 ...  11 11
  lvs <lv>               67   7   4 ...  4   4      7   7   0 ...   0  0
  ------------------- ----- ------------------- ----- ------------------
  lvcreate -L12m <vg>    84  24   4 ...  4   4     24  24   0 ...   0  0
  lvremove <vg>/<lv>     85  25   4 ...  4   4     25  25   0 ...   0  0
  ------------------- ----- ------------------- ----- ------------------
  vgchange -ay          236  15  15 ...  15 11    176  11  11 ...  11 11
  vgchange -ay <vg>      67   7   4 ...   4  4      7   7   0 ...   0  0
  ------------------- ----- ------------------- ----- ------------------
  vgcreate <vg> <pv>    103  16   6 ...   5  5     90  15   5 ...   5  5
  vgremove <vg>          75  15   4 ...   4  4     15  15   0 ...   0  0
  ------------------- ----- ------------------- ----- ------------------


FUTURE WORKS
============

* Independent cache directory

  This prototype codes use metadata backup files as cache files, but
  cache files are better maintained in their own directory. To keep
  these cache files valid in the cache directory, they might need to
  be cleaned up after system boot, or revalidated by some lvm commands,
  such as vgscan.

* Apply metadata cache feature to lvm commands which change lvm structure

  lvm commands which change lvm structure, such as vgreduce and vgextend,
  still access all devices even with this feature. To avoid device scans
  by these lvm commands, some enhancements for lvm commands are needed.

* Add commandline option

  Add a new commandline option (ex --metadatacache y|n) to enable and
  disable cache feature in order to override a setting of the lvm
  configuration file.

* Testing

  More tests under device failures and cache inconsistency.


Regards,
---
Takahiro Yasui
Hitachi Computer Products (America) Inc.






