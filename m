From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Nov 2009 20:44:08 -0000
Subject: LVM2 ./WHATS_NEW lib/datastruct/list.c lib/dat ...
Message-ID: <20091125204408.6469.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-11-25 20:44:07

Modified files:
	.              : WHATS_NEW 
Removed files:
	lib/datastruct : list.c list.h 
	libdm/datastruct: list.h 

Log message:
	Remove unnecessary / duplicate dm_list macros and functions.
	
	These are no longer used by anyone.  The dm_list defines are all in
	libdevmapper.h and libdm/datastruct/list.c contains any function definitions.
	There is some code in "old-tests" that still use this but this code is not
	being maintained.
	
	Thanks to Zdenek for spotting this.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.c.diff?cvsroot=lvm2&r1=1.5&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/datastruct/list.h.diff?cvsroot=lvm2&r1=1.28&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/list.h.diff?cvsroot=lvm2&r1=1.28&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1332&r2=1.1333

--- LVM2/WHATS_NEW	2009/11/25 15:59:07	1.1332
+++ LVM2/WHATS_NEW	2009/11/25 20:44:07	1.1333
@@ -1,5 +1,6 @@
 Version 2.02.57 -
 ====================================
+  Remove duplicate dm_list macros and functions.
   Log failure type and recognise type 'F' (flush) in dmeventd mirror plugin.
   Extend internal PV/VG/LV/segment status variables from 32-bit to 64-bit.
 


