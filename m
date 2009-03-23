From: taka@sourceware.org <taka@sourceware.org>
Date: 23 Mar 2009 22:29:07 -0000
Subject: LVM2 ./WHATS_NEW tools/vgrename.c
Message-ID: <20090323222907.10430.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	taka at sourceware.org	2009-03-23 22:29:07

Modified files:
	.              : WHATS_NEW 
	tools          : vgrename.c 

Log message:
	Remove old metadata backup file after renaming vg.
	
	Author: Takahiro Yasui <tyasui@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1069&r2=1.1070
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.58&r2=1.59

--- LVM2/WHATS_NEW	2009/03/23 21:56:32	1.1069
+++ LVM2/WHATS_NEW	2009/03/23 22:29:06	1.1070
@@ -9,6 +9,7 @@
   Fix unlocks in clvmd-corosync. Broken in 2.02.45.
   Fix error message when adding metadata directory to internal list fails.
   Fix size and error message of memory allocation at backup initialization.
+  Remove old metadata backup file after renaming vg.
 
 Version 2.02.45 - 3rd March 2009
 ================================
--- LVM2/tools/vgrename.c	2009/01/26 19:01:32	1.58
+++ LVM2/tools/vgrename.c	2009/03/23 22:29:06	1.59
@@ -149,6 +149,7 @@
 /******* FIXME Rename any active LVs! *****/
 
 	backup(vg);
+	backup_remove(cmd, vg_name_old);
 
 	unlock_vg(cmd, vg_name_new);
 	unlock_vg(cmd, vg_name_old);


