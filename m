From: David Teigland <teigland@sourceware.org>
Date: Thu, 11 Jul 2019 12:42:17 -0400
Subject: master - scan: remove unused arg to setup_bcache
Message-ID: <201907111642.x6BGgHh7028642@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2b88f271512c56737e27bbdfbd0e0b6891b4cd0
Commit:        d2b88f271512c56737e27bbdfbd0e0b6891b4cd0
Parent:        1b63a219f4f9d7f2f6c5086375b96c3bd892a1a0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 9 13:16:26 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jul 9 13:16:26 2019 -0500

scan: remove unused arg to setup_bcache

---
 lib/label/label.c |   17 +++++------------
 1 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 185e51b..8b841f6 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -798,13 +798,6 @@ out:
 }
 
 /*
- * num_devs is the number of devices the caller is going to scan.
- * When 0 the caller doesn't know, and we use the default cache size.
- * When non-zero, allocate at least num_devs bcache blocks.
- * num_devs doesn't really tell us how many bcache blocks we'll use
- * because it includes lvm devs and non-lvm devs, and each lvm dev
- * will often use a number of bcache blocks.
- *
  * We don't know ahead of time if we will find some VG metadata 
  * that is larger than the total size of the bcache, which would
  * prevent us from reading/writing the VG since we do not dynamically
@@ -817,7 +810,7 @@ out:
 #define MIN_BCACHE_BLOCKS 32    /* 4MB */
 #define MAX_BCACHE_BLOCKS 1024
 
-static int _setup_bcache(int num_devs)
+static int _setup_bcache(void)
 {
 	struct io_engine *ioe = NULL;
 	int iomem_kb = io_memory_size();
@@ -955,7 +948,7 @@ int label_scan(struct cmd_context *cmd)
 	dev_iter_destroy(iter);
 
 	if (!scan_bcache) {
-		if (!_setup_bcache(dm_list_size(&all_devs)))
+		if (!_setup_bcache())
 			return 0;
 	}
 
@@ -1105,7 +1098,7 @@ int label_scan_devs(struct cmd_context *cmd, struct dev_filter *f, struct dm_lis
 	struct device_list *devl;
 
 	if (!scan_bcache) {
-		if (!_setup_bcache(0))
+		if (!_setup_bcache())
 			return 0;
 	}
 
@@ -1132,7 +1125,7 @@ int label_scan_devs_rw(struct cmd_context *cmd, struct dev_filter *f, struct dm_
 	struct device_list *devl;
 
 	if (!scan_bcache) {
-		if (!_setup_bcache(0))
+		if (!_setup_bcache())
 			return 0;
 	}
 
@@ -1278,7 +1271,7 @@ int label_read(struct device *dev)
 int label_scan_setup_bcache(void)
 {
 	if (!scan_bcache) {
-		if (!_setup_bcache(0))
+		if (!_setup_bcache())
 			return 0;
 	}
 


