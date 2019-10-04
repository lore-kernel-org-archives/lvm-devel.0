From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:11 -0400
Subject: master - display: try to show status for inactive vdopool
Message-ID: <201910041533.x94FXBOG031000@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=98419e06670493523ee08ea8e10b222deb253f7c
Commit:        98419e06670493523ee08ea8e10b222deb253f7c
Parent:        6a9a4b45341cc62b103bf167e96bbdb5f542476e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 4 16:57:54 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

display: try to show status for inactive vdopool

Since we now support activation of 'vdo' volume
without explicit activation of 'vdopool' it's now possible
to have active layer vdopool (-vpool) volume and
having vdopool itself inactive - yet still in this
case we can show available stats for this volume.
But we need to show correct activation status and other
standard info.
---
 lib/display/display.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 913bced..36c9879 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -533,7 +533,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 	} else if (lv_is_vdo_pool(lv)) {
 		seg = first_seg(lv);
 		log_print("LV VDO Pool data       %s", seg_lv(seg, 0)->name);
-		if (inkernel && lv_vdo_pool_status(lv, 0, &vdo_status)) { /* FIXME: flush option? */
+		if (lv_vdo_pool_status(lv, 0, &vdo_status)) { /* FIXME: flush option? */
 			log_print("LV VDO Pool usage      %s%%",
 				  display_percent(cmd, vdo_status->usage));
 			log_print("LV VDO Pool saving     %s%%",


