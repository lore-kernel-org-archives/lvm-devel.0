From: David Teigland <teigland@sourceware.org>
Date: Thu, 14 Nov 2019 13:18:20 -0500
Subject: master - Revert "debug: enhance debug messages"
Message-ID: <86119.119111413181600827@us-mta-192.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=31a862a6be181764c3f505580916e11882b195a7
Commit:        31a862a6be181764c3f505580916e11882b195a7
Parent:        91df257b53849ca4206f4c3d45c71bff83c4a5ee
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 14 12:11:53 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 14 12:11:53 2019 -0600

Revert "debug: enhance debug messages"

This reverts commit e92d3bd1f75d335fba5303c433516ea4ebe5cab1.
---
 lib/label/hints.c |   42 ++++++++++++++++++++----------------------
 1 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index d913b68..45ab2ff 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -192,7 +192,7 @@ static int _hints_exists(void)
 	if (!stat(_hints_file, &buf))
 		return 1;
 	if (errno != ENOENT)
-		log_sys_debug("stat", _hints_file);
+		log_debug("hints_exist errno %d", errno);
 	return 0;
 }
 
@@ -203,7 +203,7 @@ static int _nohints_exists(void)
 	if (!stat(_nohints_file, &buf))
 		return 1;
 	if (errno != ENOENT)
-		log_sys_debug("stat", _nohints_file);
+		log_debug("nohints_exist errno %d", errno);
 	return 0;
 }
 
@@ -214,7 +214,7 @@ static int _newhints_exists(void)
 	if (!stat(_newhints_file, &buf))
 		return 1;
 	if (errno != ENOENT)
-		log_sys_debug("stat", _newhints_file);
+		log_debug("newhints_exist errno %d", errno);
 	return 0;
 }
 
@@ -225,7 +225,7 @@ static int _touch_newhints(void)
 	if (!(fp = fopen(_newhints_file, "w")))
 		return_0;
 	if (fclose(fp))
-		log_sys_debug("fclose", _newhints_file);
+		stack;
 	return 1;
 }
 
@@ -236,7 +236,7 @@ static int _touch_nohints(void)
 	if (!(fp = fopen(_nohints_file, "w")))
 		return_0;
 	if (fclose(fp))
-		log_sys_debug("fclose", _nohints_file);
+		stack;
 	return 1;
 }
 
@@ -247,26 +247,26 @@ static int _touch_hints(void)
 	if (!(fp = fopen(_hints_file, "w")))
 		return_0;
 	if (fclose(fp))
-		log_sys_debug("fclose", _hints_file);
+		stack;
 	return 1;
 }
 
 static void _unlink_nohints(void)
 {
-	if (unlink(_nohints_file) && errno != ENOENT)
-		log_sys_debug("unlink", _nohints_file);
+	if (unlink(_nohints_file))
+		log_debug("unlink_nohints errno %d", errno);
 }
 
 static void _unlink_hints(void)
 {
-	if (unlink(_hints_file) && errno != ENOENT)
-		log_sys_debug("unlink", _hints_file);
+	if (unlink(_hints_file))
+		log_debug("unlink_hints errno %d", errno);
 }
 
 static void _unlink_newhints(void)
 {
-	if (unlink(_newhints_file) && errno != ENOENT)
-		log_sys_debug("unlink", _newhints_file);
+	if (unlink(_newhints_file))
+		log_debug("unlink_newhints errno %d", errno);
 }
 
 static int _clear_hints(struct cmd_context *cmd)
@@ -275,7 +275,7 @@ static int _clear_hints(struct cmd_context *cmd)
 	time_t t;
 
 	if (!(fp = fopen(_hints_file, "w"))) {
-		log_warn("WARNING: Failed to clear hint file.");
+		log_warn("Failed to clear hint file.");
 		/* shouldn't happen, but try to unlink in case */
 		_unlink_hints();
 		return 0;
@@ -286,10 +286,10 @@ static int _clear_hints(struct cmd_context *cmd)
 	fprintf(fp, "# Created empty by %s pid %d %s", cmd->name, getpid(), ctime(&t));
 
 	if (fflush(fp))
-		log_sys_debug("fflush", _hints_file);
+		log_debug("clear_hints flush errno %d", errno);
 
 	if (fclose(fp))
-		log_sys_debug("fclose", _hints_file);
+		log_debug("clear_hints close errno %d", errno);
 
 	return 1;
 }
@@ -313,7 +313,7 @@ static int _lock_hints(struct cmd_context *cmd, int mode, int nonblock)
 
 	fd = open(_hints_file, O_RDWR);
 	if (fd < 0) {
-		log_sys_debug("open", _hints_file);
+		log_debug("lock_hints open errno %d", errno);
 		return 0;
 	}
 
@@ -641,13 +641,10 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	int ret = 1;
 	int i;
 
-	if (!(fp = fopen(_hints_file, "r"))) {
-		if (errno != ENOENT)
-			log_sys_debug("fopen", _hints_file);
+	if (!(fp = fopen(_hints_file, "r")))
 		return 0;
-	}
 
-	log_debug("Reading hint file %s.", _hints_file);
+	log_debug("Reading hint file");
 
 	for (i = 0; i < HINT_LINE_WORDS; i++)
 		split[i] = NULL;
@@ -776,7 +773,7 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	}
 
 	if (fclose(fp))
-		log_sys_debug("fclose", _hints_file);
+		stack;
 
 	if (!ret)
 		return 0;
@@ -1357,3 +1354,4 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 
 	return 1;
 }
+



