From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Jul 2008 14:12:30 -0000
Subject: LVM2/tools pvcreate.c
Message-ID: <20080725141230.1851.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-25 14:12:30

Modified files:
	tools          : pvcreate.c 

Log message:
	Refactor pvcreate - use '0' for no --uuid or --restorefile options.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/tools/pvcreate.c	2008/07/25 00:30:57	1.69
+++ LVM2/tools/pvcreate.c	2008/07/25 14:12:29	1.70
@@ -23,11 +23,11 @@
 	uint64_t pvmetadatasize;
 	int64_t labelsector;
 	struct id id; /* FIXME: redundant */
-	struct id *idp;
+	struct id *idp; /* 0 if no --uuid option */
 	uint64_t pe_start;
 	uint32_t extent_count;
 	uint32_t extent_size;
-	const char *restorefile;
+	const char *restorefile; /* 0 if no --restorefile option */
 };
 
 const char _really_init[] =
@@ -37,7 +37,8 @@
  * See if we may pvcreate on this device.
  * 0 indicates we may not.
  */
-static int pvcreate_check(struct cmd_context *cmd, const char *name)
+static int pvcreate_check(struct cmd_context *cmd, const char *name,
+			  struct pvcreate_params *pp)
 {
 	struct physical_volume *pv;
 	struct device *dev;
@@ -112,8 +113,8 @@
 
 	/* Wipe superblock? */
 	if (dev_is_md(dev, &md_superblock) &&
-	    ((!arg_count(cmd, uuidstr_ARG) &&
-	      !arg_count(cmd, restorefile_ARG)) ||
+	    ((!pp->idp &&
+	      !pp->restorefile) ||
 	     arg_count(cmd, yes_ARG) ||
 	     (yes_no_prompt("Software RAID md superblock "
 			    "detected on %s. Wipe it? [y/n] ", name) == 'y'))) {
@@ -161,7 +162,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!pvcreate_check(cmd, pv_name))
+	if (!pvcreate_check(cmd, pv_name, pp))
 		goto error;
 
 	if (sigint_caught())


