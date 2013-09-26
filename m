From: dongmao zhang <dmzhang@suse.com>
Date: Thu, 26 Sep 2013 18:53:30 +0800
Subject: [PATCH 3/4] add support_delay_flush to device-mapper
In-Reply-To: <cover.1380191958.git.dmzhang@suse.com>
References: <cover.1380191958.git.dmzhang@suse.com>
Message-ID: <f6faaad4a20908d50baa81abc69cb027327b2722.1380191958.git.dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 libdm/libdevmapper.h  |    3 +++
 libdm/libdm-deptree.c |    8 ++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index b287eef..dab07d6 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -667,6 +667,9 @@ int dm_tree_node_add_mirror_target(struct dm_tree_node *node,
 #define DM_BLOCK_ON_ERROR	0x00000004	/* On error, suspend I/O */
 #define DM_CORELOG		0x00000008	/* In-memory log */
 
+/*for cluster raid1, delay flush to improve performance*/
+#define DM_SUPPORT_DELAY_FLUSH		0x00000010
+
 int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
 					  uint32_t region_size,
 					  unsigned clustered,
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 752a44b..ff13b38 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2054,6 +2054,7 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 				     char *params, size_t paramsize)
 {
 	int block_on_error = 0;
+	int support_delay_flush;
 	int handle_errors = 0;
 	int dm_log_userspace = 0;
 	struct utsname uts;
@@ -2107,6 +2108,9 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 		 */
 		if (KERNEL_VERSION(kmaj, kmin, krel) >= KERNEL_VERSION(2, 6, 31))
 			dm_log_userspace = 1;
+
+		if(seg->flags & DM_SUPPORT_DELAY_FLUSH)
+			support_delay_flush = 1;
 	}
 
 	/* Region size */
@@ -2164,6 +2168,10 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 	if (block_on_error)
 		EMIT_PARAMS(pos, " block_on_error");
 
+	if (dm_log_userspace && support_delay_flush)
+		EMIT_PARAMS(pos, " support_delay_flush");
+
+
 	EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
 	if (_emit_areas_line(dmt, seg, params, paramsize, &pos) <= 0)
-- 
1.7.3.4


