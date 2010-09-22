From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Sep 2010 17:06:22 -0400
Subject: [PATCH 10/20] Add supporting functions vg_name_dup, vg_fmt_dup, vg_system_id_dup.
In-Reply-To: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
References: <1285189592-26525-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1285189592-26525-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add supporting functions for vg_name, vg_fmt, vg_system_id.
Append "_dup" to end of supporting functions to make clear the strings
are dup'd and to avoid namespace conflict with vg_name.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/vg.c |   17 +++++++++++++++++
 lib/metadata/vg.h |    3 +++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index c79f136..05477b2 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -16,6 +16,23 @@
 #include "metadata.h"
 #include "activate.h"
 
+char *vg_fmt_dup(const struct volume_group *vg)
+{
+	if (!vg->fid || !vg->fid->fmt)
+		return NULL;
+	return dm_pool_strdup(vg->vgmem, vg->fid->fmt->name);
+}
+
+char *vg_name_dup(const struct volume_group *vg)
+{
+	return dm_pool_strdup(vg->vgmem, vg->name);
+}
+
+char *vg_system_id_dup(const struct volume_group *vg)
+{
+	return dm_pool_strdup(vg->vgmem, vg->system_id);
+}
+
 char *vg_uuid_dup(const struct volume_group *vg)
 {
 	return id_format_and_copy(vg->vgmem, &vg->id);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 6071ccb..d4e6557 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -93,6 +93,9 @@ struct volume_group {
 	uint32_t mda_copies; /* target number of mdas for this VG */
 };
 
+char *vg_fmt_dup(const struct volume_group *vg);
+char *vg_name_dup(const struct volume_group *vg);
+char *vg_system_id_dup(const struct volume_group *vg);
 uint32_t vg_seqno(const struct volume_group *vg);
 uint64_t vg_status(const struct volume_group *vg);
 int vg_set_alloc_policy(struct volume_group *vg, alloc_policy_t alloc);
-- 
1.7.2.2


