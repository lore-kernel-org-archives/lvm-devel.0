From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Jan 2011 21:21:56 -0000
Subject: LVM2/test/api percent.c
Message-ID: <20110126212156.25214.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-26 21:21:56

Modified files:
	test/api       : percent.c 

Log message:
	Add missing lvm_quit in test
	
	Fix occasional confusing memory leak report in testing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/api/percent.c	2011/01/03 15:07:39	1.4
+++ LVM2/test/api/percent.c	2011/01/26 21:21:56	1.5
@@ -37,7 +37,7 @@
         assert(v.is_valid);
         assert(v.value.integer == PERCENT_0);
 
-        lv = lvm_lv_from_name(vg, "mirr");
+	lv = lvm_lv_from_name(vg, "mirr");
         assert(lv);
 
         v = lvm_lv_get_property(lv, "copy_percent");
@@ -52,5 +52,7 @@
         assert(v.value.integer == 50 * PERCENT_1);
 
         lvm_vg_close(vg);
+
+	lvm_quit(handle);
         return 0;
 }


