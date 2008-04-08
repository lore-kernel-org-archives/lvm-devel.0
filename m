From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Apr 2008 21:47:54 -0000
Subject: LVM2 ./WHATS_NEW tools/vgsplit.c
Message-ID: <20080408214754.17456.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-08 21:47:54

Modified files:
	.              : WHATS_NEW 
	tools          : vgsplit.c 

Log message:
	Fix vgsplit error display - fully remove log_suppress.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.833&r2=1.834
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/WHATS_NEW	2008/04/08 21:38:08	1.833
+++ LVM2/WHATS_NEW	2008/04/08 21:47:54	1.834
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix vgsplit error display - fully remove log_suppress.
   Fix vgsplit error paths to release vg_to lock.
   Indicate whether or not VG is clustered in vgcreate log message.
   Mention default --clustered setting in vgcreate man page.
--- LVM2/tools/vgsplit.c	2008/04/08 21:38:09	1.55
+++ LVM2/tools/vgsplit.c	2008/04/08 21:47:54	1.56
@@ -220,7 +220,6 @@
 	int opt;
 	int active;
 	int existing_vg;
-	int old_suppress;
 	struct pv_list *pvl;
 	int consistent;
 
@@ -272,7 +271,6 @@
 		if (!vgs_are_compatible(cmd, vg_from,vg_to))
 			goto error;
 	} else {
-		log_suppress(old_suppress);
 		existing_vg = 0;
 
 		/* Set metadata format of original VG */


