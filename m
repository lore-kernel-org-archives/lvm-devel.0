From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  7 Jun 2016 15:18:02 +0000 (UTC)
Subject: master - lvmetad: remove disabled case for "scan error"
Message-ID: <20160607151802.A794861EF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=851ccfccaf3dae184e0bd5f222bdcfcef33fa3b8
Commit:        851ccfccaf3dae184e0bd5f222bdcfcef33fa3b8
Parent:        0e7f352c70decb779508b038a22e87c8e3f58b61
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 25 16:10:46 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 7 10:17:00 2016 -0500

lvmetad: remove disabled case for "scan error"

Failures while populating lvmetad will be handling
differently in a subsequent commit.
---
 daemons/lvmetad/lvmetad-client.h |    1 -
 daemons/lvmetad/lvmetad-core.c   |   10 +++-------
 lib/cache/lvmetad.c              |    6 ------
 3 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-client.h b/daemons/lvmetad/lvmetad-client.h
index 47eb6b4..b352c04 100644
--- a/daemons/lvmetad/lvmetad-client.h
+++ b/daemons/lvmetad/lvmetad-client.h
@@ -24,7 +24,6 @@
 #define LVMETAD_DISABLE_REASON_DIRECT		"DIRECT"
 #define LVMETAD_DISABLE_REASON_LVM1		"LVM1"
 #define LVMETAD_DISABLE_REASON_DUPLICATES	"DUPLICATES"
-#define LVMETAD_DISABLE_REASON_SCANERROR	"SCANERROR"
 
 struct volume_group;
 
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index f9d0d4c..51db92f 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -202,9 +202,8 @@ struct vg_info {
 #define GLFL_DISABLE_REASON_DIRECT     0x00000004
 #define GLFL_DISABLE_REASON_LVM1       0x00000008
 #define GLFL_DISABLE_REASON_DUPLICATES 0x00000010
-#define GLFL_DISABLE_REASON_SCANERROR  0x00000020
 
-#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES | GLFL_DISABLE_REASON_SCANERROR)
+#define GLFL_DISABLE_REASON_ALL (GLFL_DISABLE_REASON_DIRECT | GLFL_DISABLE_REASON_LVM1 | GLFL_DISABLE_REASON_DUPLICATES)
 
 #define VGFL_INVALID 0x00000001
 
@@ -2333,8 +2332,6 @@ static response set_global_info(lvmetad_state *s, request r)
 			reason_flags |= GLFL_DISABLE_REASON_LVM1;
 		if (strstr(reason, LVMETAD_DISABLE_REASON_DUPLICATES))
 			reason_flags |= GLFL_DISABLE_REASON_DUPLICATES;
-		if (strstr(reason, LVMETAD_DISABLE_REASON_SCANERROR))
-			reason_flags |= GLFL_DISABLE_REASON_SCANERROR;
 	}
 
 	if (global_invalid != -1) {
@@ -2388,11 +2385,10 @@ static response get_global_info(lvmetad_state *s, request r)
 	memset(reason, 0, sizeof(reason));
 
 	if (s->flags & GLFL_DISABLE) {
-		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s%s",
+		snprintf(reason, REASON_BUF_SIZE - 1, "%s%s%s",
 			 (s->flags & GLFL_DISABLE_REASON_DIRECT)     ? LVMETAD_DISABLE_REASON_DIRECT "," : "",
 			 (s->flags & GLFL_DISABLE_REASON_LVM1)       ? LVMETAD_DISABLE_REASON_LVM1 "," : "",
-			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "",
-			 (s->flags & GLFL_DISABLE_REASON_SCANERROR)  ? LVMETAD_DISABLE_REASON_SCANERROR "," : "");
+			 (s->flags & GLFL_DISABLE_REASON_DUPLICATES) ? LVMETAD_DISABLE_REASON_DUPLICATES "," : "");
 	}
 
 	if (!reason[0])
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a87c952..bb86e88 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1792,9 +1792,6 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 
 	dev_iter_destroy(iter);
 
-	if (!ret)
-		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_SCANERROR);
-
 	_lvmetad_token = future_token;
 	if (!_token_update(NULL)) {
 		log_error("Failed to update lvmetad token after device scan.");
@@ -2401,9 +2398,6 @@ int lvmetad_is_disabled(struct cmd_context *cmd, const char **reason)
 		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_DUPLICATES)) {
 			*reason = "duplicate PVs were found";
 
-		} else if (strstr(reply_reason, LVMETAD_DISABLE_REASON_SCANERROR)) {
-			*reason = "scanning devices failed";
-
 		} else {
 			*reason = "<unknown>";
 		}


