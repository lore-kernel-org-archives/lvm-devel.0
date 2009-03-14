From: Milan Broz <mbroz@redhat.com>
Date: Sun, 15 Mar 2009 00:29:31 +0100
Subject: [PATCH] fix max_lv & snapshots creation problem
Message-ID: <49BC3DDB.7050508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix lv_count when manipulating with snapshots and max_lv is set.

Patch fixes these problems:
 - during the snapshot creation process, it needs create 2 LVs,
   one is cow, second becomes snapshot.
   If the code fails in vg_add_snapshot, lvcreate command will not remove
   LV cow volume.

 - if max_lv is set and VG contains snapshot, it can happen that
   during the activation lv_count is temporarily increased over the limit
   and VG metadata are not properly processed
   see https://bugzilla.redhat.com/show_bug.cgi?id=490298

 - vgcfgrestore allows restore with max_lv set to lower value that actual
   LV count. This later leads to situation that max_lv is completely ignored.

 - vgck doesn't call vg_validate(). It should at least try:-)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/metadata.c       |    7 +++++++
 lib/metadata/snapshot_manip.c |   11 ++++++++---
 test/t-lvcreate-usage.sh      |    9 +++++++++
 tools/lvcreate.c              |    2 +-
 tools/vgck.c                  |    3 +++
 5 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 81a7fe2..7848d82 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1461,6 +1461,13 @@ int vg_validate(struct volume_group *vg)
 		r = 0;
 	}
 
+	if (vg->max_lv && (vg->max_lv < vg->lv_count)) {
+		log_error("Internal error: Volume group %s contains %u volumes"
+			  " but the limit is set to %u.",
+			  vg->name, vg->lv_count, vg->max_lv);
+		r = 0;
+	}
+
 	return r;
 }
 
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 9531c92..d007fcd 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -76,6 +76,14 @@ int vg_add_snapshot(const char *name, struct logical_volume *origin,
 		return 0;
 	}
 
+	/*
+	 * Set origin lv count in advance to prevent fail because
+	 * of temporary violation of LV limits.
+	 */
+	origin->origin_count++;
+	origin->vg->snapshot_count++;
+	origin->vg->lv_count--;
+
 	if (!(snap = lv_create_empty(name ? name : "snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
 				     ALLOC_INHERIT, 1, origin->vg)))
@@ -91,9 +99,6 @@ int vg_add_snapshot(const char *name, struct logical_volume *origin,
 	seg->cow = cow;
 	seg->lv->status |= SNAPSHOT;
 
-	origin->origin_count++;
-	origin->vg->snapshot_count++;
-	origin->vg->lv_count--;
 	cow->snapshot = seg;
 
 	cow->status &= ~VISIBLE_LV;
diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 4e78e9e..13abbdf 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -58,3 +58,12 @@ not lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err
 grep "^  Invalid stripe size 3\.00 KB\$" err
 case $(lvdisplay $vg) in "") true ;; *) false ;; esac
 
+# Setting max_lv works. (bz490298)
+vgchange -l 4 $vg
+lvcreate -l1 -n $lv1 $vg
+lvcreate -l1 -s -n $lv2 $vg/$lv1
+lvcreate -l1 -n $lv3 $vg
+not lvcreate -l1 -n $lv4 $vg
+vgs $vg
+lvremove -ff $vg
+vgchange -l 0 $vg
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 1f14eb1..e25ecdd 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -836,7 +836,7 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		if (!vg_add_snapshot(NULL, org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
 			log_error("Couldn't create snapshot.");
-			return 0;
+			goto deactivate_and_revert_new_lv;
 		}
 
 		/* store vg on disk(s) */
diff --git a/tools/vgck.c b/tools/vgck.c
index 1fb6c03..26eab99 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -33,6 +33,9 @@ static int vgck_single(struct cmd_context *cmd __attribute((unused)),
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return ECMD_FAILED;
 
+	if (!vg_validate(vg))
+		return ECMD_FAILED;
+
 	return ECMD_PROCESSED;
 }
 



