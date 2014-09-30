From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 30 Sep 2014 14:14:47 +0000 (UTC)
Subject: master - filters: refresh filters when lvmetad use is toggled
Message-ID: <20140930141447.E71B260E49@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5f01dad224929ea39fd3a53753b8341028017b8
Commit:        a5f01dad224929ea39fd3a53753b8341028017b8
Parent:        c2981cf921c5808b6e9b21d72a988e9b22f2d4a7
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 30 16:08:05 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 30 16:08:05 2014 +0200

filters: refresh filters when lvmetad use is toggled

We need to use proper filter chain when we disable lvmetad use
explicitly in the code by calling lvmetad_set_active(0) while
overriding existing configuration. We need to reinitialize filters
in this case so proper filter chain is used. The same applies
for the other way round - when we enable lvmetad use explicitly in
the code (though this is not yet used).
---
 lib/cache/lvmetad.c        |    4 +++-
 lib/cache/lvmetad.h        |    4 ++--
 lib/commands/toolcontext.c |   14 ++++++++------
 tools/lvchange.c           |    2 +-
 tools/lvmcmdline.c         |    2 +-
 tools/vgchange.c           |    2 +-
 tools/vgck.c               |    2 +-
 7 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 5589cfd..5612c1b 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -98,11 +98,13 @@ int lvmetad_active(void)
 	return _lvmetad_connected;
 }
 
-void lvmetad_set_active(int active)
+void lvmetad_set_active(struct cmd_context *cmd, int active)
 {
 	_lvmetad_use = active;
 	if (!active && lvmetad_active())
 		lvmetad_disconnect();
+	if (cmd && !refresh_filters(cmd))
+		stack;
 }
 
 /*
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index d9aa77f..2cd738e 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -37,7 +37,7 @@ void lvmetad_init(struct cmd_context *);
 /*
  * Override the use of lvmetad for retrieving scan results and metadata.
  */
-void lvmetad_set_active(int);
+void lvmetad_set_active(struct cmd_context *, int);
 
 /*
  * Configure the socket that lvmetad_init will use to connect to the daemon.
@@ -161,7 +161,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 
 #    define lvmetad_init(cmd)	do { } while (0)
 #    define lvmetad_disconnect()	do { } while (0)
-#    define lvmetad_set_active(a)	do { } while (0)
+#    define lvmetad_set_active(cmd, a)	do { } while (0)
 #    define lvmetad_set_socket(a)	do { } while (0)
 #    define lvmetad_used()	(0)
 #    define lvmetad_socket_present()	(0)
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 7c77e54..e72691d 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -463,9 +463,9 @@ static int _process_config(struct cmd_context *cmd)
 	    find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL)) {
 		log_warn("WARNING: configuration setting use_lvmetad overridden to 0 due to locking_type 3. "
 			 "Clustered environment not supported by lvmetad yet.");
-		lvmetad_set_active(0);
+		lvmetad_set_active(NULL, 0);
 	} else
-		lvmetad_set_active(find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL));
+		lvmetad_set_active(NULL, find_config_tree_bool(cmd, global_use_lvmetad_CFG, NULL));
 
 	lvmetad_init(cmd);
 
@@ -972,8 +972,10 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 			log_verbose("Failed to create usable device filter.");
 			goto bad;
 		}
-	} else
+	} else {
 		filter_components[0] = cmd->lvmetad_filter;
+		cmd->lvmetad_filter = NULL;
+	}
 
 	/* filter component 1 */
 	if ((cn = find_config_tree_node(cmd, devices_filter_CFG, NULL))) {
@@ -1036,7 +1038,7 @@ bad:
 	}
 
 	/* if lvmetad is used, the cmd->lvmetad_filter is separate */
-	if (lvmetad_used() && cmd->lvmetad_filter)
+	if (cmd->lvmetad_filter)
 		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
 
 	return 0;
@@ -1659,7 +1661,7 @@ static void _destroy_filters(struct cmd_context *cmd)
 	* is actually a part of cmd->filter and as such, it
 	* will be destroyed together with cmd->filter.
 	*/
-	if (lvmetad_used() && cmd->lvmetad_filter) {
+	if (cmd->lvmetad_filter) {
 		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
 		cmd->lvmetad_filter = NULL;
 	}
@@ -1826,7 +1828,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	* is actually a part of cmd->filter and as such, it
 	* will be destroyed together with cmd->filter.
 	*/
-	if (lvmetad_used() && cmd->lvmetad_filter)
+	if (cmd->lvmetad_filter)
 		cmd->lvmetad_filter->destroy(cmd->lvmetad_filter);
 	if (cmd->filter)
 		cmd->filter->destroy(cmd->filter);
diff --git a/tools/lvchange.c b/tools/lvchange.c
index fb3df50..3a0e848 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1131,7 +1131,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 			 * direct activation instead of autoactivation.
 			*/
 			log_warn("lvmetad is not active yet, using direct activation during sysinit");
-			lvmetad_set_active(0);
+			lvmetad_set_active(cmd, 0);
 		} else if (lvmetad_active()) {
 			/*
 			 * If lvmetad is active already, we want
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index bb496d0..4697b24 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1342,7 +1342,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, readonly_ARG)) {
 		locking_type = 5;
 		if (lvmetad_used()) {
-			lvmetad_set_active(0);
+			lvmetad_set_active(cmd, 0);
 			log_verbose("Disabling use of lvmetad because read-only is set.");
 		}
 	} else if (arg_count(cmd, nolocking_ARG))
diff --git a/tools/vgchange.c b/tools/vgchange.c
index dfb1251..9a9fe48 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -689,7 +689,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 			 * direct activation instead of autoactivation.
 			 */
 			log_warn("lvmetad is not active yet, using direct activation during sysinit");
-			lvmetad_set_active(0);
+			lvmetad_set_active(cmd, 0);
 		} else if (lvmetad_active()) {
 			/*
 			 * If lvmetad is active already, we want
diff --git a/tools/vgck.c b/tools/vgck.c
index 4ad045a..b9d05ae 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -37,7 +37,7 @@ static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 
 int vgck(struct cmd_context *cmd, int argc, char **argv)
 {
-	lvmetad_set_active(0);
+	lvmetad_set_active(cmd, 0);
 	return process_each_vg(cmd, argc, argv, 0, NULL,
 			       &vgck_single);
 }


