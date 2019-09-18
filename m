From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 18 Sep 2019 06:47:24 -0400
Subject: stable-2.02 - pvmove: check if participating LV is already exlcusively active
Message-ID: <201909181047.x8IAlOsW016778@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1349b61bb72d3a42636053ede0d6fa71cd4f2d93
Commit:        1349b61bb72d3a42636053ede0d6fa71cd4f2d93
Parent:        2e51535b18f3a05428f087f3916ebce5c08d58d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 18 12:42:50 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 18 12:46:22 2019 +0200

pvmove: check if participating LV is already exlcusively active

When running pvmove, we need to decide whether pvmove has to be doing
exlusive or non-exclusive activations for LV.

Whenever LV that requires exlusive activation is present, it makes
pvmove exlusive. But when there is already activate i.e. linear LV
in exclusive mode it also needs to switch pvmove into 'exlusively
activating' pvmove.
---
 WHATS_NEW      |    1 +
 tools/pvmove.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eee10ce..0a5bda3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.187 - 
 ===================================
+  Pvmove runs in exlusively activating mode for exclusively active LVs.
   Activate thin-pool layered volume as 'read-only' device.
   Ignore crypto devices with UUID signature CRYPT-SUBDEV.
   Enhance validation for thin and cache pool conversion and swapping.
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 754bd58..3a447c4 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -674,7 +674,8 @@ static int _pvmove_setup_single(struct cmd_context *cmd,
 		dm_list_iterate_items(lvl, lvs_changed) {
 			lvh = lv_lock_holder(lvl->lv);
 			/* Exclusive LV decides whether pvmove must be also exclusive */
-			if (lv_is_origin(lvh) || seg_only_exclusive(first_seg(lvh)))
+			if (lv_is_origin(lvh) || seg_only_exclusive(first_seg(lvh)) ||
+			    lv_is_active_exclusive(lvh))
 				exclusive = 1;
 		}
 


