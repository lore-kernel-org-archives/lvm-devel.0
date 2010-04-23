From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 23 Apr 2010 10:48:08 -0400
Subject: Allowing an actively merging snapshot to be removed?
In-Reply-To: <20100422233605.GB23791@agk-dp.fab.redhat.com>
References: <20100407200443.26841.qmail@sourceware.org>
	<20100419223820.GA11273@redhat.com>
	<20100419232509.GG4828@agk-dp.fab.redhat.com>
	<20100421063504.GA10083@redhat.com>
	<20100421193804.GA28717@redhat.com>
	<Pine.LNX.4.64.1004211951340.24723@hs20-bc2-1.build.redhat.com>
	<20100422233605.GB23791@agk-dp.fab.redhat.com>
Message-ID: <20100423144808.GA21974@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 22 2010 at  7:36pm -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Wed, Apr 21, 2010 at 08:01:32PM -0400, Mikulas Patocka wrote:
> > I think the merging snapshot LV shouldn't be accessible 
> 
> Ack.  We are past the user-generated 'commit' point at which it goes.

The following patch is one way to address this bug.  Given the current
merge support in lvm2 this is the most straight-forward fix.  I've
tested this to work well.  Does the following seem reasonable?


Disallow the direct removal of a merging snapshot.

Allow lv_remove_with_dependencies() to know the top-level LV that was
requested to be removed (before it recurses and loses context).

A merging snapshot cannot be removed directly but the associated origin
can be.  Disallow removal of a merging snapshot unless the associated
origin is also being removed.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/metadata/lv_manip.c          |   17 +++++++++++++----
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/metadata.c          |    2 +-
 test/t-snapshot-merge.sh         |   12 +++++++++---
 tools/lvremove.c                 |    2 +-
 5 files changed, 25 insertions(+), 10 deletions(-)

Index: lvm2/lib/metadata/lv_manip.c
===================================================================
--- lvm2.orig/lib/metadata/lv_manip.c
+++ lvm2/lib/metadata/lv_manip.c
@@ -2306,16 +2306,25 @@ int lv_remove_single(struct cmd_context 
  * remove LVs with its dependencies - LV leaf nodes should be removed first
  */
 int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
-				const force_t force)
+				const force_t force, unsigned level)
 {
 	struct dm_list *snh, *snht;
 
-        if (lv_is_origin(lv)) {
+	if (lv_is_cow(lv)) {
+		/* A merging snapshot cannot be removed directly */
+		if (lv_is_merging_cow(lv) && !level) {
+			log_error("Can't remove merging snapshot logical volume \"%s\"",
+				  lv->name);
+			return 0;
+		}
+	}
+
+	if (lv_is_origin(lv)) {
 		/* remove snapshot LVs first */
 		dm_list_iterate_safe(snh, snht, &lv->snapshot_segs) {
 			if (!lv_remove_with_dependencies(cmd, dm_list_struct_base(snh, struct lv_segment,
-									       origin_list)->cow,
-							 force))
+										  origin_list)->cow,
+							 force, level + 1))
 				return 0;
 		}
 	}
Index: lvm2/test/t-snapshot-merge.sh
===================================================================
--- lvm2.orig/test/t-snapshot-merge.sh
+++ lvm2/test/t-snapshot-merge.sh
@@ -44,17 +44,22 @@ setup_merge() {
 aux prepare_vg 1 100
 
 
-# full merge of a single LV
+# test full merge of a single LV
 setup_merge $vg $lv1
-
 # now that snapshot LV is created: test if snapshot-merge target is available
 $(dmsetup targets | grep -q snapshot-merge) || exit 200
-
 lvs -a
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
 
+# test that an actively merging snapshot may not be removed
+setup_merge $vg $lv1
+lvconvert -i+100 --merge --background $vg/$(snap_lv_name_ $lv1)
+not lvremove -f $vg/$(snap_lv_name_ $lv1)
+lvremove -f $vg/$lv1
+
+
 # "onactivate merge" test
 setup_merge $vg $lv1
 lvs -a
@@ -99,6 +104,7 @@ lvs -a
 lvconvert --merge $vg/$(snap_lv_name_ $lv1)
 lvremove -f $vg/$lv1
 
+
 # test merging multiple snapshots that share the same tag
 setup_merge $vg $lv1
 setup_merge $vg $lv2
Index: lvm2/lib/metadata/metadata-exported.h
===================================================================
--- lvm2.orig/lib/metadata/metadata-exported.h
+++ lvm2/lib/metadata/metadata-exported.h
@@ -534,7 +534,7 @@ int lv_remove_single(struct cmd_context 
 		     force_t force);
 
 int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *lv,
-				force_t force);
+				force_t force, unsigned level);
 
 int lv_rename(struct cmd_context *cmd, struct logical_volume *lv,
 	      const char *new_name);
Index: lvm2/lib/metadata/metadata.c
===================================================================
--- lvm2.orig/lib/metadata/metadata.c
+++ lvm2/lib/metadata/metadata.c
@@ -484,7 +484,7 @@ int remove_lvs_in_vg(struct cmd_context 
 
 	while ((lst = dm_list_first(&vg->lvs))) {
 		lvl = dm_list_item(lst, struct lv_list);
-		if (!lv_remove_with_dependencies(cmd, lvl->lv, force))
+		if (!lv_remove_with_dependencies(cmd, lvl->lv, force, 0))
 		    return 0;
 	}
 
Index: lvm2/tools/lvremove.c
===================================================================
--- lvm2.orig/tools/lvremove.c
+++ lvm2/tools/lvremove.c
@@ -26,7 +26,7 @@ static int lvremove_single(struct cmd_co
         if (lv_is_cow(lv) && lv_is_virtual_origin(origin = origin_from_cow(lv)))
                 lv = origin;
 
-	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG))) {
+	if (!lv_remove_with_dependencies(cmd, lv, arg_count(cmd, force_ARG), 0)) {
 		stack;
 		return ECMD_FAILED;
 	}


