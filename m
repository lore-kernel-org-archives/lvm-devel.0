From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2008 19:29:59 -0000
Subject: LVM2/tools pvcreate.c
Message-ID: <20080723192959.8157.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-23 19:29:59

Modified files:
	tools          : pvcreate.c 

Log message:
	Refactor pvcreate - move labelsector parameter parsing & validation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/tools/pvcreate.c	2008/07/21 19:27:22	1.65
+++ LVM2/tools/pvcreate.c	2008/07/23 19:29:58	1.66
@@ -21,6 +21,7 @@
 	uint64_t size;
 	int pvmetadatacopies;
 	uint64_t pvmetadatasize;
+	int64_t labelsector;
 };
 
 const char _really_init[] =
@@ -237,8 +238,7 @@
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
 	if (!(pv_write(cmd, (struct physical_volume *)pv, &mdas,
-		       arg_int64_value(cmd, labelsector_ARG,
-						       DEFAULT_LABELSECTOR)))) {
+		       pp->labelsector))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
 		goto error;
 	}
@@ -290,6 +290,9 @@
 		log_error("labelsector must be less than %lu",
 			  LABEL_SCAN_SECTORS);
 		return 0;
+	} else {
+		pp->labelsector = arg_int64_value(cmd, labelsector_ARG,
+						  DEFAULT_LABELSECTOR);
 	}
 
 	if (!(cmd->fmt->features & FMT_MDAS) &&


