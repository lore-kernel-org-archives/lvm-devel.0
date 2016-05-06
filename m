From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:56 +0000 (UTC)
Subject: master - lvmetad: disable if device scan fails
Message-ID: <20160506140056.CA85860722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1ea27b1e210274dfb9c7100cf0f9714397eec3b
Commit:        b1ea27b1e210274dfb9c7100cf0f9714397eec3b
Parent:        49d9582bed338dc555b616bcc9de20fafd00ce2d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 15 14:19:46 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

lvmetad: disable if device scan fails

If a command begins repopulating the lvmetad cache,
and fails part way through, it should set the disabled
state in lvmetad so other commands don't use bad data.
If a subsequent scan succeeds, the disabled state is
cleared.
---
 daemons/lvmetad/lvmetad-client.h |    1 +
 daemons/lvmetad/lvmetad-core.c   |   10 +++++++---
 lib/cache/lvmetad.c              |   27 +++++++++++++++------------
 3 files changed, 23 insertions(+), 15 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
index dce8a7e..1376e6b 100644
--- a/daemons/lvmetad/lvmetad-client.h
+++ b/daemons/lvmetad/lvmetad-client.h
@@ -22,6 +22,7 @@
 #define LVMETAD_DISABLE_REASON_DIRECT		"DIRECT"
 #define LVMETAD_DISABLE_REASON_LVM1		"LVM1"
 #define LVMETAD_DISABLE_REASON_DUPLICATES	"DUPLICATES"
+#define LVMETAD_DISABLE_REASON_SCANERROR	"SCANERROR"
 
 struct volume_group;
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 188c9b9..54ecd4a 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -202,8 +202,9 @@ struct vg_info {
 #define GLFL_DISABLE_REASON_DIRECT     0x00000004
 #define GLFL_DISABLE_REASON_LVM1       0x00000008
 #define GLFL_DISABLE_REASON_DUPLICATES 0x00000010
+#define GLFL_DISABLE_REASON_SCANERROR  0x00000020
 
-#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES)
+#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES | GLFL_DISABLE_REASON_SCANERROR)
 
 #define VGFL_INVALID 0x00000001
 
@@ -2512,6 +2513,8 @@ static response set_global_info(lvmetad_state *s, request r)
 			reason_flags |= GLFL_DISABLE_REASON_LVM1;
 		if (strstr(reason, LVMETAD_DISABLE_REASON_DUPLICATES))
 			reason_flags |= GLFL_DISABLE_REASON_DUPLICATES;
+		if (strstr(reason, LVMETAD_DISABLE_REASON_SCANERROR))
+			reason_flags |= GLFL_DISABLE_REASON_SCANERROR;
 	}
 
 	if (global_invalid != -1) {
@@ -2565,10 +2568,11 @@ static response get_global_info(lvmetad_state *s, request r)
 	memset(reason, 0, sizeof(reason));
 
 	if (s->flags & GLFL_DISABLE) {
-		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s",
+		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s%s",
 			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_LVM1)       ? LVMETAD_DISABLE_REASON_LVM1 "," : "",
-			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "");
+			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "",
+			 (s->flags & GLFL_DISABLE_REASON_SCANERROR)  ? LVMETAD_DISABLE_REASON_SCANERROR "," : "");
 	}
 
 	if (!reason[0])
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 86ccd59..391cbc4 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1700,11 +1700,6 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	if (!baton.vg)
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 
-	/*
-	 * NB. If this command failed and we are relying on lvmetad to have an
-	 * *exact* image of the system, the lvmetad instance that went out of
-	 * sync needs to be killed.
-	 */
 	if (!lvmetad_pv_found((const struct id *) &dev->pvid, dev, lvmcache_fmt(info),
 			      label->sector, baton.vg, handler)) {
 		release_vg(baton.vg);
@@ -1749,13 +1744,13 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 	struct dev_iter *iter;
 	struct device *dev;
 	daemon_reply reply;
-	int r = 1;
 	char *future_token;
 	const char *reason;
 	int was_silent;
 	int replacing_other_update = 0;
 	int replaced_update = 0;
 	int retries = 0;
+	int ret = 1;
 
 	if (!lvmetad_used()) {
 		log_error("Cannot proceed since lvmetad is not active.");
@@ -1813,7 +1808,7 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 	log_debug_lvmetad("Telling lvmetad to clear its cache");
 	reply = _lvmetad_send(cmd, "pv_clear_all", NULL);
 	if (!_lvmetad_handle_reply(reply, "pv_clear_all", "", NULL))
-		r = 0;
+		ret = 0;
 	daemon_reply_destroy(reply);
 
 	was_silent = silent_mode();
@@ -1821,33 +1816,38 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 
 	while ((dev = dev_iter_get(iter))) {
 		if (sigint_caught()) {
-			r = 0;
+			ret = 0;
 			stack;
 			break;
 		}
 		if (!lvmetad_pvscan_single(cmd, dev, handler, ignore_obsolete))
-			r = 0;
+			ret = 0;
 	}
 
 	init_silent(was_silent);
 
 	dev_iter_destroy(iter);
 
+	if (!ret)
+		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_SCANERROR);
+
 	_lvmetad_token = future_token;
-	if (!_token_update(NULL))
+	if (!_token_update(NULL)) {
+		log_error("Failed to update lvmetad token after device scan.");
 		return 0;
+	}
 
 	/*
 	 * If lvmetad is disabled, and no lvm1 metadata was seen and no
 	 * duplicate PVs were seen, then re-enable lvmetad.
 	 */
-	if (lvmetad_is_disabled(cmd, &reason) &&
+	if (ret && lvmetad_is_disabled(cmd, &reason) &&
 	    !lvmcache_found_duplicate_pvs() && !_found_lvm1_metadata) {
 		log_debug_lvmetad("Enabling lvmetad which was previously disabled.");
 		lvmetad_clear_disabled(cmd);
 	}
 
-	return r;
+	return ret;
 }
 
 int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler, int do_wait)
@@ -2451,6 +2451,9 @@ int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
 		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_DUPLICATES)) {
 			*reason = "duplicate PVs were found";
 
+		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_SCANERROR)) {
+			*reason = "scanning devices failed";
+
 		} else {
 			*reason = "<unknown>";
 		}


