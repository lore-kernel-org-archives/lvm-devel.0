From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  6 Apr 2010 19:53:18 -0400
Subject: [PATCH 3/5] Add del_pvl_from_vgs() and move prototypes into metadata-exported.h
In-Reply-To: <1270598000-9771-3-git-send-email-dwysocha@redhat.com>
References: <1270598000-9771-1-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-2-git-send-email-dwysocha@redhat.com>
	<1270598000-9771-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1270598000-9771-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a delete function to manage the vg->pvs list.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    7 +++++++
 lib/metadata/metadata.c          |    6 ++++++
 lib/metadata/metadata.h          |    1 -
 3 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b02a22c..865cb3b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -469,6 +469,13 @@ int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);
 int vg_set_clustered(struct volume_group *vg, int clustered);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
+/*
+ * FIXME: These functions should probably take a 'pv' as parameter. To
+ * accomplish this, add dm_list * to struct physical_volume and refactor all
+ * the callers.
+ */
+void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl);
+void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl);
 
 /* FIXME: refactor / unexport when lvremove liblvm refactoring dones */
 int remove_lvs_in_vg(struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6ceb793..dd986a1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -142,6 +142,12 @@ void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
 	vg->pv_count++;
 }
 
+void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
+{
+	vg->pv_count--;
+	dm_list_del(&pvl->list);
+}
+
 
 /**
  * add_pv_to_vg - Add a physical volume to a volume group
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 1496252..782d300 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -377,6 +377,5 @@ struct id pv_vgid(const struct physical_volume *pv);
 struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
 		 struct physical_volume *pv);
-void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl);
 
 #endif
-- 
1.6.0.6


