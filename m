From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 01:53:57 -0000
Subject: LVM2/lib/metadata metadata-exported.h metadata.c
Message-ID: <20090726015357.5891.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 01:53:57

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	Change pvcreate_single to return pv_t and update function description.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.263&r2=1.264

--- LVM2/lib/metadata/metadata-exported.h	2009/07/26 01:53:09	1.97
+++ LVM2/lib/metadata/metadata-exported.h	2009/07/26 01:53:57	1.98
@@ -354,7 +354,8 @@
 	unsigned yes;
 };
 
-int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle);
+pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		       void *handle);
 
 /*
 * Utility functions
--- LVM2/lib/metadata/metadata.c	2009/07/26 01:53:30	1.263
+++ LVM2/lib/metadata/metadata.c	2009/07/26 01:53:57	1.264
@@ -1107,7 +1107,19 @@
 	pp->yes = 0;
 }
 
-int pvcreate_single(struct cmd_context *cmd, const char *pv_name, void *handle)
+/*
+ * pvcreate_single() - initialize a device with PV label and metadata
+ *
+ * Parameters:
+ * - pv_name: device path to initialize
+ * - handle: options to pass to pv_create; NULL indicates use defaults
+ *
+ * Returns:
+ * NULL: error
+ * pv_t * (non-NULL): handle to physical volume created
+ */
+pv_t * pvcreate_single(struct cmd_context *cmd, const char *pv_name,
+		       void *handle)
 {
 	struct pvcreate_params *pp;
 	void *pv;
@@ -1126,13 +1138,13 @@
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
 			log_error("uuid %s already in use on \"%s\"",
 				  pp->idp->uuid, dev_name(dev));
-			return 0;
+			return NULL;
 		}
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
 		log_error("Can't get lock for orphan PVs");
-		return 0;
+		return NULL;
 	}
 
 	if (!pvcreate_check(cmd, pv_name, pp))
@@ -1192,11 +1204,11 @@
 	log_print("Physical volume \"%s\" successfully created", pv_name);
 
 	unlock_vg(cmd, VG_ORPHANS);
-	return 1;
+	return pv;
 
       error:
 	unlock_vg(cmd, VG_ORPHANS);
-	return 0;
+	return NULL;
 }
 
 static void _free_pv(struct dm_pool *mem, struct physical_volume *pv)


