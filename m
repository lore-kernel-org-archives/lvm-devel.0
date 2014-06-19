From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 19 Jun 2014 10:04:19 +0000 (UTC)
Subject: master - lvchange: better --refresh of raid and mirrors
Message-ID: <20140619100419.1691B606D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa3e41309368c1504943b8a116f5a3646777e2a0
Commit:        aa3e41309368c1504943b8a116f5a3646777e2a0
Parent:        57faf97e6fe9a8d7be859db2edb1ba2ad855113d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 19 11:58:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 19 12:01:34 2014 +0200

lvchange: better --refresh of raid and mirrors

Use lv_check_not_in_use() to detect openned device.
Plain info.open_count is not good enough for udev random
device openning.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    5 +----
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5d59845..f7d2b96 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Fix open_count test for lvchange --refresh or mirrors and raids.
   Update pvs,vgs,lvs and lvm man page for selection support.
   Add -S/--select to lvm devtypes for report selection.
   Add -S/--select to pvs,vgs,lvs and {pv,vg,lv}display -C for report selection.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 48e48d4..9bd6a88 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -347,7 +347,7 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 	}
 
 	if (lv_info(cmd, lv, 0, &info, 1, 0)) {
-		if (info.open_count) {
+		if (!lv_check_not_in_use(cmd, lv, &info)) {
 			log_error("Can't resync open logical volume \"%s\"",
 				  lv->name);
 			return 0;
@@ -363,9 +363,6 @@ static int lvchange_resync(struct cmd_context *cmd, struct logical_volume *lv)
 				return 0;
 			}
 
-			if (sigint_caught())
-				return_0;
-
 			active = 1;
 			if (lv_is_active_exclusive_locally(lv))
 				exclusive = 1;


