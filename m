From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 Nov 2010 14:39:06 -0000
Subject: LVM2/lib/report properties.c
Message-ID: <20101125143906.21013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-25 14:39:04

Modified files:
	lib/report     : properties.c 

Log message:
	All 'size' values of lvm2app properties should be in bytes.
	Fix 'seg_size' to return bytes.
	
	Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
	Reviewed-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26

--- LVM2/lib/report/properties.c	2010/11/17 20:11:27	1.25
+++ LVM2/lib/report/properties.c	2010/11/25 14:39:02	1.26
@@ -230,7 +230,7 @@
 #define _seg_start_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(seg_start_pe, lvseg->le)
 #define _seg_start_pe_set _not_implemented_set
-GET_LVSEG_NUM_PROPERTY_FN(seg_size, lvseg_size(lvseg))
+GET_LVSEG_NUM_PROPERTY_FN(seg_size, (SECTOR_SIZE * lvseg_size(lvseg)))
 #define _seg_size_set _not_implemented_set
 GET_LVSEG_STR_PROPERTY_FN(seg_tags, lvseg_tags_dup(lvseg))
 #define _seg_tags_set _not_implemented_set


