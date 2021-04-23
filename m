From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:57 +0000 (GMT)
Subject: main - cov: explicitely ignore return value
Message-ID: <20210423210557.6512E394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=395ce6c2bb034ed64479fcf4bc8974615a0f4bb8
Commit:        395ce6c2bb034ed64479fcf4bc8974615a0f4bb8
Parent:        2b3dcd754ff99987661c47ce57a660bfcfed3ffb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 16:49:34 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: explicitely ignore return value

---
 daemons/lvmlockd/lvmlockd-core.c | 6 +++---
 lib/device/device_id.c           | 2 +-
 lib/label/label.c                | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 094491029..cd8485bb0 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4968,7 +4968,7 @@ static void *client_thread_main(void *arg_in)
 	}
 out:
 	if (adopt_opt && lock_acquire_written)
-		unlink(adopt_file);
+		(void) unlink(adopt_file);
 	return NULL;
 }
 
@@ -5740,13 +5740,13 @@ static void adopt_locks(void)
 	if (count_start_fail || count_adopt_fail)
 		goto fail;
 
-	unlink(adopt_file);
+	(void) unlink(adopt_file);
 	write_adopt_file();
 	log_debug("adopt_locks done");
 	return;
 
 fail:
-	unlink(adopt_file);
+	(void) unlink(adopt_file);
 	log_error("adopt_locks failed, reset host");
 }
 
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 9fd22692c..6fa3b0360 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -679,7 +679,7 @@ int device_ids_write(struct cmd_context *cmd)
 		goto out;
 	}
 
-	unlink(tmppath); /* in case a previous file was left */
+	(void) unlink(tmppath); /* in case a previous file was left */
 
 	if (!(fp = fopen(tmppath, "w+"))) {
 		log_warn("Cannot open tmp devices_file to write.");
diff --git a/lib/label/label.c b/lib/label/label.c
index f305ac735..203c5b6bb 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1657,7 +1657,7 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 		_scan_dev_close(dev);
 
 		dev->flags |= DEV_BCACHE_WRITE;
-		label_scan_open(dev);
+		(void) label_scan_open(dev); /* checked later */
 	}
 
 	if (dev->bcache_di < 0) {


