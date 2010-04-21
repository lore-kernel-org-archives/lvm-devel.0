From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 21 Apr 2010 13:59:00 -0400
Subject: [PATCH] conditionally avoid preloading the origin in vg_remove_snapshot
In-Reply-To: <20100421063504.GA10083@redhat.com>
References: <20100407200443.26841.qmail@sourceware.org>
	<20100419223820.GA11273@redhat.com>
	<20100419232509.GG4828@agk-dp.fab.redhat.com>
	<20100421063504.GA10083@redhat.com>
Message-ID: <20100421175859.GA19594@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 21 2010 at  2:35am -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Mon, Apr 19 2010 at  7:25pm -0400,
> Alasdair G Kergon <agk@redhat.com> wrote:
> 
> > On Mon, Apr 19, 2010 at 06:38:20PM -0400, Mike Snitzer wrote:
> > > On Wed, Apr 07 2010 at  4:04pm -0400,
> > > agk at sourceware.org <agk@sourceware.org> wrote:
> >  
> > > >  		/* Refresh open_count */
> > > >  		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
> > > > -		    !info.exists || info.open_count)
> > > > +		    !info.exists)
> > > >  			continue;
> > > >  
> > > > +		if (info.open_count) {
> > 
> > > It would appear that the non-zero open_count associated with the -real
> > > device is stale (during lvremove's dm_tree_deactivate_children).  
> > 
> > Shouldn't be - it follows a 'refresh'.
> 
> You're right, it's not stale at all.
> 
> So the 2 issues I've found:
> 1) removal of snapshot with pending onactivate merge doesn't cleanup
>    snapshot like normal (normal being "case A" below) -- it does "case B"
> 2) completely tangential but: when a merge is active the merging
>    snapshot LV is accessible (by user with lvremove); so removing the
>    merging snapshot is currently allowed (stops merge, deletes
>    snapshot); should it be allowed?
> 
> The following is more of a "note to self" that I've collected while
> looking into this.. but feel free to review it ("case B" below
> elaborates on why the t-snapshot-merge.sh test was failing).
> 
> "case B" preloads the origin when cleaning up for a merge (I believe
> this explains why we attempt to cleanup -real early).  See commit
> eaef92b02f968856 -- the vg_remove_snapshot changes in particular. 
> 
> I've yet to arrive at a fix for the attempt to cleanup -real too early
> in case B (which triggers the _dm_tree_deactivate_children: r = 0); it
> involves metadata/deptree associations not reflecting the kernel
> (because of pending onactivate merge metadata) -- so vg_remove_snapshot
> preloads origin.

Here is a fix:

Avoid preloading the origin, when removing a snapshot, if snapshot-merge
target is not active.

[This adds a 2nd consumer of lv_has_target_type().  I'm still not seeing
 an alternative way to test if snapshot-merge was performed.]

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 lib/activate/activate.h       |    3 +++
 lib/activate/dev_manager.c    |   10 ++++------
 lib/metadata/snapshot_manip.c |   21 +++++++++++++++------
 test/t-snapshot-merge.sh      |   17 +++++++++++++++++
 4 files changed, 39 insertions(+), 12 deletions(-)

diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 32d9a5c..019f44c 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -95,6 +95,9 @@ int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(struct logical_volume *lv);
 
+int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
+		       const char *layer, const char *target_type);
+
 int monitor_dev_for_events(struct cmd_context *cmd,
 			    struct logical_volume *lv, int do_reg);
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 66cc94c..cc4e046 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -329,10 +329,8 @@ static int _status(const char *name, const char *uuid,
 	return 0;
 }
 
-static int _lv_has_target_type(struct dev_manager *dm,
-			       struct logical_volume *lv,
-			       const char *layer,
-			       const char *target_type)
+int lv_has_target_type(struct dm_pool *mem, struct logical_volume *lv,
+		       const char *layer, const char *target_type)
 {
 	int r = 0;
 	char *dlid;
@@ -343,7 +341,7 @@ static int _lv_has_target_type(struct dev_manager *dm,
 	char *type = NULL;
 	char *params = NULL;
 
-	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))
+	if (!(dlid = build_dm_uuid(mem, lv->lvid.s, layer)))
 		return_0;
 
 	if (!(dmt = _setup_task(NULL, dlid, 0,
@@ -1183,7 +1181,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		    ((dinfo = _cached_info(dm->mem, find_merging_cow(lv)->cow,
 					   dtree)) && dinfo->open_count)) {
 			/* FIXME Is there anything simpler to check for instead? */
-			if (!_lv_has_target_type(dm, lv, NULL, "snapshot-merge"))
+			if (!lv_has_target_type(dm->mem, lv, NULL, "snapshot-merge"))	
 				clear_snapshot_merge(lv);
 		}
 	}
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index f7218c2..cb5df6b 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -18,6 +18,7 @@
 #include "locking.h"
 #include "toolcontext.h"
 #include "lv_alloc.h"
+#include "activate.h"
 
 int lv_is_origin(const struct logical_volume *lv)
 {
@@ -176,16 +177,24 @@ int vg_remove_snapshot(struct logical_volume *cow)
 
 	dm_list_del(&cow->snapshot->origin_list);
 	origin->origin_count--;
+
 	if (find_merging_cow(origin) == find_cow(cow)) {
 		clear_snapshot_merge(origin);
 		/*
-		 * preload origin to:
-		 * - allow proper release of -cow
-		 * - avoid allocations with other devices suspended
-		 *   when transitioning from "snapshot-merge" to
-		 *   "snapshot-origin after a merge completes.
+		 * preload origin IFF "snapshot-merge" target is active
+		 * - IMPORTANT: avoids preload if onactivate merge is pending
 		 */
-		preload_origin = 1;
+		if (lv_has_target_type(origin->vg->cmd->mem, origin, NULL,
+				       "snapshot-merge")) {
+			/*
+			 * preload origin to:
+			 * - allow proper release of -cow
+			 * - avoid allocations with other devices suspended
+			 *   when transitioning from "snapshot-merge" to
+			 *   "snapshot-origin after a merge completes.
+			 */
+			preload_origin = 1;
+		}
 	}
 
 	if (!lv_remove(cow->snapshot->lv)) {
diff --git a/test/t-snapshot-merge.sh b/test/t-snapshot-merge.sh
index ff78f14..d7239b9 100755
--- a/test/t-snapshot-merge.sh
+++ b/test/t-snapshot-merge.sh
@@ -76,6 +76,23 @@ dmsetup table ${vg}-${lv1} | grep -q " snapshot-merge "
 lvremove -f $vg/$lv1
 
 
+# "onactivate merge" test
+# -- deactivate/remove after disallowed merge attempt, tests
+#    to make sure preload of origin's metadata is _not_ performed
+setup_merge $vg $lv1
+lvs -a
+mkdir test_mnt
+mount $(lvdev_ $vg $lv1) test_mnt
+lvconvert --merge $vg/$(snap_lv_name_ $lv1)
+# -- refresh LV while FS is still mounted (merge must not start),
+#    verify 'snapshot-origin' target is still being used
+lvchange --refresh $vg/$lv1
+umount test_mnt
+rm -r test_mnt
+dmsetup table ${vg}-${lv1} | grep -q " snapshot-origin "
+lvremove -f $vg/$lv1
+
+
 # test multiple snapshot merge; tests copy out that is driven by merge
 setup_merge $vg $lv1 1
 lvs -a


