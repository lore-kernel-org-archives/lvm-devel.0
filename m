From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:22 +0000 (UTC)
Subject: master - lvmetad: clear the disabled flag in lvmetad
Message-ID: <20160419164922.D6C0E6107E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e380864e5b6e0773ddf48189b6563c3033e6354
Commit:        1e380864e5b6e0773ddf48189b6563c3033e6354
Parent:        04a83148cea3b3c7ec7f6ffccb4d84e2372c3f4a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 6 15:37:52 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 09:41:18 2016 -0500

lvmetad: clear the disabled flag in lvmetad

After a device rescan that repopulates lvmetad,
if no reason for disabling lvmetad was seen
(lvm1 metadata or duplicate PVs), then clear
the disabled flag in lvmetad.  This allows
commands to resume using the lvmetad cache
after the cause for disabling it has been removed.
---
 lib/cache/lvmetad.c |   37 +++++++++++++++++++++++++++++++++++++
 lib/cache/lvmetad.h |    2 ++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index dba7e5b..bcf6f93 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -37,6 +37,8 @@ static char *_lvmetad_token = NULL;
 static const char *_lvmetad_socket = NULL;
 static struct cmd_context *_lvmetad_cmd = NULL;
 
+static int _found_lvm1_metadata = 0;
+
 static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg);
 
 static uint64_t _monotonic_seconds(void)
@@ -1597,6 +1599,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 			log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
 			lvmetad_set_disabled(cmd, "LVM1");
+			_found_lvm1_metadata = 1;
 			return NULL;
 		}
 
@@ -1720,6 +1723,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 
 		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
 		lvmetad_set_disabled(cmd, "LVM1");
+		_found_lvm1_metadata = 1;
 
 		if (ignore_obsolete)
 			return 1;
@@ -1795,6 +1799,7 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 	daemon_reply reply;
 	int r = 1;
 	char *future_token;
+	const char *reason;
 	int was_silent;
 	int replacing_other_update = 0;
 	int replaced_update = 0;
@@ -1880,6 +1885,16 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 	if (!_token_update(NULL))
 		return 0;
 
+	/*
+	 * If lvmetad is disabled, and no lvm1 metadata was seen and no
+	 * duplicate PVs were seen, then re-enable lvmetad.
+	 */
+	if (lvmetad_is_disabled(cmd, &reason) &&
+	    !lvmcache_found_duplicate_pvs() && !_found_lvm1_metadata) {
+		log_debug_lvmetad("Enabling lvmetad which was previously disabled.");
+		lvmetad_clear_disabled(cmd);
+	}
+
 	return r;
 }
 
@@ -2285,6 +2300,28 @@ void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
 	daemon_reply_destroy(reply);
 }
 
+void lvmetad_clear_disabled(struct cmd_context *cmd)
+{
+	daemon_reply reply;
+
+	if (!_lvmetad_use)
+		return;
+
+	log_debug_lvmetad("lvmetad send disabled 0");
+
+	reply = daemon_send_simple(_lvmetad, "set_global_info",
+				   "token = %s", "skip",
+				   "global_disable = " FMTd64, (int64_t)0,
+				   NULL);
+	if (reply.error)
+		log_error("Failed to send message to lvmetad %d", reply.error);
+
+	if (strcmp(daemon_reply_str(reply, "response", ""), "OK"))
+		log_error("Failed response from lvmetad.");
+
+	daemon_reply_destroy(reply);
+}
+
 int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
 {
 	daemon_reply reply;
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 76e8fd2..9ae3f26 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -174,6 +174,7 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
 
 int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason);
 void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason);
+void lvmetad_clear_disabled(struct cmd_context *cmd);
 
 #  else		/* LVMETAD_SUPPORT */
 
@@ -207,6 +208,7 @@ void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason);
 #    define lvmetad_token_matches(cmd) (1)
 #    define lvmetad_is_disabled(cmd, reason) (0)
 #    define lvmetad_set_disabled(cmd, reason) do { } while (0)
+#    define lvmetad_clear_disabled(cmd) do { } while (0)
 
 #  endif	/* LVMETAD_SUPPORT */
 


