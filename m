From: David Teigland <teigland@sourceware.org>
Date: Mon, 4 Mar 2019 13:23:36 -0500
Subject: master - io: increase the default io memory from 4 to 8 MiB
Message-ID: <201903041823.x24INabh014619@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7edbf8a441fab4518959523e3e726bcd66b2c6a8
Commit:        7edbf8a441fab4518959523e3e726bcd66b2c6a8
Parent:        3584e0c0d5e5992a3c93e03de8b6042de0853ef2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 4 11:18:34 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 4 12:14:06 2019 -0600

io: increase the default io memory from 4 to 8 MiB

This is the default bcache size that is created at the
start of the command.  It needs to be large enough to
hold a single copy of metadata for a given VG, or the
VG cannot be read or written (since the entire VG would
not fit into available memory.)

Increasing the default reduces the chances of anyone
needing to increase the default to use their VG.

The size can be set in lvm.conf global/io_memory_size;
the lower limit is 4 MiB and the upper limit is 128 MiB.
---
 lib/config/defaults.h |    2 +-
 lib/label/label.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index ee6ca3a..3b8d341 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -314,6 +314,6 @@
 
 #define DEFAULT_HINTS "all"
 
-#define DEFAULT_IO_MEMORY_SIZE_KB 4096
+#define DEFAULT_IO_MEMORY_SIZE_KB 8192
 
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/label/label.c b/lib/label/label.c
index 174139e..f356e18 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -794,7 +794,7 @@ out:
  * the metadata size.)
  */
 
-#define MIN_BCACHE_BLOCKS 32    /* 4MB, currently matches DEFAULT_IO_MEMORY_SIZE_KB */
+#define MIN_BCACHE_BLOCKS 32    /* 4MB */
 #define MAX_BCACHE_BLOCKS 1024
 
 static int _setup_bcache(int num_devs)


