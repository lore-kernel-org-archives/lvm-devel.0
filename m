From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 10 Jun 2008 15:25:38 -0000
Subject: LVM2 ./WHATS_NEW tools/toollib.c
Message-ID: <20080610152538.31322.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-10 15:25:38

Modified files:
	.              : WHATS_NEW 
	tools          : toollib.c 

Log message:
	Add ommitted unlock_vg() call when sigint_caught() during vg processing.
	
	Specific test case:
	1. pvcreate /dev/loop1; vgcreate vg1 /dev/loop1; lvcreate -L 64M -n lv1 vg1
	2. vgremove vg1 (will prompt user)
	3. CTRL-C
	Code will exit with:
	Do you really want to remove volume group "vg2" containing 2 logical volumes? [y/n]:
	Volume group "vg2" not removed
	Command failed with status code 5.
	Internal error: Volume Group vg2 was not unlocked
	Device '/dev/loop1' has been left open.
	
	After change:
	Do you really want to remove volume group "vg2" containing 2 logical volumes? [y/n]:
	Volume group "vg2" not removed
	Command failed with status code 5.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.894&r2=1.895
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134

--- LVM2/WHATS_NEW	2008/06/10 14:55:14	1.894
+++ LVM2/WHATS_NEW	2008/06/10 15:25:37	1.895
@@ -1,5 +1,6 @@
 Version 2.02.38 - 
 =================================
+  Add omitted unlock_vg() call when sigint_caught() during vg processing.
   Fix wrong free_count on imported vg from pool device
   Fix segfault when calling pvcreate on the pool device
   Fix segfault after _free_vginfo by remembering to remove vginfo from list.
--- LVM2/tools/toollib.c	2008/04/10 19:59:43	1.133
+++ LVM2/tools/toollib.c	2008/06/10 15:25:38	1.134
@@ -514,9 +514,6 @@
 		ret_max = ret;
 	}
 
-	if (sigint_caught())
-		return ret_max;
-
 	unlock_vg(cmd, vg_name);
 
 	return ret_max;


