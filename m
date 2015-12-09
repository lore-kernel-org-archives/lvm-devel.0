From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  9 Dec 2015 18:00:46 +0000 (UTC)
Subject: master - lvrename: move the lvmlockd LV lock
Message-ID: <20151209180046.2603060ECE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bdba4e7a931f1e77f9c7cf6837a6c8b33b35a099
Commit:        bdba4e7a931f1e77f9c7cf6837a6c8b33b35a099
Parent:        dcd946e95a80da1b6b2d2285d9a5f41e87cb153d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 9 11:51:25 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 9 11:59:49 2015 -0600

lvrename: move the lvmlockd LV lock

The function it was in is used for various
internal renaming of hidden LVs where a lock
from lvmlockd does not apply.
---
 lib/metadata/lv_manip.c |   12 ------------
 tools/lvrename.c        |   12 ++++++++++++
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2582ed5..2f37f5b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4247,18 +4247,6 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		return 0;
 	}
 
-	/*
-	 * The lvmlockd LV lock is only acquired here to ensure the LV is not
-	 * active on another host.  This requests a transient LV lock.
-	 * If the LV is active, a persistent LV lock already exists in
-	 * lvmlockd, and the transient lock request does nothing.
-	 * If the LV is not active, then no LV lock exists and the transient
-	 * lock request acquires the LV lock (or fails).  The transient lock
-	 * is automatically released when the command exits.
-	 */
-	if (!lockd_lv(cmd, lv, "ex", 0))
-		return_0;
-
 	if (update_mda && !archive(vg))
 		return_0;
 
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 18b02d2..217ebdc 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -46,6 +46,18 @@ static int _lvrename_single(struct cmd_context *cmd, const char *vg_name,
 		goto bad;
 	}
 
+	/*
+	 * The lvmlockd LV lock is only acquired here to ensure the LV is not
+	 * active on another host.  This requests a transient LV lock.
+	 * If the LV is active, a persistent LV lock already exists in
+	 * lvmlockd, and the transient lock request does nothing.
+	 * If the LV is not active, then no LV lock exists and the transient
+	 * lock request acquires the LV lock (or fails).  The transient lock
+	 * is automatically released when the command exits.
+	 */
+	if (!lockd_lv(cmd, lvl->lv, "ex", 0))
+		goto_bad;
+
 	if (!lv_rename(cmd, lvl->lv, lp->lv_name_new))
 		goto_bad;
 


