From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Jun 2016 22:46:02 +0000 (UTC)
Subject: master - thin: fix link validation for unused thin-pool
Message-ID: <20160630224602.CE990609F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=458918b31953943a3cc44976388f008ca850c124
Commit:        458918b31953943a3cc44976388f008ca850c124
Parent:        2f638e07e814617152d617a2ca7c8acdae41968a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 30 15:54:27 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 1 00:44:46 2016 +0200

thin: fix link validation for unused thin-pool

This patch fixes link validation for used thin-pool.
Udev rules correctly creates symlinks only for unused new thin-pool.
Such thin-pool can be used by foreing apps (like Docker) thus
has  /dev/vg/lv link.
However when thin-pool becomes used by thinLV - this link is no
longer exposed to user - but internal verfication missed this
and caused messages like this to be printed upon 'vgchange -ay':

The link /dev/vg/pool should have been created by udev but it was not
found. Falling back to direct link creation.

And same with 'vgchange -an':
The link /dev/vg/pool should have been removed by udev but it is still
present. Falling back to direct link removal.

This patch ensures only unused thin-pool has this link.
---
 WHATS_NEW                           |    1 +
 lib/activate/dev_manager.c          |   10 ++++++++--
 test/shell/thin-overprovisioning.sh |    4 ++++
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a73744e..4d71ea8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.159 - 
 =================================
+  Fix created link for a used pool for vgmknode.
   Introduce and use is_power_of_2 macro.
   Support conversions between striped and raid0 segment types.
   Add infrastructure for raid takeover lvconvert options.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 51f1a9a..233a216 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1599,6 +1599,12 @@ static int _dev_manager_lv_rmnodes(const struct logical_volume *lv)
 	return fs_del_lv(lv);
 }
 
+static int _lv_has_mknode(const struct logical_volume *lv)
+{
+	return (lv_is_visible(lv) &&
+		(!lv_is_thin_pool(lv) || lv_is_new_thin_pool(lv)));
+}
+
 int dev_manager_mknodes(const struct logical_volume *lv)
 {
 	struct dm_info dminfo;
@@ -1610,7 +1616,7 @@ int dev_manager_mknodes(const struct logical_volume *lv)
 
 	if ((r = _info_run(MKNODES, name, NULL, &dminfo, NULL, NULL, 0, 0, 0, 0))) {
 		if (dminfo.exists) {
-			if (lv_is_visible(lv))
+			if (_lv_has_mknode(lv))
 				r = _dev_manager_lv_mknodes(lv);
 		} else
 			r = _dev_manager_lv_rmnodes(lv);
@@ -2993,7 +2999,7 @@ static int _create_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 				r = 0;
 			continue;
 		}
-		if (lv_is_visible(lvlayer->lv)) {
+		if (_lv_has_mknode(lvlayer->lv)) {
 			if (!_dev_manager_lv_mknodes(lvlayer->lv))
 				r = 0;
 			continue;
diff --git a/test/shell/thin-overprovisioning.sh b/test/shell/thin-overprovisioning.sh
index 8a396b6..07c74cc 100644
--- a/test/shell/thin-overprovisioning.sh
+++ b/test/shell/thin-overprovisioning.sh
@@ -24,6 +24,8 @@ aux have_thin 1 3 0 || skip
 aux prepare_vg 2 33
 
 lvcreate -L32 -T $vg/pool
+# check there is link node for UNUSED thin-pool
+test -e "$DM_DEV_DIR/$vg/pool"
 
 # leave 12M free space
 lvcreate -an -n $lv1 -L16 $vg 2>&1 | tee out
@@ -31,6 +33,8 @@ vgs $vg
 
 lvcreate -n thin1 -V30 $vg/pool 2>&1 | tee out
 not grep "WARNING: Sum" out
+# check again link node is now gone for a USED thin-pool
+test ! -e "$DM_DEV_DIR/$vg/pool"
 
 # Pool gets overprovisioned
 lvcreate -an -n thin2 -V4 $vg/pool 2>&1 | tee out


