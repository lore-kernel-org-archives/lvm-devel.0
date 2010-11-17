From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 17 Nov 2010 22:26:43 -0000
Subject: LVM2/tools reporter.c
Message-ID: <20101117222643.16641.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-11-17 22:26:43

Modified files:
	tools          : reporter.c 

Log message:
	The _free_vg that is created as a placeholder when reporting segments in pvs
	was lacking the (vgmem) pool. We now create that pool. There is at least one
	more such VG (_dummy_vg) which is pool-less. I am not sure what is the right
	way to go about this, but this is currently necessary to fix a segfault
	introduced by using vgmem in the reporter in Dave's lvseg lvm2app patches.
	
	Signed-off-by: Petr Rockai <prockai@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/reporter.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/tools/reporter.c	2010/07/09 15:34:48	1.62
+++ LVM2/tools/reporter.c	2010/11/17 22:26:42	1.63
@@ -64,6 +64,9 @@
 		.name = (char *)"",
 	};
 
+        if (!(_free_vg.vgmem = dm_pool_create("_free_vg", 10240)))
+            return ECMD_FAILED;
+
 	struct logical_volume _free_logical_volume = {
 		.vg = vg ?: &_free_vg,
 		.name = (char *) "",
@@ -103,10 +106,11 @@
 
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
 			   seg ? : &_free_lv_segment, pvseg)) {
-		stack;
 		ret = ECMD_FAILED;
+                goto_out;
 	}
-
+ out:
+        dm_pool_destroy(_free_vg.vgmem);
 	return ret;
 }
 


