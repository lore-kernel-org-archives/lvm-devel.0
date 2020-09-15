From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:13 +0000 (GMT)
Subject: master - hints: enhance debug with log_sys_debug
Message-ID: <20200915212113.E40023857828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d344b4ac05cab54d65cc5380afeb7931873d6f0
Commit:        6d344b4ac05cab54d65cc5380afeb7931873d6f0
Parent:        187cc8d344ed806194ac7a8ce7582d043cf1d673
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 21:33:30 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 22:52:25 2020 +0200

hints: enhance debug with log_sys_debug

---
 lib/label/hints.c | 43 ++++++++++++++++++++++++++++---------------
 1 file changed, 28 insertions(+), 15 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 4177c678f..5ca2c3638 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -190,8 +190,10 @@ static int _hints_exists(void)
 
 	if (!stat(_hints_file, &buf))
 		return 1;
+
 	if (errno != ENOENT)
-		log_debug("hints_exist errno %d", errno);
+		log_sys_debug("stat", _hints_file);
+
 	return 0;
 }
 
@@ -201,8 +203,10 @@ static int _nohints_exists(void)
 
 	if (!stat(_nohints_file, &buf))
 		return 1;
+
 	if (errno != ENOENT)
-		log_debug("nohints_exist errno %d", errno);
+		log_sys_debug("stat", _nohints_file);
+
 	return 0;
 }
 
@@ -212,8 +216,10 @@ static int _newhints_exists(void)
 
 	if (!stat(_newhints_file, &buf))
 		return 1;
+
 	if (errno != ENOENT)
-		log_debug("newhints_exist errno %d", errno);
+		log_sys_debug("stat", _newhints_file);
+
 	return 0;
 }
 
@@ -243,29 +249,33 @@ static int _touch_hints(void)
 {
 	FILE *fp;
 
-	if (!(fp = fopen(_hints_file, "w")))
-		return_0;
+	if (!(fp = fopen(_hints_file, "w"))) {
+		log_sys_debug("fopen", _hints_file);
+		return 0;
+	}
 	if (fclose(fp))
-		stack;
+		log_sys_debug("fclose", _hints_file);
+
 	return 1;
 }
 
 static void _unlink_nohints(void)
 {
 	if (unlink(_nohints_file))
-		log_debug("unlink_nohints errno %d", errno);
+		log_sys_debug("unlink", _nohints_file);
 }
 
+
 static void _unlink_hints(void)
 {
 	if (unlink(_hints_file))
-		log_debug("unlink_hints errno %d", errno);
+		log_sys_debug("unlink", _hints_file);
 }
 
 static void _unlink_newhints(void)
 {
 	if (unlink(_newhints_file))
-		log_debug("unlink_newhints errno %d", errno);
+		log_sys_debug("unlink", _newhints_file);
 }
 
 static int _clear_hints(struct cmd_context *cmd)
@@ -312,7 +322,7 @@ static int _lock_hints(struct cmd_context *cmd, int mode, int nonblock)
 
 	fd = open(_hints_file, O_RDWR);
 	if (fd < 0) {
-		log_debug("lock_hints open errno %d", errno);
+		log_sys_debug("open", _hints_file);
 		return 0;
 	}
 
@@ -324,7 +334,8 @@ static int _lock_hints(struct cmd_context *cmd, int mode, int nonblock)
 	}
 
 	if (close(fd))
-		stack;
+		log_sys_debug("close", _hints_file);
+
 	return 0;
 }
 
@@ -434,7 +445,7 @@ static int _dev_in_hint_hash(struct cmd_context *cmd, struct device *dev)
 		return 0;
 
 	if (!dev_get_size(dev, &devsize) || !devsize)
-		return 0;
+		return_0;
 
 	return 1;
 }
@@ -799,7 +810,7 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	}
 
 	if (fclose(fp))
-		stack;
+		log_sys_debug("fclose", _hints_file);
 
 	if (!ret)
 		return 0;
@@ -1020,7 +1031,7 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 
  out_close:
 	if (fclose(fp))
-		stack;
+		log_sys_debug("fclose", _hints_file);
 
  out_unlock:
 	/* get_hints() took ex lock before returning with newhints set */
@@ -1118,8 +1129,10 @@ void pvscan_recreate_hints_begin(struct cmd_context *cmd)
 
 	log_debug("pvscan_recreate_hints_begin");
 
-	if (!_touch_hints())
+	if (!_touch_hints()) {
+		stack;
 		return;
+	}
 
 	/* limit potential delay blocking on hints lock next */
 	if (!_touch_nohints())


