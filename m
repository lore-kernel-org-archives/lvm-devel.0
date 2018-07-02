From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 2 Jul 2018 04:27:05 -0400
Subject: master - lv_manip: add name of failing LV into error message
Message-ID: <201807020827.w628R5nB025985@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2bb9627d01dc138c56d0262f918462324782d3c7
Commit:        2bb9627d01dc138c56d0262f918462324782d3c7
Parent:        ed3428b7ed5386b508e76a403f2b11c5903d3d0f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 17:26:01 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 2 10:24:23 2018 +0200

lv_manip: add name of failing LV into error message

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7b68313..fc55c98 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7865,7 +7865,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 		lv->status &= ~LV_TEMPORARY;
 	} else if (!lv_active_change(cmd, lv, lp->activate)) {
-		log_error("Failed to activate new LV.");
+		log_error("Failed to activate new LV %s.", display_lvname(lv));
 		goto deactivate_and_revert_new_lv;
 	}
 


