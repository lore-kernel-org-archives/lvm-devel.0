From: David Teigland <teigland@sourceware.org>
Date: Mon, 4 Mar 2019 12:27:31 -0500
Subject: stable-2.02 - io: increase the default io memory from 4 to 8 MiB
Message-ID: <201903041727.x24HRVY7005072@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=590a1ebcf78b8aae2a1e5ebaba1ac24a54435690
Commit:        590a1ebcf78b8aae2a1e5ebaba1ac24a54435690
Parent:        863a2e693ee95b95463d60fa8b21f4c7c084292c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 4 11:18:34 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 4 11:18:34 2019 -0600

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
index 3b4438a..9e398d7 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -269,6 +269,6 @@
 
 #define DEFAULT_SCAN_LVS 0
 
-#define DEFAULT_IO_MEMORY_SIZE_KB 4096
+#define DEFAULT_IO_MEMORY_SIZE_KB 8192
 
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/label/label.c b/lib/label/label.c
index e96a7fe..4f8e135 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -791,7 +791,7 @@ out:
  * the metadata size.)
  */
 
-#define MIN_BCACHE_BLOCKS 32    /* 4MB, currently matches DEFAULT_IO_MEMORY_SIZE_KB */
+#define MIN_BCACHE_BLOCKS 32    /* 4MB */
 #define MAX_BCACHE_BLOCKS 1024
 
 static int _setup_bcache(int num_devs)


