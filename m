From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Wed, 28 Jul 2010 19:49:36 -0400
Subject: [PATCH] Fix log disk disappear with mirror allocate policy
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228865A8@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

With mirror_log_fault_policy of 'remove' and mirror_image_fault_policy
of 'allocate', the log type of the mirror volume is converted from
'disk' or 'mirrored' to 'core' when all mirror legs but one in a mirror
volume broke.

For example, vg00 contains four PVs and lv00 has two mirror legs and
a disk log. lv00 is converted to two way mirror without a log device.


- Policy
    mirror_log_fault_policy = "remove"
    mirror_image_fault_policy = "allocate"

- Before being repaired

# dmsetup ls --tree -o ascii
vg00-lv00 (253:3)
 |-vg00-lv00_mimage_1 (253:2)
 |  `- (8:32)
 |-vg00-lv00_mimage_0 (253:1)
 |  `- (8:16)
 `-vg00-lv00_mlog (253:0)
    `- (8:64)

- After being repaired

# dmsetup ls --tree -o ascii
vg00-lv00 (253:3)
 |-vg00-lv00_mimage_1 (253:1)
 |  `- (8:48)
 `-vg00-lv00_mimage_0 (253:0)
    `- (8:16)
 !!! Log disk disappeared !!!


* Solution

Keep new_log_count as a number of valid log devices by using
log_count variable for a temporary usage in the first phase
of error recovery in _lvconvert_mirrors_repair().


Apprecaite your review.

Thanks,
Taka


Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
---
 tools/lvconvert.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

Index: LVM2-2.02.71/tools/lvconvert.c
===================================================================
--- LVM2-2.02.71.orig/tools/lvconvert.c
+++ LVM2-2.02.71/tools/lvconvert.c
@@ -1237,25 +1237,27 @@ static int _lvconvert_mirrors_repair(str
 	if (!(lp->failed_pvs = _failed_pv_list(lv->vg)))
 		return_0;
 
+	log_count = new_log_count;
+
 	/*
 	 * We must adjust the log first, or the entire mirror
 	 * will get stuck during a suspend.
 	 */
-	if (!_lv_update_mirrored_log(lv, lp->failed_pvs, new_log_count))
+	if (!_lv_update_mirrored_log(lv, lp->failed_pvs, log_count))
 		return 0;
 
 	if (lp->mirrors == 1)
-		new_log_count = 0;
+		log_count = 0;
 
 	if (failed_mirrors) {
 		if (!lv_remove_mirrors(cmd, lv, failed_mirrors,
-				       new_log_count ? 0U : 1U,
+				       log_count ? 0U : 1U,
 				       _is_partial_lv, NULL, 0))
 			return 0;
 	}
 
 	if (!_lv_update_log_type(cmd, lp, lv, lp->failed_pvs,
-				 new_log_count))
+				 log_count))
 		return 0;
 
 	if (!_reload_lv(cmd, lv))


-- 
Takahiro Yasui
Hitachi Data Systems


