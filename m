From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:18 +0000 (UTC)
Subject: master - lvmetad: set disabled flag in lvmetad if lvm1 metadata is found
Message-ID: <20160419164918.A4E8660314@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff867c2ef6b0717c26f2073f0b79041156a6af58
Commit:        ff867c2ef6b0717c26f2073f0b79041156a6af58
Parent:        a4ef8fa25e4a8e14bef132393070006819b30935
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 29 11:30:57 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 09:41:18 2016 -0500

lvmetad: set disabled flag in lvmetad if lvm1 metadata is found

When devices are being scanned, if lvm1 metadata is seen,
tell lvmetad to set its disabled flag because of lvm1 metadata.
---
 lib/cache/lvmetad.c |   28 ++++++++++++++++++++++++++++
 lib/cache/lvmetad.h |    2 ++
 2 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index f2831f1..642a407 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1595,6 +1595,8 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 			log_error("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
 			  	baton.fid->fmt->name, dev_name(pvl->pv->dev));
 			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+			log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
+			lvmetad_set_disabled(cmd, "LVM1");
 			return NULL;
 		}
 
@@ -1716,6 +1718,9 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 				  baton.fid->fmt->name, dev_name(dev));
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 
+		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
+		lvmetad_set_disabled(cmd, "LVM1");
+
 		if (ignore_obsolete)
 			return 1;
 		return 0;
@@ -2250,6 +2255,29 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
 	return ret;
 }
 
+void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason)
+{
+	daemon_reply reply;
+
+	if (!_lvmetad_use)
+		return;
+
+	log_debug_lvmetad("lvmetad send disabled %s", reason);
+
+	reply = daemon_send_simple(_lvmetad, "set_global_info",
+				   "token = %s", "skip",
+				   "global_disable = " FMTd64, (int64_t)1,
+				   "disable_reason = %s", reason,
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
index 10283bb..76e8fd2 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -173,6 +173,7 @@ int lvmetad_token_matches(struct cmd_context *cmd);
 int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
 int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason);
+void lvmetad_set_disabled(struct cmd_context *cmd, const char *reason);
 
 #  else		/* LVMETAD_SUPPORT */
 
@@ -205,6 +206,7 @@ int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason);
 #    define lvmetad_vg_is_foreign(cmd, vgname, vgid) (0)
 #    define lvmetad_token_matches(cmd) (1)
 #    define lvmetad_is_disabled(cmd, reason) (0)
+#    define lvmetad_set_disabled(cmd, reason) do { } while (0)
 
 #  endif	/* LVMETAD_SUPPORT */
 


