From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:45:09 -0000
Subject: LVM2 ./WHATS_NEW lib/report/properties.c lib/r ...
Message-ID: <20120227114509.30986.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:45:07

Modified files:
	.              : WHATS_NEW 
	lib/report     : properties.c properties.h 

Log message:
	Use unsigned type for bitmask
	
	Using report_type_t for bitmask is not correct, since we have not defined types
	for all  bit combinations - so switching to unsigned type, since values of
	report_type_t enum are unsigned.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2317&r2=1.2318
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2012/02/27 11:26:25	1.2317
+++ LVM2/WHATS_NEW	2012/02/27 11:45:05	1.2318
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Use unsigned type for bitmask instead of enum type for lvm properties.
   Add missing cleanup of excl_uuid hash on some exit paths of clvmd.
   Check for existance of vg_name in _format1/_pool_vg_read().
   Fix missing break in _format_pvsegs (2.02.92).
--- LVM2/lib/report/properties.c	2012/01/19 15:34:33	1.33
+++ LVM2/lib/report/properties.c	2012/02/27 11:45:06	1.34
@@ -315,7 +315,7 @@
 
 
 static int _get_property(const void *obj, struct lvm_property_type *prop,
-			 report_type_t type)
+			 unsigned type)
 {
 	struct lvm_property_type *p;
 
@@ -343,7 +343,7 @@
 }
 
 static int _set_property(void *obj, struct lvm_property_type *prop,
-			 report_type_t type)
+			 unsigned type)
 {
 	struct lvm_property_type *p;
 
--- LVM2/lib/report/properties.h	2010/11/17 20:11:28	1.9
+++ LVM2/lib/report/properties.h	2012/02/27 11:45:06	1.10
@@ -20,7 +20,7 @@
 #include "report.h"
 
 struct lvm_property_type {
-	report_type_t type;
+	unsigned type;
 	const char *id;
 	unsigned is_settable:1;
 	unsigned is_string:1;


