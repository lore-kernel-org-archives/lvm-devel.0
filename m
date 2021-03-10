From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:35 +0000 (GMT)
Subject: main - debug: more tracing
Message-ID: <20210310003635.68ADA385802B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=75037bee5d92023718a1b9f0725152b4512e4349
Commit:        75037bee5d92023718a1b9f0725152b4512e4349
Parent:        d01c17ff229beb1cfe9d6331fbd35637866412ec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 10 01:26:30 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:27:13 2021 +0100

debug: more tracing

Check result of device_ids_write() and at least provide stack;
---
 lib/device/device_id.c | 10 ++++++----
 lib/label/label.c      |  6 ++++--
 tools/toollib.c        |  3 ++-
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 4b7214b60..74edae05c 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -689,7 +689,8 @@ int device_ids_write(struct cmd_context *cmd)
 	}
 
 	if ((dir_fd = open(dirpath, O_RDONLY)) < 0) {
-		fclose(fp);
+		if (fclose(fp))
+                        log_sys_debug("fclose", tmpfile);
 		ret = 0;
 		goto out;
 	}
@@ -782,9 +783,10 @@ static void _device_ids_update_try(struct cmd_context *cmd)
 	if (!lock_devices_file_try(cmd, LOCK_EX, &held)) {
 		log_debug("Skip devices file update (busy).");
 	} else {
-		if (device_ids_version_unchanged(cmd))
-			device_ids_write(cmd);
-		else
+		if (device_ids_version_unchanged(cmd)) {
+			if (!device_ids_write(cmd))
+				stack;
+		} else
 			log_debug("Skip devices file update (changed).");
 	}
 	if (!held)
diff --git a/lib/label/label.c b/lib/label/label.c
index 8cbed7dd8..f305ac735 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -582,7 +582,8 @@ retry_open:
 
 	if (di == -1) {
 		log_error("Failed to set bcache fd.");
-		close(fd);
+		if (close(fd))
+			log_sys_debug("close", name);
 		dev->bcache_fd = -1;
 		return 0;
 	}
@@ -1592,7 +1593,8 @@ int label_scan_reopen_rw(struct device *dev)
 	if (!bcache_change_fd(dev->bcache_di, fd)) {
 		log_error("Failed to change to rw fd %s di %d fd %d.",
 			  dev_name(dev), dev->bcache_di, fd);
-		close(fd);
+		if (close(fd))
+			log_sys_debug("close", dev_name(dev));
 		return 0;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index c8540b005..b9be54ebb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5770,7 +5770,8 @@ do_command:
 	}
 
 	/* TODO: when vgcreate uses only existing PVs this doesn't change and can be skipped */
-	device_ids_write(cmd);
+	if (!device_ids_write(cmd))
+		stack;
 
 	/*
 	 * Don't keep devs open excl in bcache because the excl will prevent


