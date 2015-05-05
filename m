From: okozina <okozina@fedoraproject.org>
Date: Tue,  5 May 2015 18:54:19 +0000 (UTC)
Subject: master - polldaemon: make wait_for_single_lv public
Message-ID: <20150505185419.C753A60ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7fca7f196d17add08cdcc22ede99e8432a2fc4d0
Commit:        7fca7f196d17add08cdcc22ede99e8432a2fc4d0
Parent:        81c038934c61f4c2afe159460b04dbccdda2a721
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Apr 10 16:36:50 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 5 20:52:24 2015 +0200

polldaemon: make wait_for_single_lv public

referenced by new lvpoll command after lvmpolld
gets merged.
---
 tools/polldaemon.c |    6 +++---
 tools/polldaemon.h |    3 +++
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index a311e24..9c62ebf 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -158,8 +158,8 @@ static void _sleep_and_rescan_devices(struct daemon_parms *parms)
 	}
 }
 
-static int _wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
-			       struct daemon_parms *parms)
+int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
+		       struct daemon_parms *parms)
 {
 	struct volume_group *vg;
 	struct logical_volume *lv;
@@ -392,7 +392,7 @@ static int _poll_daemon(struct cmd_context *cmd, struct poll_operation_id *id,
 	 * Process one specific task or all incomplete tasks?
 	 */
 	if (id) {
-		if (!_wait_for_single_lv(cmd, id, parms)) {
+		if (!wait_for_single_lv(cmd, id, parms)) {
 			stack;
 			ret = ECMD_FAILED;
 		}
diff --git a/tools/polldaemon.h b/tools/polldaemon.h
index 9c33250..6309a5f 100644
--- a/tools/polldaemon.h
+++ b/tools/polldaemon.h
@@ -87,4 +87,7 @@ struct logical_volume *poll_get_copy_lv(struct cmd_context *cmd,
 					const char *name, const char *uuid,
 					uint64_t lv_type);
 
+int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
+		       struct daemon_parms *parms);
+
 #endif


