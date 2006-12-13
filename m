From: agk@sourceware.org <agk@sourceware.org>
Date: 13 Dec 2006 18:40:23 -0000
Subject: LVM2 ./WHATS_NEW tools/pvremove.c
Message-ID: <20061213184023.27638.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-12-13 18:40:23

Modified files:
	.              : WHATS_NEW 
	tools          : pvremove.c 

Log message:
	Add missing pvremove error message when device doesn't exist.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.520&r2=1.521
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/WHATS_NEW	2006/12/13 03:39:57	1.520
+++ LVM2/WHATS_NEW	2006/12/13 18:40:22	1.521
@@ -1,5 +1,6 @@
 Version 2.02.17 -
 ===================================
+  Add missing pvremove error message when device doesn't exist.
   When lvconvert allocates a mirror log, respect parallel area constraints.
   Use loop to iterate through the now-ordered policy list in _allocate().
   Check for failure to allocate just the mirror log.
--- LVM2/tools/pvremove.c	2006/11/17 02:45:51	1.11
+++ LVM2/tools/pvremove.c	2006/12/13 18:40:23	1.12
@@ -38,8 +38,8 @@
 	if (!(pv = pv_read(cmd, name, NULL, NULL, 1))) {
 		if (arg_count(cmd, force_ARG))
 			return 1;
-		else
-			return 0;
+		log_error("Physical Volume %s not found", name);
+		return 0;
 	}
 
 	/* orphan ? */


