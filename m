From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 24 May 2018 11:35:03 -0400
Subject: master - pre-release
Message-ID: <201805241535.w4OFZ3Xg026860@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=adae8ee1c2926d59c85dc9fc253375f07f262819
Commit:        adae8ee1c2926d59c85dc9fc253375f07f262819
Parent:        7e85361c34ec539880fe8e764e4b49fc55f78a09
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu May 24 15:13:10 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu May 24 15:13:10 2018 +0200

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   21 ++++++++-------------
 WHATS_NEW_DM |    4 ++--
 4 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/VERSION b/VERSION
index 586bf0f..1594f32 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.178(2)-git (2017-12-18)
+2.02.178(2)-rc1 (2018-05-24)
diff --git a/VERSION_DM b/VERSION_DM
index d55b61b..e95d765 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.147-git (2017-12-18)
+1.02.147-rc1 (2018-05-24)
diff --git a/WHATS_NEW b/WHATS_NEW
index 3d722da..620c9d5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,16 +1,18 @@
-Version 2.02.178 - 
-=====================================
+Version 2.02.178-rc1 - 24th May 2018
+====================================
+  Add libaio dependency for build.
   Remove lvm1 and pool format handling and add filter to ignore them.
   Move some filter checks to after disks are read.
   Rework disk scanning and when it is used.
   Add new io layer and shift code to using it.
-  lvconvert: don't return success on degraded -m raid1 conversion
+  Fix lvconvert's return code on degraded -m raid1 conversion.
   --enable-testing switch for ./configure has been removed.
   --with-snapshots switch for ./configure has been removed.
   --with-mirrors switch for ./configure has been removed.
   --with-raid switch for ./configure has been removed.
   --with-thin switch for ./configure has been removed.
   --with-cache switch for ./configure has been removed.
+  Include new unit-test framework and unit tests.
   Extend validation of region_size for mirror segment.
   Reload whole device stack when reinitilizing mirror log.
   Mirrors without monitoring are WARNING and not blocking on error.
@@ -34,8 +36,8 @@ Version 2.02.178 -
   Enhance mirror log initialization for old mirror target.
   Skip private crypto and stratis devices.
   Skip frozen raid devices from scanning.
-  Activate RAID SubLVs on read_only_volume_list readwrite
-  Offer convenience type raid5_n converting to raid10
+  Activate RAID SubLVs on read_only_volume_list readwrite.
+  Offer convenience type raid5_n converting to raid10.
   Automatically avoid reading invalid snapshots during device scan.
   Ensure COW device is writable even for read-only thick snapshots.
   Support activation of component LVs in read-only mode.
@@ -53,20 +55,13 @@ Version 2.02.178 -
   Improve validation of created strings in vgimportclone.
   Add missing initialisation of mem pool in systemd generator.
   Do not reopen output streams for multithreaded users of liblvm.
-  Use versionsort to fix archive file expiry beyond 100000 files.
-  Add devices/use_aio, aio_max, aio_memory to configure AIO limits.
-  Support asynchronous I/O when scanning devices.
-  Detect asynchronous I/O capability in configure or accept --disable-aio.
-  Add AIO_SUPPORTED_CODE_PATH to indicate whether AIO may be used.
   Configure ensures /usr/bin dir is checked for dmpd tools.
   Restore pvmove support for wide-clustered active volumes (2.02.177).
   Avoid non-exclusive activation of exclusive segment types.
   Fix trimming sibling PVs when doing a pvmove of raid subLVs.
   Preserve exclusive activation during thin snaphost merge.
-  Suppress some repeated reads of the same disk data at the device layer.
   Avoid exceeding array bounds in allocation tag processing.
-  Refactor metadata reading code to use callback functions.
-  Move memory allocation for the key dev_reads into the device layer.
+  Add --lockopt to common options and add option to skip selected locks.
 
 Version 2.02.177 - 18th December 2017
 =====================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8fc3230..a40ca4e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.147 - 
-=====================================
+Version 1.02.147-rc1 - 24th May 2018
+====================================
   Reuse uname() result for mirror target.
   Recognize also mounted btrfs through dm_device_has_mounted_fs().
   Add missing log_error() into dm_stats_populate() returning 0.


