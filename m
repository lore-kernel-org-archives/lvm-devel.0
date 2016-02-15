From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:23 +0000 (UTC)
Subject: master - metadata: add_pv_to_vg: add 'new_pv' arg to state if the PV is about to be created
Message-ID: <20160215120823.742F260DC7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2950adc2ab67fd14173807164f9829f5f53cd33c
Commit:        2950adc2ab67fd14173807164f9829f5f53cd33c
Parent:        4cbaaa5c98c78784e9eab5489c12d2e72e952f32
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 12 14:37:50 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

metadata: add_pv_to_vg: add 'new_pv' arg to state if the PV is about to be created

---
 lib/metadata/metadata.c |   11 +++++++----
 lib/metadata/metadata.h |    3 ++-
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0ca17f6..981bfbc 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -177,7 +177,8 @@ void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
  * FIXME: remove pv_name - obtain safely from pv
  */
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
-		 struct physical_volume *pv, struct pvcreate_params *pp)
+		 struct physical_volume *pv, struct pvcreate_params *pp,
+		 int new_pv)
 {
 	struct pv_to_write *pvw;
 	struct pv_list *pvl;
@@ -284,7 +285,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 			return 0;
 		}
 		pvw->pv = pv;
-		pvw->pp = pp;
+		pvw->pp = new_pv ? pp : NULL;
 		dm_list_add(&vg->pvs_to_write, &pvw->list);
 	}
 
@@ -710,6 +711,7 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 			       unsigned int *max_phys_block_size)
 {
 	struct physical_volume *pv;
+	int new_pv = 0;
 
 	pv = find_pv_by_name(vg->cmd, pv_name, 1, 1);
 
@@ -720,13 +722,14 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 	} else if (!pv && pp) {
 		if (!(pv = pvcreate_vol(vg->cmd, pv_name, pp, 0)))
 			return_0;
+		new_pv = 1;
 	}
 
 	if (!(check_dev_block_size_for_vg(pv->dev, (const struct volume_group *) vg,
 					  max_phys_block_size)))
 		goto_bad;
 
-	if (!add_pv_to_vg(vg, pv_name, pv, pp))
+	if (!add_pv_to_vg(vg, pv_name, pv, pp, new_pv))
 		goto_bad;
 
 	return 1;
@@ -1610,7 +1613,7 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp)
 
 static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_write *pvw)
 {
-	int zero = pvw->pp->zero;
+	int zero = pvw->pp ? pvw->pp->zero : 1;
 	struct physical_volume *pv = pvw->pv;
 	struct device *dev = pv->dev;
 	const char *pv_name = dev_name(dev);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 3891b26..3f5f5ae 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -496,7 +496,8 @@ const struct format_type *pv_format_type(const struct physical_volume *pv);
 struct id pv_vgid(const struct physical_volume *pv);
 
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
-		 struct physical_volume *pv, struct pvcreate_params *pp);
+		 struct physical_volume *pv, struct pvcreate_params *pp,
+		 int new_pv);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tagsl);


