From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:01 -0500
Subject: master - man: missed --zero option for thin-pool creation
Message-ID: <201901211155.x0LBt1cW024403@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e8ea3c9a61b9d3bea50c7e5957660caf45a89dd9
Commit:        e8ea3c9a61b9d3bea50c7e5957660caf45a89dd9
Parent:        28f3125aaa1d7843d2ce01d25b172478b0836bba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 18 22:38:34 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:38:47 2019 +0100

man: missed --zero option for thin-pool creation

During man page rewrite this info got lost and remained
only for lvconvert. So restore it back for lvcreate.
---
 WHATS_NEW             |    1 +
 man/lvcreate.8_pregen |    1 +
 tools/args.h          |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5bb5797..74def38 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Restore missing man info lvcreate --zero for thin-pools.
   Drop misleadning comment for metadata minimum_io_size for VDO segment.
   Add device hints to reduce scanning.
   Introduce LVM_SUPPRESS_SYSLOG to suppress syslog usage by generator.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 2a5e05d..ff68447 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -2715,6 +2715,7 @@ answer yes. Use with extreme caution.
 Controls zeroing of the first 4KiB of data in the new LV.
 Default is \fBy\fP.
 Snapshot COW volumes are always zeroed.
+For thin pools, this controls zeroing of provisioned blocks.
 LV is not zeroed if the read only flag is set.
 Warning: trying to mount an unzeroed LV can cause the system to hang.
 .ad b
diff --git a/tools/args.h b/tools/args.h
index 522cccf..898e756 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -1464,6 +1464,7 @@ arg(zero_ARG, 'Z', "zero", bool_VAL, 0, 0,
     "Controls zeroing of the first 4KiB of data in the new LV.\n"
     "Default is \\fBy\\fP.\n"
     "Snapshot COW volumes are always zeroed.\n"
+    "For thin pools, this controls zeroing of provisioned blocks.\n"
     "LV is not zeroed if the read only flag is set.\n"
     "Warning: trying to mount an unzeroed LV can cause the system to hang.\n"
     "#pvcreate\n"


