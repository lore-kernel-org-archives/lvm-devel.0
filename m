From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 01:52:19 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090726015219.5263.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 01:52:19

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Remove unneeded pv_create wrapper function.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.260&r2=1.261

--- LVM2/lib/metadata/metadata.c	2009/07/24 15:15:26	1.260
+++ LVM2/lib/metadata/metadata.c	2009/07/26 01:52:19	1.261
@@ -44,16 +44,6 @@
 					uint64_t *label_sector,
 					int warnings, int scan_label_only);
 
-static struct physical_volume *_pv_create(const struct format_type *fmt,
-				  struct device *dev,
-				  struct id *id, uint64_t size,
-				  unsigned long data_alignment,
-				  uint64_t pe_start,
-				  uint32_t existing_extent_count,
-				  uint32_t existing_extent_size,
-				  int pvmetadatacopies,
-				  uint64_t pvmetadatasize, struct dm_list *mdas);
-
 static int _pv_write(struct cmd_context *cmd __attribute((unused)),
 		     struct physical_volume *pv,
 	     	     struct dm_list *mdas, int64_t label_sector);
@@ -964,44 +954,6 @@
 	return 1;
 }
 
-/**
- * pv_create - initialize a physical volume for use with a volume group
- * @fmt: format type
- * @dev: PV device to initialize
- * @id: PV UUID to use for initialization
- * @size: size of the PV in sectors
- * @data_alignment: requested alignment of data
- * @pe_start: physical extent start
- * @existing_extent_count
- * @existing_extent_size
- * @pvmetadatacopies
- * @pvmetadatasize
- * @mdas
- *
- * Returns:
- *   PV handle - physical volume initialized successfully
- *   NULL - invalid parameter or problem initializing the physical volume
- *
- * Note:
- *   FIXME - liblvm todo - tidy up arguments for external use (fmt, mdas, etc)
- */
-pv_t *pv_create(const struct cmd_context *cmd,
-		struct device *dev,
-		struct id *id, uint64_t size,
-		unsigned long data_alignment,
-		uint64_t pe_start,
-		uint32_t existing_extent_count,
-		uint32_t existing_extent_size,
-		int pvmetadatacopies,
-		uint64_t pvmetadatasize, struct dm_list *mdas)
-{
-	return _pv_create(cmd->fmt, dev, id, size, data_alignment, pe_start,
-			  existing_extent_count,
-			  existing_extent_size,
-			  pvmetadatacopies,
-			  pvmetadatasize, mdas);
-}
-
 static void _free_pv(struct dm_pool *mem, struct physical_volume *pv)
 {
 	dm_pool_free(mem, pv);
@@ -1035,8 +987,28 @@
 	return pv;
 }
 
-/* Sizes in sectors */
-static struct physical_volume *_pv_create(const struct format_type *fmt,
+/**
+ * pv_create - initialize a physical volume for use with a volume group
+ *
+ * @fmt: format type
+ * @dev: PV device to initialize
+ * @size: size of the PV in sectors
+ * @data_alignment: requested alignment of data
+ * @pe_start: physical extent start
+ * @existing_extent_count
+ * @existing_extent_size
+ * @pvmetadatacopies
+ * @pvmetadatasize
+ * @mdas
+ *
+ * Returns:
+ *   PV handle - physical volume initialized successfully
+ *   NULL - invalid parameter or problem initializing the physical volume
+ *
+ * Note:
+ *   FIXME: shorten argument list and replace with explict 'set' functions
+ */
+struct physical_volume *pv_create(const struct cmd_context *cmd,
 				  struct device *dev,
 				  struct id *id, uint64_t size,
 				  unsigned long data_alignment,
@@ -1046,6 +1018,7 @@
 				  int pvmetadatacopies,
 				  uint64_t pvmetadatasize, struct dm_list *mdas)
 {
+	const struct format_type *fmt = cmd->fmt;
 	struct dm_pool *mem = fmt->cmd->mem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
 


