From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Oct 2013 13:18:14 +0000 (UTC)
Subject: master - release 2.02.103
Message-ID: <20131004131814.300DB60D12@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6d1898d16cb21a7e3a1629b1229ab267c04d7c77
Commit:        6d1898d16cb21a7e3a1629b1229ab267c04d7c77
Parent:        0d03503a453f91cee09fb3a1664d2136d58ac751
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 4 14:17:30 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 4 14:17:30 2013 +0100

release 2.02.103

52 files changed, 598 insertions(+), 264 deletions(-)
---
 VERSION               |    2 +-
 VERSION_DM            |    2 +-
 WHATS_NEW             |   12 +++++++-----
 WHATS_NEW_DM          |    4 ++--
 conf/example.conf.in  |    2 +-
 lib/config/defaults.h |    6 +++---
 6 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/VERSION b/VERSION
index d1e7c0e..f4bbdb9 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.103(2)-git (2013-09-23)
+2.02.103(2)-git (2013-10-04)
diff --git a/VERSION_DM b/VERSION_DM
index 6c755b8..f4e8c0b 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.82-git (2013-09-23)
+1.02.82-git (2013-10-04)
diff --git a/WHATS_NEW b/WHATS_NEW
index 0b71786..d69e74e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,14 +1,16 @@
-Version 2.02.103 - 
-======================================
+Version 2.02.103 - 4th October 2013
+===================================
+  Ensure vgid matches before removing vgname entry from lvmetad cache.
   Add --ignoreskippedcluster for exit status success when clustered VGs skipped.
-  Fix 3min udev timeout so that it is applied for all LVM volumes.
+  Fix 3 minute udev timeout so that it is applied for all LVM volumes.
+  Fix thin/raid & activation config defaults with configure --disable-devmapper.
   Fix RAID calculation for sufficient allocatable space.
-  Conversion from linear to mirror or RAID1 now honors mirror_segtype_default.
+  lvconvert from linear to mirror or RAID1 now honors mirror_segtype_default.
   Add thin-performance configuration profile.
   Add lvm.conf allocation/thin_pool_chunk_size_policy option.
   Fix contiguous & cling allocation policies for parity RAID.  (2.02.100)
   Have lvmconf --enable/disable-cluster reset/set use_lvmetad.
-  Don't install separate command symlink in binary directory for 'lvm devtypes'.
+  Don't install separate command symlink for 'lvm devtypes'. (2.02.101)
   Add seg_size_pe field to reports.
   Support start+length notation with command line PE ranges.
   Exit cleanly with message when pvmove cannot restart because LV is inactive.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dfc2d89..9dfd9bf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.82 - 
-=====================================
+Version 1.02.82 - 4th October 2013
+==================================
   Define symbolic names for subsystem udev flags in libdevmapper for easier use.
   Make subsystem udev rules responsible for importing DM_SUBSYSTEM_UDEV_FLAG*.
 
diff --git a/conf/example.conf.in b/conf/example.conf.in
index e0f8be8..ae571b6 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -255,7 +255,7 @@ allocation {
     # Specify chunk size calculation policy for thin pool volumes.
     # Possible options are:
     # "generic"        - if thin_pool_chunk_size is defined, use it.
-    #                    Otherwise, calcucate the chunk size based on
+    #                    Otherwise, calculate the chunk size based on
     #                    estimation and device hints exposed in sysfs:
     #                    the minimum_io_size. The chunk size is always
     #                    at least 64KiB.
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index fc2d4dc..bd7a40a 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -141,9 +141,9 @@
 #  define DEFAULT_ACTIVATION 0
 #endif
 
-# define DEFAULT_RESERVED_MEMORY 8192
-#  define DEFAULT_RESERVED_STACK 64 /* KB */
-#  define DEFAULT_PROCESS_PRIORITY -18
+#define DEFAULT_RESERVED_MEMORY 8192
+#define DEFAULT_RESERVED_STACK 64 /* KB */
+#define DEFAULT_PROCESS_PRIORITY -18
 
 #define DEFAULT_AUTO_SET_ACTIVATION_SKIP 1
 #define DEFAULT_USE_LINEAR_TARGET 1


