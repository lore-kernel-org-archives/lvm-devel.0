From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Jul 2008 00:30:57 -0000
Subject: LVM2 test/t-pvcreate-operation.sh tools/pvcreate.c
Message-ID: <20080725003057.5116.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-25 00:30:57

Modified files:
	test           : t-pvcreate-operation.sh 
	tools          : pvcreate.c 

Log message:
	Refactor pvcreate - move uuid and restorefile options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/test/t-pvcreate-operation.sh	2008/07/24 17:33:40	1.3
+++ LVM2/test/t-pvcreate-operation.sh	2008/07/25 00:30:57	1.4
@@ -91,8 +91,8 @@
 
 test_expect_success \
   'pvcreate rejects uuid already in use' \
-  'pvcreate --uuid freddy-fred-fred-fred-fred-fred-freddy $d1 &&
-   pvcreate --uuid freddy-fred-fred-fred-fred-fred-freddy $d2;
+  'pvcreate --uuid $uuid1 $d1 &&
+   pvcreate --uuid $uuid1 $d2;
    status=$?; echo status=$status; test $status != 0'
 
 test_expect_success \
--- LVM2/tools/pvcreate.c	2008/07/24 15:25:09	1.68
+++ LVM2/tools/pvcreate.c	2008/07/25 00:30:57	1.69
@@ -22,6 +22,12 @@
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;
 	int64_t labelsector;
+	struct id id; /* FIXME: redundant */
+	struct id *idp;
+	uint64_t pe_start;
+	uint32_t extent_count;
+	uint32_t extent_size;
+	const char *restorefile;
 };
 
 const char _really_init[] =
@@ -138,47 +144,16 @@
 {
 	struct pvcreate_params *pp = (struct pvcreate_params *) handle;
 	void *pv;
-	void *existing_pv;
-	struct id id, *idp = NULL;
-	const char *uuid = NULL;
 	struct device *dev;
 	struct list mdas;
-	struct volume_group *vg;
-	const char *restorefile;
-	uint64_t pe_start = 0;
-	uint32_t extent_count = 0, extent_size = 0;
 
-	if (arg_count(cmd, uuidstr_ARG)) {
-		uuid = arg_str_value(cmd, uuidstr_ARG, "");
-		if (!id_read_format(&id, uuid))
-			return EINVALID_CMD_LINE;
-		if ((dev = device_from_pvid(cmd, &id)) &&
+	if (pp->idp) {
+		if ((dev = device_from_pvid(cmd, pp->idp)) &&
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
-			log_error("uuid %s already in use on \"%s\"", uuid,
-				  dev_name(dev));
-			return ECMD_FAILED;
-		}
-		idp = &id;
-	}
-
-	if (arg_count(cmd, restorefile_ARG)) {
-		restorefile = arg_str_value(cmd, restorefile_ARG, "");
-		/* The uuid won't already exist */
-		init_partial(1);
-		if (!(vg = backup_read_vg(cmd, NULL, restorefile))) {
-			log_error("Unable to read volume group from %s",
-				  restorefile);
-			return ECMD_FAILED;
-		}
-		init_partial(0);
-		if (!(existing_pv = find_pv_in_vg_by_uuid(vg, idp))) {
-			log_error("Can't find uuid %s in backup file %s",
-				  uuid, restorefile);
+			log_error("uuid %s already in use on \"%s\"",
+				  pp->idp->uuid, dev_name(dev));
 			return ECMD_FAILED;
 		}
-		pe_start = pv_pe_start(existing_pv);
-		extent_size = pv_pe_size(existing_pv);
-		extent_count = pv_pe_count(existing_pv);
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
@@ -199,8 +174,9 @@
 	}
 
 	list_init(&mdas);
-	if (!(pv = pv_create(cmd, dev, idp, pp->size, pe_start,
-			     extent_count, extent_size, pp->pvmetadatacopies,
+	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size, pp->pe_start,
+			     pp->extent_count, pp->extent_size,
+			     pp->pvmetadatacopies,
 			     pp->pvmetadatasize,&mdas))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
 		goto error;
@@ -261,6 +237,12 @@
 				    int argc, char **argv,
 				    struct pvcreate_params *pp)
 {
+	const char *uuid = NULL;
+	void *existing_pv;
+	struct volume_group *vg;
+
+	memset(pp, 0, sizeof(*pp));
+
 	if (!argc) {
 		log_error("Please enter a physical volume path");
 		return 0;
@@ -276,6 +258,33 @@
 		return 0;
 	}
 
+ 	if (arg_count(cmd, uuidstr_ARG)) {
+		uuid = arg_str_value(cmd, uuidstr_ARG, "");
+		if (!id_read_format(&pp->id, uuid))
+			return 0;
+		pp->idp = &pp->id;
+	}
+
+	if (arg_count(cmd, restorefile_ARG)) {
+		pp->restorefile = arg_str_value(cmd, restorefile_ARG, "");
+		/* The uuid won't already exist */
+		init_partial(1);
+		if (!(vg = backup_read_vg(cmd, NULL, pp->restorefile))) {
+			log_error("Unable to read volume group from %s",
+				  pp->restorefile);
+			return 0;
+		}
+		init_partial(0);
+		if (!(existing_pv = find_pv_in_vg_by_uuid(vg, pp->idp))) {
+			log_error("Can't find uuid %s in backup file %s",
+				  uuid, pp->restorefile);
+			return 0;
+		}
+		pp->pe_start = pv_pe_start(existing_pv);
+		pp->extent_size = pv_pe_size(existing_pv);
+		pp->extent_count = pv_pe_count(existing_pv);
+	}
+
 	if (arg_count(cmd, yes_ARG) && !arg_count(cmd, force_ARG)) {
 		log_error("Option y can only be given with option f");
 		return 0;


