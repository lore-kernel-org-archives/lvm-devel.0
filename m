From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Feb 2010 22:50:56 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100205225056.13525.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-05 22:50:56

Modified files:
	.              : WHATS_NEW 

Log message:
	Add multiple snapshot lv 'lvconvert --merge @tag' support via process_each_lv().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1421&r2=1.1422

--- LVM2/WHATS_NEW	2010/02/05 21:49:16	1.1421
+++ LVM2/WHATS_NEW	2010/02/05 22:50:56	1.1422
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Add multiple snapshot lv 'lvconvert --merge @tag' support via process_each_lv().
   Fix inappropriate second resync when adding mimage to core-logged mirror.
   Exclude internal VG names and uuids in lists returned via liblvm interface.
   Add %ORIGIN support to lv{create,extend,reduce,resize} --extents option.


