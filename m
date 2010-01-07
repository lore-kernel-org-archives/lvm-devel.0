From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jan 2010 14:30:48 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-report.c
Message-ID: <20100107143048.23697.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-07 14:30:47

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-report.c 

Log message:
	Show all fields for 'dmsetup info -c -o all'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.323&r2=1.324
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/WHATS_NEW_DM	2010/01/05 21:32:59	1.323
+++ LVM2/WHATS_NEW_DM	2010/01/07 14:30:47	1.324
@@ -1,5 +1,6 @@
 Version 1.02.41 -
 ====================================
+  Update code to show all fields for 'dmsetup info -c -o all'.
   Return error from dm_tree_deactivate_children().
   Return error from dm_tree_suspend_children().
   Return error from dm_tree_preload_children() and dm_tree_activate_children().
--- LVM2/libdm/libdm-report.c	2009/02/09 09:45:49	1.30
+++ LVM2/libdm/libdm-report.c	2010/01/07 14:30:47	1.31
@@ -26,6 +26,8 @@
 struct dm_report {
 	struct dm_pool *mem;
 
+	/* To report all available types */
+#define REPORT_TYPES_ALL	UINT32_MAX
 	uint32_t report_types;
 	const char *output_field_name_prefix;
 	const char *field_prefix;
@@ -379,7 +381,8 @@
 			       _all_match(rh, prefixed_all,
 					  strlen(prefixed_all));
 		} else
-			return rh->report_types;
+			return (rh->report_types)
+				? rh->report_types : REPORT_TYPES_ALL;
 	}
 
 	for (t = rh->types; t->data_fn; t++) {


