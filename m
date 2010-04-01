From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  1 Apr 2010 17:57:29 -0400
Subject: [PATCH 3/6] Add add_pvl_to_vgs() - helper function to add a pv to a vg list.
In-Reply-To: <1270159052-1181-3-git-send-email-dwysocha@redhat.com>
References: <1270159052-1181-1-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-2-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1270159052-1181-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Small refactor of main places in the code where a pv is added to a
vg into a small function which adds the pv to the list and updates
the vg counts.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/format_text/import_vsn1.c |    5 +----
 lib/metadata/metadata.c       |   16 +++++++++++-----
 lib/metadata/metadata.h       |    1 +
 3 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index cf2c9df..48fa7f2 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -269,10 +269,7 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 	if (!alloc_pv_segment_whole_pv(mem, pv))
 		return_0;
 
-	vg->extent_count += pv->pe_count;
-	vg->free_count += pv->pe_count;
-	vg->pv_count++;
-	dm_list_add(&vg->pvs, &pvl->list);
+	add_pvl_to_vgs(vg, pvl);
 
 	return 1;
 }
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9e6d9ba..a60ea34 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -136,6 +136,16 @@ out:
 	return pv->pe_align_offset;
 }
 
+void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
+{
+	dm_list_add(&vg->pvs, &pvl->list);
+
+	vg->pv_count++;
+	vg->extent_count += pvl->pv->pe_count;
+	vg->free_count += pvl->pv->pe_count;
+}
+
+
 /**
  * add_pv_to_vg - Add a physical volume to a volume group
  * @vg - volume group to add to
@@ -230,11 +240,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	}
 
 	pvl->pv = pv;
-	dm_list_add(&vg->pvs, &pvl->list);
-
-	vg->pv_count++;
-	vg->extent_count += pv->pe_count;
-	vg->free_count += pv->pe_count;
+	add_pvl_to_vgs(vg, pvl);
 
 	return 1;
 }
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 782d300..1496252 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -377,5 +377,6 @@ struct id pv_vgid(const struct physical_volume *pv);
 struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv);
+void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl);
 
 #endif
-- 
1.6.0.6


