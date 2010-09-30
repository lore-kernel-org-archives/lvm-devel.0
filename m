From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:07:34 -0000
Subject: LVM2/lib report/report.c uuid/uuid.c uuid/uuid.h
Message-ID: <20100930140734.16135.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:07:34

Modified files:
	lib/report     : report.c 
	lib/uuid       : uuid.c uuid.h 

Log message:
	Add id_format_and_copy() common function and call from _uuid_disp.
	
	Add supporting uuid function to allocate memory and call id_write_format.
	Call id_format_and_copy from _uuid_disp.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/uuid/uuid.h.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/lib/report/report.c	2010/09/30 13:52:57	1.128
+++ LVM2/lib/report/report.c	2010/09/30 14:07:33	1.129
@@ -677,12 +677,7 @@
 {
 	char *repstr = NULL;
 
-	if (!(repstr = dm_pool_alloc(mem, 40))) {
-		log_error("dm_pool_alloc failed");
-		return 0;
-	}
-
-	if (!id_write_format((const struct id *) data, repstr, 40))
+	if (!(repstr = id_format_and_copy(mem, (struct id *)data)))
 		return_0;
 
 	dm_report_field_set_value(field, repstr, NULL);
--- LVM2/lib/uuid/uuid.c	2009/07/15 20:02:47	1.30
+++ LVM2/lib/uuid/uuid.c	2010/09/30 14:07:33	1.31
@@ -206,3 +206,18 @@
 
 	return id_valid(id);
 }
+
+char *id_format_and_copy(struct dm_pool *mem, const struct id *id)
+{
+	char *repstr = NULL;
+
+	if (!(repstr = dm_pool_alloc(mem, 40))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (!id_write_format(id, repstr, 40))
+		return_NULL;
+
+	return repstr;
+}
--- LVM2/lib/uuid/uuid.h	2008/08/28 18:41:51	1.16
+++ LVM2/lib/uuid/uuid.h	2010/09/30 14:07:33	1.17
@@ -54,4 +54,6 @@
  */
 int id_read_format(struct id *id, const char *buffer);
 
+char *id_format_and_copy(struct dm_pool *mem, const struct id *id);
+
 #endif


