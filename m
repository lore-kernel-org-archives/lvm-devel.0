From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 11:39:39 +0000 (UTC)
Subject: master - thin: dmeventd plugin check number of failures
Message-ID: <20151029113939.5835160E62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=099466939e4d6bdbe4b105f6b052dee6fc99b9d4
Commit:        099466939e4d6bdbe4b105f6b052dee6fc99b9d4
Parent:        b3c81d02c974eda1c33afd88517d899e64aea24e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 11:52:11 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 12:14:20 2015 +0100

thin: dmeventd plugin check number of failures

If plugin's lvm command execution fails too often (>10 times),
there is no point to torture system more then necessary, just log
and drop monitoring in this case.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   19 ++++++++++++++++---
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 961aec5..63cb2cc 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.110 - 
 ======================================
+  Disable thin monitoring plugin when it fails too often (>10 times).
   Fix/restore parsing of empty field '-' when processing dmeventd event.
   Enhance dm_tree_node_size_changed() to recognize size reduction.
   Support exit on idle for dmenventd (1 hour).
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 888cc0c..7f422a9 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -18,6 +18,7 @@
 
 #include <sys/wait.h>
 #include <stdarg.h>
+#include <pthread.h>
 
 /* TODO - move this mountinfo code into library to be reusable */
 #ifdef __linux__
@@ -36,6 +37,8 @@
 
 #define UMOUNT_COMMAND "/bin/umount"
 
+#define MAX_FAILS	(10)
+
 #define THIN_DEBUG 0
 
 struct dso_state {
@@ -44,6 +47,7 @@ struct dso_state {
 	int data_percent_check;
 	uint64_t known_metadata_size;
 	uint64_t known_data_size;
+	unsigned fails;
 	char cmd_str[1024];
 };
 
@@ -157,7 +161,7 @@ static int _run(const char *cmd, ...)
 		argv = alloca(sizeof(const char *) * (argc + 1));
 
 		argv[0] = cmd;
-                va_start(ap, cmd);
+		va_start(ap, cmd);
 		while ((argv[++i] = va_arg(ap, const char *)));
 		va_end(ap);
 
@@ -245,7 +249,9 @@ static void _use_policy(struct dm_task *dmt, struct dso_state *state)
 		log_error("Failed to extend thin pool %s.",
 			  dm_task_get_name(dmt));
 		_umount(dmt);
-	}
+		state->fails++;
+	} else
+		state->fails = 0;
 }
 
 void process_event(struct dm_task *dmt,
@@ -270,7 +276,7 @@ void process_event(struct dm_task *dmt,
 	if (event & DM_EVENT_DEVICE_ERROR) {
 		/* Error -> no need to check and do instant resize */
 		_use_policy(dmt, state);
-		return;
+		goto out;
 	}
 
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
@@ -338,6 +344,13 @@ void process_event(struct dm_task *dmt,
 out:
 	if (tps)
 		dm_pool_free(state->mem, tps);
+
+	if (state->fails >= MAX_FAILS) {
+		log_warn("WARNING: Dropping monitoring of %s. "
+			 "lvm2 command fails too often (%u times in raw).",
+			 device, state->fails);
+		pthread_kill(pthread_self(), SIGALRM);
+	}
 }
 
 int register_device(const char *device,


