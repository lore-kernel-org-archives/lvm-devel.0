From: David Teigland <teigland@sourceware.org>
Date: Mon,  9 Mar 2020 17:28:39 +0000 (GMT)
Subject: master - lvmlockd: use transient LV lock when creating snapshot
Message-ID: <20200309172839.88E75394201F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd0fdd846d85d7028e65bb801c27791a8e2cee2d
Commit:        dd0fdd846d85d7028e65bb801c27791a8e2cee2d
Parent:        a5b1b52903fe3c71e8515f5592ab10d69896b5e7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 9 12:25:26 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 9 12:25:26 2020 -0500

lvmlockd: use transient LV lock when creating snapshot

Creating a snapshot was using a persistent LV lock
on the origin, so if the origin LV was inactive at
the time of the snapshot the LV lock would remain.
(Running lvchange -an on the inactive LV would
clear the LV lock.)  Use a transient LV lock so it
will be dropped if it was not locked previously.
---
 lib/locking/lvmlockd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 416121011..e378fe6cb 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2679,7 +2679,7 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 			log_error("Failed to find origin LV %s/%s", vg->name, lp->origin_name);
 			return 0;
 		}
-		if (!lockd_lv(cmd, origin_lv, "ex", LDLV_PERSISTENT)) {
+		if (!lockd_lv(cmd, origin_lv, "ex", 0)) {
 			log_error("Failed to lock origin LV %s/%s", vg->name, lp->origin_name);
 			return 0;
 		}



