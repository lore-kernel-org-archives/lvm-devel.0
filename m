From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 19:50:16 -0000
Subject: LVM2/lib/report properties.h
Message-ID: <20101117195016.30014.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 19:50:15

Modified files:
	lib/report     : properties.h 

Log message:
	Make value.string const char *, in properties.h, to fix a warning introduced by
	the previous patch set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/lib/report/properties.h	2010/11/17 19:15:11	1.6
+++ LVM2/lib/report/properties.h	2010/11/17 19:50:15	1.7
@@ -26,7 +26,7 @@
 	unsigned is_string:1;
 	unsigned is_integer:1;
 	union {
-		char *string;
+		const char *string;
 		uint64_t integer;
 	} value;
 	int (*get) (const void *obj, struct lvm_property_type *prop);


