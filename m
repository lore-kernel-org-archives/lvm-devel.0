From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  1 Feb 2023 10:53:14 +0000 (GMT)
Subject: main - lv/vgchange: when refreshing whole vg skip snapshot
Message-ID: <20230201105314.AD9DC3858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94eda42e7ad7c2dbd7fedfdfbf38032857318fec
Commit:        94eda42e7ad7c2dbd7fedfdfbf38032857318fec
Parent:        0ec087e8b82848891512f100ff594add8f47cfb2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 31 22:48:43 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 1 11:48:53 2023 +0100

lv/vgchange: when refreshing whole vg skip snapshot

When refreshing all LVs in a VG, skip processing of thick snapshots,
since they will be refreshed through its origin LV.
Should reduce some unnecessary ioctl().
---
 tools/toollib.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index d52c9e342..194088ea6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -883,7 +883,9 @@ int vg_refresh_visible(struct cmd_context *cmd, struct volume_group *vg)
 			break;
 		}
 
-		if (lv_is_visible(lvl->lv) && !lv_refresh(cmd, lvl->lv)) {
+		if (lv_is_visible(lvl->lv) &&
+		    !(lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv))) &&
+		    !lv_refresh(cmd, lvl->lv)) {
 			r = 0;
 			stack;
 		}
@@ -3292,7 +3294,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		/* Skip availability change for non-virt snaps when processing all LVs */
 		/* FIXME: pass process_all to process_single_lv() */
-		if (process_all && arg_is_set(cmd, activate_ARG) &&
+		if (process_all &&
+		    (arg_is_set(cmd, activate_ARG) ||
+		     arg_is_set(cmd, refresh_ARG)) &&
 		    lv_is_cow(lvl->lv) && !lv_is_virtual_origin(origin_from_cow(lvl->lv)))
 			continue;
 

