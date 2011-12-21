From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Dec 2011 12:52:39 -0000
Subject: LVM2/libdm libdevmapper.h libdm-deptree.c
Message-ID: <20111221125239.12669.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-21 12:52:38

Modified files:
	libdm          : libdevmapper.h libdm-deptree.c 

Log message:
	Add Thin API for parsing thin status
	
	Add dm_get_status_thin_pool and dm_get_status_thin functions to
	parse 'params' argument which is received via dm_get_next_target.
	
	Returns filed structure allocated from given mempool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.172&r2=1.173
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147

--- LVM2/libdm/libdevmapper.h	2011/12/21 12:47:45	1.172
+++ LVM2/libdm/libdevmapper.h	2011/12/21 12:52:38	1.173
@@ -238,6 +238,29 @@
 			 void *next, uint64_t *start, uint64_t *length,
 			 char **target_type, char **params);
 
+/* Parse params from STATUS call for thin_pool target */
+struct dm_pool;
+
+struct dm_status_thin_pool {
+	uint64_t transaction_id;
+	uint64_t used_meta_blocks;
+	uint64_t total_meta_blocks;
+	uint64_t used_data_blocks;
+	uint64_t total_data_blocks;
+};
+
+int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
+			    struct dm_status_thin_pool **status);
+
+/* Parse params from STATUS call for thin target */
+struct dm_status_thin {
+	uint64_t mapped_sectors;
+	uint64_t highest_mapped_sector;
+};
+
+int dm_get_status_thin(struct dm_pool *mem, const char *params,
+		       struct dm_status_thin **status);
+
 /*
  * Call this to actually run the ioctl.
  */
--- LVM2/libdm/libdm-deptree.c	2011/11/12 22:44:10	1.146
+++ LVM2/libdm/libdm-deptree.c	2011/12/21 12:52:38	1.147
@@ -3030,6 +3030,54 @@
 	return 1;
 }
 
+
+int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
+			    struct dm_status_thin_pool **status)
+{
+	struct dm_status_thin_pool *s;
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin_pool)))) {
+		log_error("Failed to allocate thin_pool status structure.");
+		return 0;
+	}
+
+	if (sscanf(params, "%" PRIu64 " %" PRIu64 "/%" PRIu64 " %" PRIu64 "/%" PRIu64,
+		   &s->transaction_id,
+		   &s->used_meta_blocks,
+		   &s->total_meta_blocks,
+		   &s->used_data_blocks,
+		   &s->total_data_blocks) != 5) {
+		log_error("Failed to parse thin pool params: %s.", params);
+		return 0;
+	}
+
+	*status = s;
+
+	return 1;
+}
+
+int dm_get_status_thin(struct dm_pool *mem, const char *params,
+		       struct dm_status_thin **status)
+{
+	struct dm_status_thin *s;
+
+	if (!(s = dm_pool_zalloc(mem, sizeof(struct dm_status_thin)))) {
+		log_error("Failed to allocate thin status structure.");
+		return 0;
+	}
+
+	if (sscanf(params, "%" PRIu64 " %" PRIu64,
+		   &s->mapped_sectors,
+		   &s->highest_mapped_sector) != 2) {
+		log_error("Failed to parse thin params: %s.", params);
+		return 0;
+	}
+
+	*status = s;
+
+	return 1;
+}
+
 static int _add_area(struct dm_tree_node *node, struct load_segment *seg, struct dm_tree_node *dev_node, uint64_t offset)
 {
 	struct seg_area *area;


