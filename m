From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 18 Feb 2011 14:38:51 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20110218143851.31318.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-18 14:38:48

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-report.c 

Log message:
	API change - support more const arg
	
	As dm_report_field_string() doesn't modify content of data pointer,
	it can be marked as const.
	
	It's slight API change - but doesn't require any change on the user side
	and supports wider range of arguments without const casting.
	(i.e. we may use as paramater const lv struct this way:  &lv->name)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.446&r2=1.447
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.135&r2=1.136
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW_DM	2011/02/09 12:11:21	1.446
+++ LVM2/WHATS_NEW_DM	2011/02/18 14:38:47	1.447
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Change dm_report_field_string() API to accept const char *const *data.
 
 Version 1.02.63 - 9th February 2011
 ===================================
--- LVM2/libdm/libdevmapper.h	2011/02/04 19:33:53	1.135
+++ LVM2/libdm/libdevmapper.h	2011/02/18 14:38:48	1.136
@@ -1123,7 +1123,7 @@
  * They take care of allocating copies of the data.
  */
 int dm_report_field_string(struct dm_report *rh, struct dm_report_field *field,
-			   const char **data);
+			   const char *const *data);
 int dm_report_field_int32(struct dm_report *rh, struct dm_report_field *field,
 			  const int32_t *data);
 int dm_report_field_uint32(struct dm_report *rh, struct dm_report_field *field,
--- LVM2/libdm/libdm-report.c	2011/01/25 21:51:31	1.41
+++ LVM2/libdm/libdm-report.c	2011/02/18 14:38:48	1.42
@@ -102,7 +102,7 @@
  */
 
 int dm_report_field_string(struct dm_report *rh,
-			   struct dm_report_field *field, const char **data)
+			   struct dm_report_field *field, const char *const *data)
 {
 	char *repstr;
 


