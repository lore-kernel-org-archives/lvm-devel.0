From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Sep 2010 19:38:03 -0000
Subject: LVM2/lib/report properties.c
Message-ID: <20100909193803.781.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-09 19:38:03

Modified files:
	lib/report     : properties.c 

Log message:
	Update vg_mda_free 'get' function to multiply by SECTOR_SIZE.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/lib/report/properties.c	2010/08/20 13:02:39	1.3
+++ LVM2/lib/report/properties.c	2010/09/09 19:38:03	1.4
@@ -152,7 +152,7 @@
 #define _vg_mda_count_set _not_implemented
 GET_NUM_PROPERTY_FN(vg_mda_used_count, (vg_mda_used_count(vg)))
 #define _vg_mda_used_count_set _not_implemented
-GET_NUM_PROPERTY_FN(vg_mda_free, (vg_mda_free(vg)))
+GET_NUM_PROPERTY_FN(vg_mda_free, (SECTOR_SIZE * vg_mda_free(vg)))
 #define _vg_mda_free_set _not_implemented
 GET_NUM_PROPERTY_FN(vg_mda_size, (SECTOR_SIZE * vg_mda_size(vg)))
 #define _vg_mda_size_set _not_implemented


