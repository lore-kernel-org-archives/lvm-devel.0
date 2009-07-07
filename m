From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 03:50:07 -0400
Subject: [PATCH 6/7] Add vg_set_alloc() liblvm function and move vgchange logic inside.
In-Reply-To: <1246953008-27609-6-git-send-email-dwysocha@redhat.com>
References: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-2-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-3-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-4-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-5-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-6-git-send-email-dwysocha@redhat.com>
Message-ID: <1246953008-27609-7-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add vg_set_alloc() liblvm function and move vgchange logic inside.
NOTE: We also change a failure to success in one case - setting
an alloc value that is the same as the current value.  This should
not be an error, and is inconsistent throughout the code (see
vg_set_extent_size)

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |   18 ++++++++++++++++++
 tools/vgchange.c                 |   15 ++-------------
 3 files changed, 21 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c95f5f3..1b7eee3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -443,6 +443,7 @@ int vg_extend(struct volume_group *vg, int pv_count, char **pv_names);
 int vg_set_extent_size(vg_t *vg, uint32_t new_extent_size);
 int vg_set_max_lv(vg_t *vg, uint32_t max_lv);
 int vg_set_max_pv(vg_t *vg, uint32_t max_pv);
+int vg_set_alloc(vg_t *vg, alloc_policy_t alloc);
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5b563e3..077159b 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -829,6 +829,24 @@ int vg_set_max_pv(vg_t *vg, uint32_t max_pv)
 	return 1;
 }
 
+int vg_set_alloc(vg_t *vg, alloc_policy_t alloc)
+{
+	if (alloc == ALLOC_INHERIT) {
+		log_error("Volume Group allocation policy cannot inherit "
+			  "from anything");
+		return 0;
+	}
+
+	if (alloc == vg->alloc) {
+		log_error("Volume group allocation policy is already %s",
+			  get_alloc_string(vg->alloc));
+		return 1;
+	}
+	vg->alloc = alloc;
+	return 1;
+}
+
+
 /*
  * Separate metadata areas after splitting a VG.
  * Also accepts orphan VG as destination (for vgreduce).
diff --git a/tools/vgchange.c b/tools/vgchange.c
index a095d9e..f99290a 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -179,22 +179,11 @@ static int _vgchange_alloc(struct cmd_context *cmd, struct volume_group *vg)
 
 	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
 
-	if (alloc == ALLOC_INHERIT) {
-		log_error("Volume Group allocation policy cannot inherit "
-			  "from anything");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (alloc == vg->alloc) {
-		log_error("Volume group allocation policy is already %s",
-			  get_alloc_string(vg->alloc));
-		return ECMD_FAILED;
-	}
-
 	if (!archive(vg))
 		return ECMD_FAILED;
 
-	vg->alloc = alloc;
+	if (!vg_set_alloc(vg, alloc))
+		return ECMD_FAILED;
 
 	if (!vg_write(vg) || !vg_commit(vg))
 		return ECMD_FAILED;
-- 
1.6.0.6


