From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Wed, 12 Oct 2022 13:19:49 +0000 (GMT)
Subject: main - toollib: do not process just created historical LV
Message-ID: <20221012131949.04C683898393@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=908555459f0abbcda687882439589209528e1dc0
Commit:        908555459f0abbcda687882439589209528e1dc0
Parent:        f6f2737015746b1b6c7fbd0d297a4596c584749b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 12 14:41:58 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 12 15:14:59 2022 +0200

toollib: do not process just created historical LV

When executing process_each_lv_in_vg, we process live LVs first and
after that, we process any historical LVs. In case we have just removed
an LV, which also means we have just made it "historical" and so it
appears as fresh item in vg->historical_lvs list, we have to skip it
when we get to processing historical LVs inside the same process_each_lv_in_vg
call.

The simplest approach here, without introducing another LV list, is to
simply mark such historical LVs as "fresh" directly in struct
historical_logical_volume when we have just removed the original LV
and created the historical LV for it. Then, we just need to check the
flag when processing historical LVs and skip it if it is "fresh".

When we read historical LVs out of metadata, they are marked as
"not fresh" and so they can be processed as usual.

This was mainly an issue in conjuction with -S|--select use:

	#  lvmconfig --type diff
	metadata {
		record_lvs_history=1
	}

(In this example, a thin pool with lvol1 thin LV and lvol2 and lvol3 snapshots.)

	#  lvs -H vg -o name,pool_lv,full_ancestors,full_descendants
	  LV    Pool FAncestors  FDescendants
	  lvol1 pool             lvol2,lvol3
	  lvol2 pool lvol1       lvol3
	  lvol3 pool lvol2,lvol1
	  pool

	#  lvremove -S 'name=lvol2'
	  Logical volume "lvol2" successfully removed.
	  Historical logical volume "lvol2" successfully removed.

...here, the historical LV lvol2 should not have been removed because
we have just removed its original non-historical lvol2 and the fresh
historical lvol2 must not be included in the same processing spree.
---
 WHATS_NEW                 | 1 +
 lib/metadata/lv.h         | 1 +
 lib/metadata/pool_manip.c | 1 +
 tools/toollib.c           | 3 +++
 4 files changed, 6 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index e29ec7066..2942b0e53 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+  Fix 'lvremove -S|--select LV' to not also remove its historical LV right away.
   Fix lv_active field type to binary so --select and --binary applies properly.
   Switch to use mallinfo2 and use it only with glibc.
   Error out in lvm shell if using a cmd argument not supported in the shell.
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 304ee2f7d..e591a9510 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -93,6 +93,7 @@ struct historical_logical_volume {
 	struct dm_list indirect_glvs; /* list of struct generic_logical_volume */
 	unsigned checked:1; /* set if this historical LV has been checked for validity */
 	unsigned valid:1;   /* historical LV is valid if there's at least one live LV among ancestors */
+	unsigned fresh:1;   /* historical LV has just been created (the original LV just removed) */
 };
 
 struct generic_logical_volume {
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index a6bfc2deb..559b07ba8 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -169,6 +169,7 @@ static struct glv_list *_init_historical_glvl(struct dm_pool *mem, struct lv_seg
 	hlv->name = seg->lv->name;
 	hlv->vg = seg->lv->vg;
 	hlv->timestamp = seg->lv->timestamp;
+	hlv->fresh = 1;
 	dm_list_init(&hlv->indirect_glvs);
 
 	glvl->glv->is_historical = 1;
diff --git a/tools/toollib.c b/tools/toollib.c
index e45afb6ee..5305e811b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3450,6 +3450,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 				goto_out;
 			}
 
+			if (glvl->glv->historical->fresh)
+				continue;
+
 			process_lv = process_all;
 
 			if (lvargs_supplied &&

