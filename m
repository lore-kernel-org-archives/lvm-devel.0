From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:25:09 +0200
Subject: [PATCH 9/9] Check max_lv on only place and force the check only for new volume.
In-Reply-To: <cover.1242227458.git.mbroz@redhat.com>
References: <cover.1242227458.git.mbroz@redhat.com>
Message-ID: <ae4bfc0f2c377f3c23cabf4c6834ad17c420f14a.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We can temporarily violate max_lv during mirror conversion etc.

(If the operation fails, orphan mirror images are visible to administrator
for manual remove for example. Not that this should ever happen:-)

Force limit only for lvcreate (and vg merge) command.

Patch also adds simple max_lv tests into testsuite

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c          |   24 +++++++++++++++++++-----
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    8 ++------
 test/t-lvcreate-usage.sh         |   23 ++++++++++++++++++++++-
 test/test-utils.sh               |    1 +
 tools/lvcreate.c                 |    6 ++++++
 6 files changed, 51 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1c758ea..b1ceef4 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1805,6 +1805,20 @@ char *generate_lv_name(struct volume_group *vg, const char *format,
 	return buffer;
 }
 
+int vg_max_lv_reached(struct volume_group *vg)
+{
+	if (!vg->max_lv)
+		return 0;
+
+	if (vg->max_lv > volumes_count(vg))
+		return 0;
+
+	log_verbose("Maximum number of logical volumes (%u) reached "
+		    "in volume group %s", vg->max_lv, vg->name);
+
+	return 1;
+}
+
 /*
  * Create a new empty LV.
  */
@@ -1818,11 +1832,8 @@ struct logical_volume *lv_create_empty(const char *name,
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
 
-	if (vg->max_lv && (vg->max_lv == volumes_count(vg))) {
-		log_error("Maximum number of logical volumes (%u) reached "
-			  "in volume group %s", vg->max_lv, vg->name);
-		return NULL;
-	}
+	if (vg_max_lv_reached(vg))
+		stack;
 
 	if (strstr(name, "%d") &&
 	    !(name = generate_lv_name(vg, name, dname, sizeof(dname)))) {
@@ -1937,6 +1948,9 @@ int vg_link_lv(struct volume_group *vg, struct logical_volume *lv)
 {
 	struct lv_list *lvl;
 
+	if (vg_max_lv_reached(vg))
+		stack;
+
 	if (!(lvl = dm_pool_zalloc(vg->vgmem, sizeof(*lvl))))
 		return_0;
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1477a0b..ca6a0c2 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -557,6 +557,7 @@ int vg_remove_snapshot(struct logical_volume *cow);
 int vg_check_status(const struct volume_group *vg, uint32_t status);
 
 unsigned volumes_count(const struct volume_group *vg);
+int vg_max_lv_reached(struct volume_group *vg);
 
 /*
 * Mirroring functions
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 82ee6cb..0894320 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1528,12 +1528,8 @@ int vg_validate(struct volume_group *vg)
 		r = 0;
 	}
 
-	if (vg->max_lv && (vg->max_lv < volumes_count(vg))) {
-		log_error("Internal error: Volume group %s contains %u volumes"
-			  " but the limit is set to %u.",
-			  vg->name, volumes_count(vg), vg->max_lv);
-		r = 0;
-	}
+	if (vg_max_lv_reached(vg))
+		stack;
 
 	return r;
 }
diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 6c60b15..43cf716 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -55,12 +55,33 @@ grep "^  Invalid stripe size 3\.00 KB\$" err
 case $(lvdisplay $vg) in "") true ;; *) false ;; esac
 
 # Setting max_lv works. (bz490298)
-vgchange -l 4 $vg
+lvremove -ff $vg
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
+lvs
+vgs -o +max_lv
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
index 1d06c4b..ed29855 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -613,6 +613,12 @@ static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
+	if (vg_max_lv_reached(vg)) {
+		log_error("Maximum number of logical volumes (%u) reached "
+			  "in volume group %s", vg->max_lv, vg->name);
+		return 0;
+	}
+
 	if (lp->mirrors > 1 && !(vg->fid->fmt->features & FMT_SEGMENTS)) {
 		log_error("Metadata does not support mirroring.");
 		return 0;
-- 
1.6.2.4


