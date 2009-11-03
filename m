From: Milan Broz <mbroz@redhat.com>
Date: Tue, 03 Nov 2009 17:32:22 +0100
Subject: [PATCH] Fix segfault if %PVS is used in lvresize without PVs list
Message-ID: <4AF05B16.5070504@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix segfault if %PVS in lvresize without PVs list.

... and use the all available PVs instaed.

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 033078f..36c1717 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -367,8 +367,11 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			lp->extents = lp->extents * lv->le_count / 100;
 			break;
 		case PERCENT_PVS:
-			pv_extent_count = pv_list_extents_free(pvh);
-			lp->extents = lp->extents * pv_extent_count / 100;
+			if (lp->argc) {
+				pv_extent_count = pv_list_extents_free(pvh);
+				lp->extents = lp->extents * pv_extent_count / 100;
+			} else
+				lp->extents = lp->extents * vg->extent_count / 100;
 			break;
 		case PERCENT_NONE:
 			break;



