From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Sep 2012 07:55:54 +0000 (UTC)
Subject: master - vgchange: fix -aay to activate proper volumes
Message-ID: <20120912075554.41D5D23E5@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31271606265ec8f7c14734aedbb0a314dfea2cd1
Commit:        31271606265ec8f7c14734aedbb0a314dfea2cd1
Parent:        4ededc698f32a4cbabaf70bfd3835abab866cbb9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 12 09:47:40 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 12 09:47:40 2012 +0200

vgchange: fix -aay to activate proper volumes

Using 'activation/auto_activation_volume_list = [ "vg/lvol1" ]'.

Before this patch:
  3 logical volume(s) in volume group "vg" now active
  LV    VG   Attr     LSize Pool Origin Data%  Move Log Copy%  Convert
  lvol0 vg   -wi----- 4.00m
  lvol1 vg   -wi-a--- 4.00m
  lvol2 vg   -wi-a--- 4.00m
  lvol3 vg   -wi-a--- 4.00m

(vg/lvol1 activated as it passes the list and all subsequent volumes too - wrong!)

With this patch:
  1 logical volume(s) in volume group "vg" now active
  LV    VG   Attr     LSize Pool Origin Data%  Move Log Copy%  Convert
  lvol0 vg   -wi----- 4.00m
  lvol1 vg   -wi-a--- 4.00m
  lvol2 vg   -wi----- 4.00m
  lvol3 vg   -wi----- 4.00m

(only vg/lvol1 activated as it passes the list and no other - correct!)
---
 WHATS_NEW        |    1 +
 tools/vgchange.c |    9 +++------
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0c3b591..4884626 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Fix vgchange -aay to activate proper logical volumes.
   Properly handle 'resync' of RAID LVs.
   Disallow addition of RAID images until the array is in-sync.
   Fix RAID LV creation with '--test' so valid commands do not fail.
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 34f6167..fa129f8 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -131,11 +131,8 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			continue;
 		}
 
-		if (activate == CHANGE_AAY) {
-			if (!lv_passes_auto_activation_filter(cmd, lv))
-				continue;
-			activate = CHANGE_ALY;
-		}
+		if (activate == CHANGE_AAY && !lv_passes_auto_activation_filter(cmd, lv))
+			continue;
 
 		expected_count++;
 
@@ -157,7 +154,7 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 				stack;
 				continue;
 			}
-		} else if (activate == CHANGE_ALY) {
+		} else if (activate == CHANGE_AAY || activate == CHANGE_ALY) {
 			if (!activate_lv_local(cmd, lv)) {
 				stack;
 				continue;


