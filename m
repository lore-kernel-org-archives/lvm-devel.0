From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 19 Aug 2022 12:58:48 +0000 (GMT)
Subject: main - vdo: extend volume and pool without flush
Message-ID: <20220819125848.773E53858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e26c21cb8d5841141dcfdfc77f46da1108a81255
Commit:        e26c21cb8d5841141dcfdfc77f46da1108a81255
Parent:        309df239e3ee474f3a5337f8fa3c0a1f7b0a89e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 19 14:48:01 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 19 14:56:55 2022 +0200

vdo: extend volume and pool without flush

When the volume size is extended, there is no need to flush
IO operations (nothing can be targeting new space yet).
VDO target is supported as target that can safely work with
this condition.

Such support is also needed, when extending VDOPOOL size
while the pool is reaching its capacity - since this allows
to continue working without reaching 'out-of-space' condition
due to flushing of all in flight IO.
---
 WHATS_NEW                  | 1 +
 lib/activate/activate.c    | 6 +++++-
 lib/activate/dev_manager.c | 2 ++
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6e9a3fa1d..fac295336 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.17 - 
 ===============================
+  Extend VDO and VDOPOOL without flushing and locking fs.
   Add --valuesonly option to lvmconfig to print only values without keys.
   Updates configure with recent autoconf tooling.
   Fix lvconvert --test --type vdo-pool execution.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index db5f08b11..a92fbb8e1 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2141,7 +2141,11 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 	 * TODO: Relax this limiting condition further */
 	if (!flush_required &&
 	    (lv_is_pvmove(lv) || pvmove_lv ||
-	     (!lv_is_mirror(lv) && !lv_is_thin_pool(lv) && !lv_is_thin_volume(lv)))) {
+	     (!lv_is_mirror(lv) &&
+	      !lv_is_thin_volume(lv) &&
+	      !lv_is_thin_pool(lv) &&
+	      !lv_is_vdo(lv) &&
+	      !lv_is_vdo_pool(lv)))) {
 		log_debug("Requiring flush for LV %s.", display_lvname(lv));
 		flush_required = 1;
 	}
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8cb31008e..2bfd275fd 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3908,6 +3908,8 @@ static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 		 * non 'thin pool/volume' and  size increase */
 		else if (!lv_is_thin_volume(lv) &&
 			 !lv_is_thin_pool(lv) &&
+			 !lv_is_vdo(lv) &&
+			 !lv_is_vdo_pool(lv) &&
 			 dm_tree_node_size_changed(root))
 			dm->flush_required = 1;
 

