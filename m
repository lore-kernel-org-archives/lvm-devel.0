From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Mon, 15 Aug 2016 17:31:29 +0000 (UTC)
Subject: master - pvmove: fix regression introduced with 8e9d5d12ae3ac75852ebd74b64c28e31abb68d0e
Message-ID: <20160815173129.5B589606D7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d83f2d766d3177e2d2509f4fddb9b6f9c7fac7bc
Commit:        d83f2d766d3177e2d2509f4fddb9b6f9c7fac7bc
Parent:        8e9d5d12ae3ac75852ebd74b64c28e31abb68d0e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Aug 15 19:31:04 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Aug 15 19:31:04 2016 +0200

pvmove: fix regression introduced with 8e9d5d12ae3ac75852ebd74b64c28e31abb68d0e

'pvmove -n name pv1 pv2' called with the name of a top-level LV
failed with mentioned commit.

Enhance pvmove-raid-segtypes.sh to test for prohibited RAID SubLV moves.
---
 test/shell/pvmove-raid-segtypes.sh |    9 +++++++++
 tools/pvmove.c                     |    5 ++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index 78f5f3e..0025ba2 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -53,6 +53,15 @@ lvcreate -l 4 --type raid10 -i 2 -m 1 -n $lv1 $vg \
 check lv_tree_on $vg ${lv1}_foo "$dev1"
 check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 aux mkdev_md5sum $vg $lv1
+
+# Check collocation of SubLVs is prohibited
+not pvmove $mode -n ${lv1}_rimage_0 "$dev1" "$dev2"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+not pvmove $mode -n ${lv1}_rimage_1 "$dev2" "$dev1"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+not pvmove $mode -n ${lv1}_rmeta_0 "$dev1" "$dev3"
+check lv_tree_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
+
 pvmove $mode "$dev1" "$dev5"
 check lv_tree_on $vg ${lv1}_foo "$dev5"
 check lv_tree_on $vg $lv1 "$dev2" "$dev3" "$dev4" "$dev5"
diff --git a/tools/pvmove.c b/tools/pvmove.c
index f491d58..3877562 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -163,7 +163,8 @@ static int _remove_sibling_pvs_from_trim_list(struct logical_volume *lv,
 	/* Give up with success unless @lv_name _and_ valid raid segment type */
 	if (!lv_name || !*lv_name ||
 	    !seg_is_raid(first_seg(lv)) ||
-	    seg_is_raid0(first_seg(lv)))
+	    seg_is_raid0(first_seg(lv)) ||
+	    !strcmp(lv->name, lv_name))
 		return 1;
 
 	dm_list_init(&untrim_list);
@@ -427,6 +428,8 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
  			 * for collocation (e.g. *rmeta_0 -> *rimage_0).
  			 *
  			 * Callee checks for lv_name and valid raid segment type.
+ 			 *
+ 			 * FIXME: don't rely on namespace
  			 */
 			if (!_remove_sibling_pvs_from_trim_list(lv, lv_name, &trim_list))
 				return_NULL;


