From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Sep 2011 21:13:34 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/mirror.c
Message-ID: <20110913211334.9661.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-13 21:13:33

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : mirror.c 

Log message:
	Fix bug 733400 - Mirror down conversion when specifying the secondary leg is broke
	
	The operation of deactivating the residual error target LV after removing a
	mirror layer can cause a "device in-use" conflict with udev.  Giving udev a
	poke before calling deactivate_lv eliminates the conflict.  The stick used
	to poke udev is 'sync_local_dev_names'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2105&r2=1.2106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166

--- LVM2/WHATS_NEW	2011/09/13 18:42:57	1.2105
+++ LVM2/WHATS_NEW	2011/09/13 21:13:33	1.2106
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix failure to down-convert a mirror to linear due to udev "dev open" conflict
   Fix mirrored log creation when PE size is small - force log_size >= region_size
   Fix improper RAID 64-bit status flag reset when and'ing against 32-bit flag.
   Fix log size calculation when only a log is being added to a mirror.
--- LVM2/lib/metadata/mirror.c	2011/09/13 18:11:38	1.165
+++ LVM2/lib/metadata/mirror.c	2011/09/13 21:13:33	1.166
@@ -419,6 +419,7 @@
 			return_0;
 	}
 
+	sync_local_dev_names(lv->vg->cmd);
 	if (!deactivate_lv(cmd, lv))
 		return_0;
 


