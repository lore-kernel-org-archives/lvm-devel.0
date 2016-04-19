From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:38 +0000 (UTC)
Subject: master - lvmetad: use defines for disabled reason strings
Message-ID: <20160419164938.290F461286@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=593900b795e194608e9e2088aa8f75f4f42484c1
Commit:        593900b795e194608e9e2088aa8f75f4f42484c1
Parent:        fa904a844f7129c39e15ce5e3dc310854646fb87
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 19 10:51:11 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 11:45:24 2016 -0500

lvmetad: use defines for disabled reason strings

---
 daemons/lvmetad/lvmetactl.c      |    2 +-
 daemons/lvmetad/lvmetad-client.h |    4 ++++
 daemons/lvmetad/lvmetad-core.c   |   13 +++++++------
 lib/cache/lvmetad.c              |   10 +++++-----
 4 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/daemons/lvmetad/lvmetactl.c b/daemons/lvmetad/lvmetactl.c
index 90db173..30ca1d6 100644
--- a/daemons/lvmetad/lvmetactl.c
+++ b/daemons/lvmetad/lvmetactl.c
@@ -98,7 +98,7 @@ int main(int argc, char **argv)
 
 		reply = daemon_send_simple(h, "set_global_info",
 					   "global_disable = " FMTd64, (int64_t) val,
-					   "disable_reason = %s", "DIRECT",
+					   "disable_reason = %s", LVMETAD_DISABLE_REASON_DIRECT,
 					   "token = %s", "skip",
 					   NULL);
 		print_reply(reply);
diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
index 012f3a8..dce8a7e 100644
--- a/daemons/lvmetad/lvmetad-client.h
+++ b/daemons/lvmetad/lvmetad-client.h
@@ -19,6 +19,10 @@
 
 #define LVMETAD_SOCKET DEFAULT_RUN_DIR "/lvmetad.socket"
 
+#define LVMETAD_DISABLE_REASON_DIRECT		"DIRECT"
+#define LVMETAD_DISABLE_REASON_LVM1		"LVM1"
+#define LVMETAD_DISABLE_REASON_DUPLICATES	"DUPLICATES"
+
 struct volume_group;
 
 /* Different types of replies we may get from lvmetad. */
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1c2ac81..45641a6 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -22,6 +22,7 @@
 #include "daemon-server.h"
 #include "daemon-log.h"
 #include "lvm-version.h"
+#include "lvmetad-client.h"
 
 #include <assert.h>
 #include <errno.h>
@@ -2626,11 +2627,11 @@ static response set_global_info(lvmetad_state *s, request r)
 	uint32_t reason_flags = 0;
 
 	if ((reason = daemon_request_str(r, "disable_reason", NULL))) {
-		if (strstr(reason, "DIRECT"))
+		if (strstr(reason, LVMETAD_DISABLE_REASON_DIRECT))
 			reason_flags |= GLFL_DISABLE_REASON_DIRECT;
-		if (strstr(reason, "LVM1"))
+		if (strstr(reason, LVMETAD_DISABLE_REASON_LVM1))
 			reason_flags |= GLFL_DISABLE_REASON_LVM1;
-		if (strstr(reason, "DUPLICATES"))
+		if (strstr(reason, LVMETAD_DISABLE_REASON_DUPLICATES))
 			reason_flags |= GLFL_DISABLE_REASON_DUPLICATES;
 	}
 
@@ -2686,9 +2687,9 @@ static response get_global_info(lvmetad_state *s, request r)
 
 	if (s->flags & GLFL_DISABLE) {
 		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s",
-			 (s->flags & GLFL_DISABLE_REASON_DIRECT) ? "DIRECT," : "",
-			 (s->flags & GLFL_DISABLE_REASON_LVM1) ? "LVM1," : "",
-			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? "DUPLICATES," : "");
+			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
+			 (s->flags & GLFL_DISABLE_REASON_LVM1)       ? LVMETAD_DISABLE_REASON_LVM1 "," : "",
+			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "");
 	}
 
 	if (!reason[0])
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index bcf6f93..858be4d 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1598,7 +1598,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 			  	baton.fid->fmt->name, dev_name(pvl->pv->dev));
 			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 			log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
-			lvmetad_set_disabled(cmd, "LVM1");
+			lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
 			_found_lvm1_metadata = 1;
 			return NULL;
 		}
@@ -1722,7 +1722,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 
 		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
-		lvmetad_set_disabled(cmd, "LVM1");
+		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
 		_found_lvm1_metadata = 1;
 
 		if (ignore_obsolete)
@@ -2352,13 +2352,13 @@ int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
 		if (!reply_reason) {
 			*reason = "<not set>";
 
-		} else if (strstr(reply_reason, "DIRECT")) {
+		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_DIRECT)) {
 			*reason = "the disable flag was set directly";
 
-		} else if (strstr(reply_reason, "LVM1")) {
+		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_LVM1)) {
 			*reason = "LVM1 metadata was found";
 
-		} else if (strstr(reply_reason, "DUPLICATES")) {
+		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_DUPLICATES)) {
 			*reason = "duplicate PVs were found";
 
 		} else {


