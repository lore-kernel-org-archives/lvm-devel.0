From: David Teigland <teigland@sourceware.org>
Date: Fri, 24 Apr 2020 16:16:55 +0000 (GMT)
Subject: master - remove vg_read_error
Message-ID: <20200424161655.82395386EC42@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d945b53ff7076bf7713f5e3b9ad7b79ed1db14c0
Commit:        d945b53ff7076bf7713f5e3b9ad7b79ed1db14c0
Parent:        4047a321285fc0d1a70fd519fb53fc778fe6093b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 24 11:14:29 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 24 11:14:29 2020 -0500

remove vg_read_error

Once converted results to error numbers but is now just a null check.
---
 lib/metadata/metadata-exported.h |  3 ---
 lib/metadata/metadata.c          | 11 -----------
 tools/vgmerge.c                  |  4 +---
 tools/vgsplit.c                  |  2 +-
 4 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 52bc77673..083f74a28 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -744,9 +744,6 @@ struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_
 			 const char *vgid, uint32_t read_flags, uint32_t lockd_state);
 struct volume_group *vg_read_orphans(struct cmd_context *cmd, const char *orphan_vgname);
 
-/* this is historical and being removed, don't use */
-uint32_t vg_read_error(struct volume_group *vg_handle);
-
 /* pe_start and pe_end relate to any existing data so that new metadata
 * areas can avoid overlap */
 struct physical_volume *pv_create(const struct cmd_context *cmd,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b42d7a9b9..4b8dce902 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4010,17 +4010,6 @@ static int _access_vg_exported(struct cmd_context *cmd, struct volume_group *vg)
 	return 0;
 }
 
-/*
- * Test the validity of a VG handle returned by vg_read() or vg_read_for_update().
- */
-uint32_t vg_read_error(struct volume_group *vg_handle)
-{
-	if (!vg_handle)
-		return FAILED_ALLOCATION;
-
-	return SUCCESS;
-}
-
 struct format_instance *alloc_fid(const struct format_type *fmt,
 				  const struct format_instance_ctx *fic)
 {
diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index 903504c57..895018a6f 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -21,10 +21,8 @@ static struct volume_group *_vgmerge_vg_read(struct cmd_context *cmd,
 	struct volume_group *vg;
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0, 0);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
+	if (!vg)
 		return NULL;
-	}
 
 	if (vg_is_shared(vg)) {
 		log_error("vgmerge not allowed for lock_type %s", vg->lock_type);
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index 3dc19ecea..1a422e683 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -691,7 +691,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 
 		vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0, 0);
 
-		if (vg_read_error(vg_to)) {
+		if (!vg_to) {
 			log_error("Volume group \"%s\" became inconsistent: "
 				  "please fix manually", vg_name_to);
 			goto bad;



