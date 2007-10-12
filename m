From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2007 18:37:20 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20071012183720.31244.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-10-12 18:37:19

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Add _alloc_pv() and _free_pv() from _pv_create() code and fix error paths.
	
	Modified original patch by Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.720&r2=1.721
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139

--- LVM2/WHATS_NEW	2007/10/12 14:29:31	1.720
+++ LVM2/WHATS_NEW	2007/10/12 18:37:19	1.721
@@ -1,8 +1,9 @@
 Version 2.02.29 -
 ==================================
+  Add _alloc_pv() and _free_pv() from _pv_create() code and fix error paths.
   Add pv_dev_name() to access PV device name.
   Add const attributes to pv accessor functions.
-  Refactor vg_add_snapshot and lv_create_empty.
+  Refactor vg_add_snapshot() and lv_create_empty().
   Handle new sysfs subsystem/block/devices directory structure.
   Tests are run with LVM_SYSTEM_DIR pointing to private root and /dev dirs.
   Fix a bug in lvm_dump.sh checks for lvm/dmsetup binaries.
--- LVM2/lib/metadata/metadata.c	2007/10/12 14:29:32	1.138
+++ LVM2/lib/metadata/metadata.c	2007/10/12 18:37:19	1.139
@@ -708,6 +708,45 @@
 			  pvmetadatasize, mdas);
 }
 
+static void _free_pv(struct dm_pool *mem, struct physical_volume *pv)
+{
+	/*
+	 * FIXME: leak pv->vg_name
+	 * Adding dm_pool_free(mem, pv->vg_name) - causes warning w/'const'
+	 * Perhaps pv->vg_name should be initialized to ORPHAN, not alloc'd
+	 * memory?
+	 */
+	dm_pool_free(mem, pv);
+}
+
+static struct physical_volume *_alloc_pv(struct dm_pool *mem)
+{
+	struct physical_volume *pv = dm_pool_zalloc(mem, sizeof(*pv));
+
+	if (!pv) {
+		stack;
+		return NULL;
+	}
+
+	if (!(pv->vg_name = dm_pool_zalloc(mem, NAME_LEN))) {
+		dm_pool_free(mem, pv);
+		return NULL;
+	}
+
+	pv->pe_size = 0;
+	pv->pe_start = 0;
+	pv->pe_count = 0;
+	pv->pe_alloc_count = 0;
+	pv->fmt = NULL;
+
+	pv->status = ALLOCATABLE_PV;
+
+	list_init(&pv->tags);
+	list_init(&pv->segments);
+
+	return pv;
+}
+
 /* Sizes in sectors */
 static struct physical_volume *_pv_create(const struct format_type *fmt,
 				  struct device *dev,
@@ -719,28 +758,21 @@
 				  uint64_t pvmetadatasize, struct list *mdas)
 {
 	struct dm_pool *mem = fmt->cmd->mem;
-	struct physical_volume *pv = dm_pool_zalloc(mem, sizeof(*pv));
+	struct physical_volume *pv = _alloc_pv(mem);
 
-	if (!pv) {
-		stack;
+	if (!pv)
 		return NULL;
-	}
 
 	if (id)
 		memcpy(&pv->id, id, sizeof(*id));
 	else if (!id_create(&pv->id)) {
 		log_error("Failed to create random uuid for %s.",
 			  dev_name(dev));
-		return NULL;
+		goto bad;
 	}
 
 	pv->dev = dev;
 
-	if (!(pv->vg_name = dm_pool_zalloc(mem, NAME_LEN)))
-		goto_bad;
-
-	pv->status = ALLOCATABLE_PV;
-
 	if (!dev_get_size(pv->dev, &pv->size)) {
 		log_error("%s: Couldn't get size.", pv_dev_name(pv));
 		goto bad;
@@ -761,15 +793,8 @@
 		goto bad;
 	}
 
-	pv->pe_size = 0;
-	pv->pe_start = 0;
-	pv->pe_count = 0;
-	pv->pe_alloc_count = 0;
 	pv->fmt = fmt;
 
-	list_init(&pv->tags);
-	list_init(&pv->segments);
-
 	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
 				existing_extent_size,
 				pvmetadatacopies, pvmetadatasize, mdas,
@@ -781,7 +806,7 @@
 	return pv;
 
       bad:
-	dm_pool_free(mem, pv);
+	_free_pv(mem, pv);
 	return NULL;
 }
 


