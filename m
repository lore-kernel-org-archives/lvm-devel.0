From: Milan Broz <mbroz@redhat.com>
Date: Wed,  6 May 2009 16:43:04 +0200
Subject: [PATCH 7/7] Remove import paramater from lv_create_empty.
In-Reply-To: <cover.1241620083.git.mbroz@redhat.com>
References: <cover.1241620083.git.mbroz@redhat.com>
Message-ID: <a46a601acc54a18f46dc8a0fd483497cec77d046.1241620083.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Now the max_lv check is performed in vg_add_lv and import
parameter in lv_create_empty has no use.

Patch also adds simple max_lv tests into testsuite

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c          |   17 ++++++++---------
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/mirror.c            |    4 ++--
 lib/metadata/snapshot_manip.c    |    2 +-
 test/t-lvcreate-usage.sh         |   22 ++++++++++++++++++++--
 test/test-utils.sh               |    1 +
 tools/lvcreate.c                 |    4 ++--
 tools/pvmove.c                   |    2 +-
 8 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fa83614..0ddf173 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1811,19 +1811,12 @@ struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
 				       uint32_t status,
 				       alloc_policy_t alloc,
-				       int import,
 				       struct volume_group *vg)
 {
 	struct format_instance *fi = vg->fid;
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
 
-	if (vg->max_lv && (vg->max_lv == vg->lv_count)) {
-		log_error("Maximum number of logical volumes (%u) reached "
-			  "in volume group %s", vg->max_lv, vg->name);
-		return NULL;
-	}
-
 	if (strstr(name, "%d") &&
 	    !(name = generate_lv_name(vg, name, dname, sizeof(dname)))) {
 		log_error("Failed to generate unique name for the new "
@@ -1831,7 +1824,7 @@ struct logical_volume *lv_create_empty(const char *name,
 		return NULL;
 	}
 
-	if (!import)
+	if (status & VISIBLE_LV)
 		log_verbose("Creating logical volume %s", name);
 
 	if (!(lv = dm_pool_zalloc(vg->vgmem, sizeof(*lv))))
@@ -1938,6 +1931,12 @@ int vg_add_lv(struct volume_group *vg, struct logical_volume *lv)
 {
 	struct lv_list *lvl;
 
+	if (lv_is_visible(lv) && vg->max_lv && vg->max_lv <= vg->lv_count) {
+		log_error("Maximum number of logical volumes (%u) reached "
+			  "in volume group %s", vg->max_lv, vg->name);
+		return 0;
+	}
+
 	if (!(lvl = dm_pool_zalloc(vg->vgmem, sizeof(*lvl))))
 		return_0;
 
@@ -2426,7 +2425,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	}
 
 	if (!(layer_lv = lv_create_empty(name, NULL, LVM_READ | LVM_WRITE,
-					 ALLOC_INHERIT, 0, lv_where->vg))) {
+					 ALLOC_INHERIT, lv_where->vg))) {
 		log_error("Creation of layer LV failed");
 		return NULL;
 	}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ffb1510..85000a5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -446,7 +446,6 @@ struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
 				       uint32_t status,
 				       alloc_policy_t alloc,
-				       int import,
 				       struct volume_group *vg);
 
 /* Write out LV contents */
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index f46381e..6c2cc10 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -928,7 +928,7 @@ static int _create_mimage_lvs(struct alloc_handle *ah,
 	for (m = 0; m < num_mirrors; m++) {
 		if (!(img_lvs[m] = lv_create_empty(img_name,
 					     NULL, LVM_READ | LVM_WRITE,
-					     ALLOC_INHERIT, 0, lv->vg))) {
+					     ALLOC_INHERIT, lv->vg))) {
 			log_error("Aborting. Failed to create mirror image LV. "
 				  "Remove new LV and retry.");
 			return 0;
@@ -1262,7 +1262,7 @@ static struct logical_volume *_create_mirror_log(struct logical_volume *lv,
 
 	if (!(log_lv = lv_create_empty(log_name, NULL,
 				       LVM_READ | LVM_WRITE,
-				       alloc, 0, lv->vg)))
+				       alloc, lv->vg)))
 		return_NULL;
 
 	if (!lv_add_log_segment(ah, log_lv))
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 154c404..379587f 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -85,7 +85,7 @@ int vg_add_snapshot(struct logical_volume *origin,
 
 	if (!(snap = lv_create_empty("snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
-				     ALLOC_INHERIT, 1, origin->vg))) {
+				     ALLOC_INHERIT, origin->vg))) {
 		lv_set_visible(cow);
 		return_0;
 	}
diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 13abbdf..48a4f4e 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -13,7 +13,7 @@
 
 . ./test-utils.sh
 
-aux prepare_pvs 2
+aux prepare_pvs 4
 aux pvcreate --metadatacopies 0 $dev1
 vgcreate -cn $vg $devs
 
@@ -59,11 +59,29 @@ grep "^  Invalid stripe size 3\.00 KB\$" err
 case $(lvdisplay $vg) in "") true ;; *) false ;; esac
 
 # Setting max_lv works. (bz490298)
-vgchange -l 4 $vg
+vgchange -l 3 $vg
 lvcreate -l1 -n $lv1 $vg
 lvcreate -l1 -s -n $lv2 $vg/$lv1
 lvcreate -l1 -n $lv3 $vg
 not lvcreate -l1 -n $lv4 $vg
+
+lvremove -ff $vg/$lv3
+lvcreate -l1 -s -n $lv3 $vg/$lv1
+not lvcreate -l1 -n $lv4 $vg
+not lvcreate -l1 -m1 -n $lv4 $vg
+
+lvremove -ff $vg/$lv3
+lvcreate -l1 -m1 -n $lv3 $vg
+not lvcreate -l1 -n $lv4 $vg
+not lvcreate -l1 -m1 -n $lv4 $vg
+
+lvconvert -m0 $vg/$lv3
+lvconvert -m2 -i 1 $vg/$lv3
+lvconvert -m1 $vg/$lv3
+
+not vgchange -l 2
+vgchange -l 4
 vgs $vg
+
 lvremove -ff $vg
 vgchange -l 0 $vg
diff --git a/test/test-utils.sh b/test/test-utils.sh
index e078a33..7c57972 100644
--- a/test/test-utils.sh
+++ b/test/test-utils.sh
@@ -128,6 +128,7 @@ prepare_devs() {
 	lv1=LV1
 	lv2=LV2
 	lv3=LV3
+	lv4=LV4
 }
 
 disable_dev() {
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 069cc0e..1d06c4b 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -577,7 +577,7 @@ static struct logical_volume *_create_virtual_origin(struct cmd_context *cmd,
 	}
 
 	if (!(lv = lv_create_empty(vorigin_name, NULL, permission,
-				   ALLOC_INHERIT, 0, vg)))
+				   ALLOC_INHERIT, vg)))
 		return_0;
 
 	if (!lv_extend(lv, segtype, 1, 0, 1, voriginextents, NULL, 0u, 0u,
@@ -824,7 +824,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (!(lv = lv_create_empty(lv_name ? lv_name : "lvol%d", NULL,
-				   status, lp->alloc, 0, vg)))
+				   status, lp->alloc, vg)))
 		return_0;
 
 	if (lp->read_ahead) {
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 55285df..d760802 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -191,7 +191,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	/* FIXME Cope with non-contiguous => splitting existing segments */
 	if (!(lv_mirr = lv_create_empty("pvmove%d", NULL,
 					LVM_READ | LVM_WRITE,
-					ALLOC_CONTIGUOUS, 0, vg))) {
+					ALLOC_CONTIGUOUS, vg))) {
 		log_error("Creation of temporary pvmove LV failed");
 		return NULL;
 	}
-- 
1.6.2.4


