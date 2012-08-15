From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 15 Aug 2012 08:46:01 +0000 (UTC)
Subject: master - mirror: reconfigure_mirror_images not used
Message-ID: <20120815084601.0E92B344F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00877fe47b99458e22f6e1c928505fc75aad0752
Commit:        00877fe47b99458e22f6e1c928505fc75aad0752
Parent:        54c24193f535660478e88af76340eef40dc3223c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 15 10:44:19 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 15 10:44:19 2012 +0200

mirror: reconfigure_mirror_images not used

---
 lib/metadata/metadata-exported.h |    3 +++
 lib/metadata/mirror.c            |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f46fccc..f39f968 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -761,8 +761,11 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 		   uint32_t log_count, uint32_t region_size,
 		   struct dm_list *allocatable_pvs, alloc_policy_t alloc);
 
+#if 0
+/* FIXME: reconfigure_mirror_images: remove this code? */
 int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirrors,
 			      struct dm_list *removable_pvs, unsigned remove_log);
+#endif
 int collapse_mirrored_lv(struct logical_volume *lv);
 int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage);
 
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 61e4b47..0997c58 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1219,6 +1219,8 @@ int collapse_mirrored_lv(struct logical_volume *lv)
 	return 1;
 }
 
+#if 0
+/* FIXME: reconfigure_mirror_images: remove this code? */
 static int _get_mirror_fault_policy(struct cmd_context *cmd __attribute__((unused)),
 				   int log_policy)
 {
@@ -1375,6 +1377,7 @@ int reconfigure_mirror_images(struct lv_segment *mirrored_seg, uint32_t num_mirr
 	 */
 	return 1;
 }
+#endif
 
 static int _create_mimage_lvs(struct alloc_handle *ah,
 			      uint32_t num_mirrors,


