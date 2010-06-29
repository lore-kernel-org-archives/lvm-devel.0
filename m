From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 29 Jun 2010 15:04:00 -0000
Subject: LVM2/lib/format_text archiver.c
Message-ID: <20100629150400.658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-29 15:03:59

Modified files:
	lib/format_text: archiver.c 

Log message:
	Add error message if backup_to_file fails because of empty in_use mdas list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/format_text/archiver.c	2010/06/28 20:32:46	1.31
+++ LVM2/lib/format_text/archiver.c	2010/06/29 15:03:59	1.32
@@ -396,6 +396,11 @@
 		return 0;
 	}
 
+	if (!dm_list_size(&tf->metadata_areas_in_use)) {
+		log_error(INTERNAL_ERROR "No in use metadata areas to write.");
+		return 0;
+	}
+
 	/* Write and commit the metadata area */
 	dm_list_iterate_items(mda, &tf->metadata_areas_in_use) {
 		if (!(r = mda->ops->vg_write(tf, vg, mda))) {


