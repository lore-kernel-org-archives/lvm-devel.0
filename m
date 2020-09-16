From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Sep 2020 20:18:30 +0000 (GMT)
Subject: master - hints: enhance debug messages
Message-ID: <20200916201830.A3C2138618AA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46f43589d00d0bcb74028df602897509db7d93b9
Commit:        46f43589d00d0bcb74028df602897509db7d93b9
Parent:        491eb258327ca07d1fe98e8bb344f63e14d97c0a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 16 14:46:50 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 16 15:01:10 2020 -0500

hints: enhance debug messages

---
 lib/label/hints.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 5ca2c3638..4a51ec918 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -192,7 +192,7 @@ static int _hints_exists(void)
 		return 1;
 
 	if (errno != ENOENT)
-		log_sys_debug("stat", _hints_file);
+		log_debug("hints_exist errno %d %s", errno, _hints_file);
 
 	return 0;
 }
@@ -205,7 +205,7 @@ static int _nohints_exists(void)
 		return 1;
 
 	if (errno != ENOENT)
-		log_sys_debug("stat", _nohints_file);
+		log_debug("nohints_exist errno %d %s", errno, _nohints_file);
 
 	return 0;
 }
@@ -218,7 +218,7 @@ static int _newhints_exists(void)
 		return 1;
 
 	if (errno != ENOENT)
-		log_sys_debug("stat", _newhints_file);
+		log_debug("newhints_exist errno %d %s", errno, _newhints_file);
 
 	return 0;
 }
@@ -250,11 +250,11 @@ static int _touch_hints(void)
 	FILE *fp;
 
 	if (!(fp = fopen(_hints_file, "w"))) {
-		log_sys_debug("fopen", _hints_file);
+		log_debug("touch_hints errno %d %s", errno, _hints_file);
 		return 0;
 	}
 	if (fclose(fp))
-		log_sys_debug("fclose", _hints_file);
+		log_debug("touch_hints close errno %d %s", errno, _hints_file);
 
 	return 1;
 }
@@ -262,20 +262,20 @@ static int _touch_hints(void)
 static void _unlink_nohints(void)
 {
 	if (unlink(_nohints_file))
-		log_sys_debug("unlink", _nohints_file);
+		log_debug("unlink_nohints errno %d %s", errno, _nohints_file);
 }
 
 
 static void _unlink_hints(void)
 {
 	if (unlink(_hints_file))
-		log_sys_debug("unlink", _hints_file);
+		log_debug("unlink_hints errno %d %s", errno, _hints_file);
 }
 
 static void _unlink_newhints(void)
 {
 	if (unlink(_newhints_file))
-		log_sys_debug("unlink", _newhints_file);
+		log_debug("unlink_newhints errno %d %s", errno, _newhints_file);
 }
 
 static int _clear_hints(struct cmd_context *cmd)
@@ -295,10 +295,10 @@ static int _clear_hints(struct cmd_context *cmd)
 	fprintf(fp, "# Created empty by %s pid %d %s", cmd->name, getpid(), ctime(&t));
 
 	if (fflush(fp))
-		log_debug("clear_hints flush errno %d", errno);
+		log_debug("clear_hints flush errno %d %s", errno, _hints_file);
 
 	if (fclose(fp))
-		log_debug("clear_hints close errno %d", errno);
+		log_debug("clear_hints close errno %d %s", errno, _hints_file);
 
 	return 1;
 }
@@ -322,7 +322,7 @@ static int _lock_hints(struct cmd_context *cmd, int mode, int nonblock)
 
 	fd = open(_hints_file, O_RDWR);
 	if (fd < 0) {
-		log_sys_debug("open", _hints_file);
+		log_debug("lock_hints open errno %d %s", errno, _hints_file);
 		return 0;
 	}
 
@@ -334,7 +334,7 @@ static int _lock_hints(struct cmd_context *cmd, int mode, int nonblock)
 	}
 
 	if (close(fd))
-		log_sys_debug("close", _hints_file);
+		log_debug("lock_hints close errno %d %s", errno, _hints_file);
 
 	return 0;
 }
@@ -810,7 +810,7 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	}
 
 	if (fclose(fp))
-		log_sys_debug("fclose", _hints_file);
+		log_debug("read_hint_file close errno %d", errno);
 
 	if (!ret)
 		return 0;
@@ -1031,7 +1031,7 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 
  out_close:
 	if (fclose(fp))
-		log_sys_debug("fclose", _hints_file);
+		log_debug("write_hint_file close errno %d", errno);
 
  out_unlock:
 	/* get_hints() took ex lock before returning with newhints set */


