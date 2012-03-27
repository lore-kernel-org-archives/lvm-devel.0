From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Mar 2012 15:53:47 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c
Message-ID: <20120327155347.10271.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-27 15:53:45

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 

Log message:
	Fix exclusive lvmchange -aey to fail if volume is active on different node.
	
	Activation on remote node should be tried only if it is masked by tags
	locally (like when hosttags enabled, IOW activate_lv_excl_local()
	doesn't return error.)
	
	Introduced change caused that lvchange -aey succeeded even if volume was
	activated exclusively remotely.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2371&r2=1.2372
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/WHATS_NEW	2012/03/27 11:04:46	1.2371
+++ LVM2/WHATS_NEW	2012/03/27 15:53:45	1.2372
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix exclusive lvchange running from other node. (2.02.89)
   Add 'vgscan --cache' functionality for consistency with 'pvscan --cache'.
   Keep exclusive activation in pvmove if LV is already active.
   Disallow pvmove for exclusive LV if some affected LVs are not exclusively activated.
--- LVM2/lib/locking/locking.c	2012/03/26 20:33:40	1.104
+++ LVM2/lib/locking/locking.c	2012/03/27 15:53:45	1.105
@@ -551,7 +551,7 @@
 	if (!vg_is_clustered(lv->vg))
 		return activate_lv_excl_local(cmd, lv);
 
-	if (lv_is_active_exclusive(lv))
+	if (lv_is_active_exclusive_locally(lv))
 		return 1;
 
 	if (!activate_lv_excl_local(cmd, lv))


