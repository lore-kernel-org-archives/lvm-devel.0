From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 22:52:54 -0400
Subject: [PATCH 23/38] Add mda_copies to VG structures and initialization.
In-Reply-To: <1277520789-6808-23-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-1-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-2-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-3-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-4-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-5-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-6-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-7-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-8-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-9-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-10-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-11-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-12-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-13-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-14-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-15-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-16-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-17-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-18-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-19-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-20-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-21-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-22-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-23-git-send-email-dwysocha@redhat.com>
Message-ID: <1277520789-6808-24-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a field to struct volume_group to later implement metadata
balancing:
- mda_copies: target # of non-ignored mdas in the VG; default 0 (do
not control pv 'ignore mdas' bit.

This patch just adds the parameter to the structures with the default
values but does not modify any commands.  Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/config/defaults.h            |    1 +
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |    1 +
 tools/toollib.c                  |    2 ++
 4 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 3c383d0..0d8cb9c 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -61,6 +61,7 @@
 #define DEFAULT_STRIPESIZE 64	/* KB */
 #define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
+#define DEFAULT_VGMETADATACOPIES 0
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
 #define DEFAULT_UDEV_RULES 1
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7a66743..b9f5844 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -281,6 +281,7 @@ struct volume_group {
 	 * 0 for success else appropriate FAILURE_* bits set.
 	 */
 	uint32_t read_status;
+	uint32_t mda_copies; /* target number of mdas for this VG */
 };
 
 /* There will be one area for each stripe */
@@ -890,6 +891,7 @@ struct vgcreate_params {
 	size_t max_lv;
 	alloc_policy_t alloc;
 	int clustered; /* FIXME: put this into a 'status' variable instead? */
+	uint32_t metadata_copies;
 };
 
 int vgcreate_params_validate(struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 18e3760..d81fcd1 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -910,6 +910,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	vg->max_pv = DEFAULT_MAX_PV;
 
 	vg->alloc = DEFAULT_ALLOC_POLICY;
+	vg->mda_copies = DEFAULT_VGMETADATACOPIES;
 
 	vg->pv_count = 0;
 	dm_list_init(&vg->pvs);
diff --git a/tools/toollib.c b/tools/toollib.c
index e6791e2..02b06fd 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1187,6 +1187,7 @@ void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
 		vp_def->max_lv = vg->max_lv;
 		vp_def->alloc = vg->alloc;
 		vp_def->clustered = vg_is_clustered(vg);
+		vp_def->metadata_copies = vg->mda_copies;
 	} else {
 		vp_def->vg_name = NULL;
 		vp_def->extent_size = DEFAULT_EXTENT_SIZE * 2;
@@ -1194,6 +1195,7 @@ void vgcreate_params_set_defaults(struct vgcreate_params *vp_def,
 		vp_def->max_lv = DEFAULT_MAX_LV;
 		vp_def->alloc = DEFAULT_ALLOC_POLICY;
 		vp_def->clustered = DEFAULT_CLUSTERED;
+		vp_def->metadata_copies = DEFAULT_VGMETADATACOPIES;
 	}
 }
 
-- 
1.6.0.6


