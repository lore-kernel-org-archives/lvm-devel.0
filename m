From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  5 Apr 2010 15:51:38 -0400
Subject: [PATCH 4/5] Add add_pvl_to_vgs() - helper function to add a pv to a vg list.
In-Reply-To: <1270497099-13259-4-git-send-email-dwysocha@redhat.com>
References: <1270497099-13259-1-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-2-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-3-git-send-email-dwysocha@redhat.com>
	<1270497099-13259-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1270497099-13259-5-git-send-email-dwysocha@redhat.com>
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
 lib/format1/import-export.c   |    3 +--
 lib/format_text/import_vsn1.c |    3 +--
 lib/metadata/metadata.c       |   11 ++++++++---
 lib/metadata/metadata.h       |    1 +
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 2ffc19e..e37d59e 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -437,8 +437,7 @@ int import_pvs(const struct format_type *fmt, struct dm_pool *mem,
 			return_0;
 
 		pvl->pv->fmt = fmt;
-		dm_list_add(&vg->pvs, &pvl->list);
-		vg->pv_count++;
+		add_pvl_to_vgs(vg, pvl);
 	}
 
 	return 1;
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index cf2c9df..ed508cf 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -271,8 +271,7 @@ static int _read_pv(struct format_instance *fid, struct dm_pool *mem,
 
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
-	vg->pv_count++;
-	dm_list_add(&vg->pvs, &pvl->list);
+	add_pvl_to_vgs(vg, pvl);
 
 	return 1;
 }
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9e6d9ba..6ceb793 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -136,6 +136,13 @@ out:
 	return pv->pe_align_offset;
 }
 
+void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
+{
+	dm_list_add(&vg->pvs, &pvl->list);
+	vg->pv_count++;
+}
+
+
 /**
  * add_pv_to_vg - Add a physical volume to a volume group
  * @vg - volume group to add to
@@ -230,9 +237,7 @@ int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 	}
 
 	pvl->pv = pv;
-	dm_list_add(&vg->pvs, &pvl->list);
-
-	vg->pv_count++;
+	add_pvl_to_vgs(vg, pvl);
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
 
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


