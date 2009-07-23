From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2009 23:36:20 -0000
Subject: LVM2/liblvm lvm.h
Message-ID: <20090723233620.19664.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-23 23:36:20

Modified files:
	liblvm         : lvm.h 

Log message:
	Remove lvseg_t and pvseg_t typedefs from liblvm/lvm.h.
	
	We do not need lvseg and pvseg for now.  If we need we will add back
	later.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/liblvm/lvm.h	2009/07/23 01:20:22	1.6
+++ LVM2/liblvm/lvm.h	2009/07/23 23:36:20	1.7
@@ -22,15 +22,11 @@
 struct volume_group;
 struct physical_volume;
 struct logical_volume;
-struct lv_segment;
-struct pv_segment;
 
 /* liblvm handles to objects pv, vg, lv, pvseg, lvseg */
 typedef struct volume_group vg_t;
 typedef struct physical_volume pv_t;
 typedef struct logical_volume lv_t;
-typedef struct pv_segment pvseg_t;
-typedef struct lv_segment lvseg_t;
 
 struct lvm; /* internal data */
 


