From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Sep 2019 07:38:43 -0400
Subject: master - vdo: restore monitoring of vdo pool
Message-ID: <201909301138.x8UBchU1002535@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c0264d68954e5677f21459bb18d50704b2b9d77
Commit:        5c0264d68954e5677f21459bb18d50704b2b9d77
Parent:        a98b77c16455ee97f5bd4b89536a3ae4efd8e009
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 30 13:28:20 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 30 13:34:34 2019 +0200

vdo: restore monitoring of vdo pool

Switch to -vpool layered name needs to monitor proper device.
---
 lib/activate/activate.c |    2 ++
 tools/lvchange.c        |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2588816..6f5fa1a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1604,6 +1604,8 @@ static char *_build_target_uuid(struct cmd_context *cmd, const struct logical_vo
 
 	if (lv_is_thin_pool(lv))
 		layer = "tpool"; /* Monitor "tpool" for the "thin pool". */
+	else if (lv_is_vdo_pool(lv))
+		layer = "vpool"; /* Monitor "vpool" for the "VDO pool". */
 	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		layer = "real"; /* Monitor "real" for "snapshot-origin". */
 	else
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 65cea6c..5f0fcab 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -145,7 +145,7 @@ static int _lvchange_monitoring(struct cmd_context *cmd,
 {
 	struct lvinfo info;
 
-	if (!lv_info(cmd, lv, lv_is_thin_pool(lv) ? 1 : 0,
+	if (!lv_info(cmd, lv, (lv_is_thin_pool(lv) || lv_is_vdo_pool(lv)) ? 1 : 0,
 		     &info, 0, 0) || !info.exists) {
 		log_error("Logical volume %s is not active.", display_lvname(lv));
 		return 0;


