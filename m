From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:18 -0500
Subject: [PATCH 15/21] Add vg metadata balance parameters with defaults.
In-Reply-To: <1265754744-17319-15-git-send-email-dwysocha@redhat.com>
References: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-2-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-3-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-4-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-5-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-6-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-7-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-8-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-9-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-10-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-11-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-12-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-13-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-14-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-15-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-16-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add 3 parameters that control vg metadata balancing.
1) metadata_balance: enable metadata balancing; default 0 (disable)
2) metadata_balance_min: min # of PVs to contain metadata; default 1
3) metadata_balance_max: max # of PVs to contain metadata; default UINT_MAX
(all PVs contain metadata)

This patch just adds the parameters to the structures with the default
values but does not modify any commands.  Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/config/defaults.h            |    3 +++
 lib/metadata/metadata-exported.h |    9 +++++++++
 lib/metadata/metadata.c          |    3 +++
 tools/toollib.c                  |    6 ++++++
 4 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 94057e4..3136269 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -74,6 +74,9 @@
 #define DEFAULT_MAX_LV 0
 #define DEFAULT_ALLOC_POLICY ALLOC_NORMAL
 #define DEFAULT_CLUSTERED 0
+#define DEFAULT_METADATA_BALANCE 0
+#define DEFAULT_METADATA_BALANCE_MIN 1
+#define DEFAULT_METADATA_BALANCE_MAX UINT32_MAX
 
 #define DEFAULT_MSG_PREFIX "  "
 #define DEFAULT_CMD_NAME 0
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1ae058e..a40ffe4 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -263,6 +263,12 @@ struct volume_group {
 	 * 0 for success else appropriate FAILURE_* bits set.
 	 */
 	uint32_t read_status;
+	/*
+	 * Metadata balance parameters
+	 */
+	uint32_t metadata_balance; /* 0 - disable (default); 1 - enable */
+	uint32_t metadata_balance_min; /* min # of mdas in this VG */
+	uint32_t metadata_balance_max; /* max # of mdas in this VG */
 };
 
 /* There will be one area for each stripe */
@@ -767,6 +773,9 @@ struct vgcreate_params {
 	size_t max_lv;
 	alloc_policy_t alloc;
 	int clustered; /* FIXME: put this into a 'status' variable instead? */
+	int metadata_balance;
+	uint32_t metadata_balance_max;
+	uint32_t metadata_balance_min;
 };
 
 int vgcreate_params_validate(struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 95d74b4..6fe8008 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -832,6 +832,9 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	vg->max_pv = DEFAULT_MAX_PV;
 
 	vg->alloc = DEFAULT_ALLOC_POLICY;
+	vg->metadata_balance = DEFAULT_METADATA_BALANCE;
+	vg->metadata_balance_min = DEFAULT_METADATA_BALANCE_MIN;
+	vg->metadata_balance_max = DEFAULT_METADATA_BALANCE_MAX;
 
 	vg->pv_count = 0;
 	dm_list_init(&vg->pvs);
diff --git a/tools/toollib.c b/tools/toollib.c
index e4040f8..c868523 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1189,6 +1189,9 @@ void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
 		vp_def->max_lv = vg->max_lv;
 		vp_def->alloc = vg->alloc;
 		vp_def->clustered = vg_is_clustered(vg);
+		vp_def->metadata_balance = vg->metadata_balance;
+		vp_def->metadata_balance_min = vg->metadata_balance_min;
+		vp_def->metadata_balance_max = vg->metadata_balance_max;
 	} else {
 		vp_def->vg_name = NULL;
 		vp_def->extent_size = DEFAULT_EXTENT_SIZE * 2;
@@ -1196,6 +1199,9 @@ void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
 		vp_def->max_lv = DEFAULT_MAX_LV;
 		vp_def->alloc = DEFAULT_ALLOC_POLICY;
 		vp_def->clustered = DEFAULT_CLUSTERED;
+		vp_def->metadata_balance = DEFAULT_METADATA_BALANCE;
+		vp_def->metadata_balance_min = DEFAULT_METADATA_BALANCE_MIN;
+		vp_def->metadata_balance_max = DEFAULT_METADATA_BALANCE_MAX;
 	}
 }
 
-- 
1.6.0.6


