From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 00:05:46 -0400
Subject: [PATCH 1/8] Remove unneeded pv_create wrapper function.
In-Reply-To: <1248235553-13519-1-git-send-email-dwysocha@redhat.com>
References: <1248235553-13519-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1248235553-13519-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata.c |   73 +++++++++++++++--------------------------------
 1 files changed, 23 insertions(+), 50 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 03e0810..ce699e6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -44,16 +44,6 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
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
@@ -972,44 +962,6 @@ int vg_split_mdas(struct cmd_context *cmd __attribute((unused)),
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
@@ -1043,8 +995,28 @@ static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev
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
@@ -1054,6 +1026,7 @@ static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  int pvmetadatacopies,
 				  uint64_t pvmetadatasize, struct dm_list *mdas)
 {
+	const struct format_type *fmt = cmd->fmt;
 	struct dm_pool *mem = fmt->cmd->mem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
 
-- 
1.6.0.6


