From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Aug 2007 20:16:02 -0000
Subject: LVM2/tools pvresize.c
Message-ID: <20070830201602.17810.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-08-30 20:16:02

Modified files:
	tools          : pvresize.c 

Log message:
	prepare to move guts of pvresize into library

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/tools/pvresize.c	2007/08/20 20:55:30	1.13
+++ LVM2/tools/pvresize.c	2007/08/30 20:16:01	1.14
@@ -23,10 +23,10 @@
 	unsigned total;
 };
 
-static int _pvresize_single(struct cmd_context *cmd,
+static int pv_resize_single(struct cmd_context *cmd,
 			    struct volume_group *vg,
 			    struct physical_volume *pv,
-			    void *handle)
+			    uint64_t new_size)
 {
 	struct pv_list *pvl;
 	int consistent = 1;
@@ -34,25 +34,22 @@
 	uint32_t new_pe_count = 0;
 	struct list mdas;
 	const char *pv_name = dev_name(pv_dev(pv));
-	struct pvresize_params *params = (struct pvresize_params *) handle;
 	const char *vg_name;
 
 	list_init(&mdas);
 
-	params->total++;
-
 	if (!*pv_vg_name(pv)) {
 		vg_name = ORPHAN;
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 			log_error("Can't get lock for orphans");
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		if (!(pv = pv_read(cmd, pv_name, &mdas, NULL, 1))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to read PV \"%s\"", pv_name);
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		/* FIXME Create function to test compatibility properly */
@@ -60,76 +57,76 @@
 			log_error("%s: too many metadata areas for pvresize",
 				  pv_name);
 			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
+			return 0;
 		}
 	} else {
 		vg_name = pv_vg_name(pv);
 
 		if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 			log_error("Can't get lock for %s", pv_vg_name(pv));
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to find volume group of \"%s\"",
 				  pv_name);
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		if (!vg_check_status(vg, CLUSTERED | EXPORTED_VG | LVM_WRITE)) {
 			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to find \"%s\" in volume group \"%s\"",
 				  pv_name, vg->name);
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		pv = pvl->pv;
 
 		if (!archive(vg))
-			return ECMD_FAILED;
+			return 0;
 	}
 
 	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
 		log_error("Physical volume %s format does not support resizing.",
 			  pv_name);
 		unlock_vg(cmd, vg_name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	/* Get new size */
 	if (!dev_get_size(pv_dev(pv), &size)) {
 		log_error("%s: Couldn't get size.", pv_name);
 		unlock_vg(cmd, vg_name);
-		return ECMD_FAILED;
+		return 0;
 	}
 	
-	if (params->new_size) {
-		if (params->new_size > size)
+	if (new_size) {
+		if (new_size > size)
 			log_warn("WARNING: %s: Overriding real size. "
 				  "You could lose data.", pv_name);
 		log_verbose("%s: Pretending size is %" PRIu64 " not %" PRIu64
-			    " sectors.", pv_name, params->new_size, pv_size(pv));
-		size = params->new_size;
+			    " sectors.", pv_name, new_size, pv_size(pv));
+		size = new_size;
 	}
 
 	if (size < PV_MIN_SIZE) {
 		log_error("%s: Size must exceed minimum of %ld sectors.",
 			  pv_name, PV_MIN_SIZE);
 		unlock_vg(cmd, vg_name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	if (size < pv_pe_start(pv)) {
 		log_error("%s: Size must exceed physical extent start of "
 			  "%" PRIu64 " sectors.", pv_name, pv_pe_start(pv));
 		unlock_vg(cmd, vg_name);
-		return ECMD_FAILED;
+		return 0;
 	}
 
 	pv->size = size;
@@ -144,13 +141,13 @@
 				  "%" PRIu32 " sectors.", pv_name,
 				  pv_pe_size(pv));
 			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
+			return 0;
 		}
 
 		if (!pv_resize(pv, vg, new_pe_count)) {
 			stack;
 			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
+			return 0;
 		}
 	}
 
@@ -163,7 +160,7 @@
 			unlock_vg(cmd, pv_vg_name(pv));
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);
-			return ECMD_FAILED;
+			return 0;
 		}
 		backup(vg);
 		unlock_vg(cmd, vg_name);
@@ -172,16 +169,31 @@
 			unlock_vg(cmd, ORPHAN);
 			log_error("Failed to store physical volume \"%s\"",
 				  pv_name);
-			return ECMD_FAILED;
+			return 0;
 		}
 		unlock_vg(cmd, vg_name);
 	}
 
 	log_print("Physical volume \"%s\" changed", pv_name);
+	return 1;
+}
+
+
+static int _pvresize_single(struct cmd_context *cmd,
+			    struct volume_group *vg,
+			    struct physical_volume *pv,
+			    void *handle)
+{
+	struct pvresize_params *params = (struct pvresize_params *) handle;
+
+	params->total++;
 
+	if (!pv_resize_single(cmd, vg, pv, params->new_size))
+		return ECMD_FAILED;
+	
 	params->done++;
 
-	return 1;
+	return ECMD_PROCESSED;
 }
 
 int pvresize(struct cmd_context *cmd, int argc, char **argv)


