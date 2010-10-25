From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Oct 2010 14:08:33 -0000
Subject: LVM2/lib/report properties.c properties.h
Message-ID: <20101025140833.20168.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-10-25 14:08:32

Modified files:
	lib/report     : properties.c properties.h 

Log message:
	Add 'is_integer' flag into internal lvm_property_type.
	
	Add 'is_integer' flag similar to 'is_string'.
	Suggested in review by Petr Rockai.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/lib/report/properties.c	2010/10/21 18:51:16	1.21
+++ LVM2/lib/report/properties.c	2010/10/25 14:08:32	1.22
@@ -227,11 +227,11 @@
 #define STR DM_REPORT_FIELD_TYPE_STRING
 #define NUM DM_REPORT_FIELD_TYPE_NUMBER
 #define FIELD(type, strct, sorttype, head, field, width, fn, id, desc, settable) \
-	{ type, #id, settable, sorttype == STR, { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
+	{ type, #id, settable, sorttype == STR, sorttype == NUM, { .integer = 0 }, _ ## id ## _get, _ ## id ## _set },
 
 struct lvm_property_type _properties[] = {
 #include "columns.h"
-	{ 0, "", 0, 0, { .integer = 0 }, _not_implemented_get, _not_implemented_set },
+	{ 0, "", 0, 0, 0, { .integer = 0 }, _not_implemented_get, _not_implemented_set },
 };
 
 #undef STR
--- LVM2/lib/report/properties.h	2010/10/21 18:51:17	1.4
+++ LVM2/lib/report/properties.h	2010/10/25 14:08:32	1.5
@@ -24,6 +24,7 @@
 	const char *id;
 	unsigned is_settable:1;
 	unsigned is_string:1;
+	unsigned is_integer:1;
 	union {
 		char *string;
 		uint64_t integer;


