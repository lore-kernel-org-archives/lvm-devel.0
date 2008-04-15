From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Apr 2008 11:36:47 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c ...
Message-ID: <20080415113647.3794.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-15 11:36:46

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 
	lib/locking    : cluster_locking.c 

Log message:
	rename P_global to P_#global

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.849&r2=1.850
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2008/04/14 19:49:12	1.849
+++ LVM2/WHATS_NEW	2008/04/15 11:36:46	1.850
@@ -1,5 +1,6 @@
 Version 2.02.35 - 
 =================================
+  Rename P_global to P_#global.
   Don't attempt remote metadata backups of non-clustered VGs. (2.02.29)
   Don't store fid in VG metadata cache to avoid clvmd segfault. (2.02.34)
   Update vgsplit tests to verify loosening of active LV restriction.
--- LVM2/daemons/clvmd/clvmd-command.c	2007/12/04 15:39:26	1.19
+++ LVM2/daemons/clvmd/clvmd-command.c	2008/04/15 11:36:46	1.20
@@ -118,8 +118,8 @@
 		lockname = &args[2];
 		/* Check to see if the VG is in use by LVM1 */
 		status = do_check_lvm1(lockname);
-		/* P_global causes a cache refresh */
-		if (strcmp(lockname, "P_global") == 0)
+		/* P_#global causes a cache refresh */
+		if (strcmp(lockname, "P_#global") == 0)
 		      do_refresh_cache();
 
 		break;
--- LVM2/lib/locking/cluster_locking.c	2008/04/14 19:49:12	1.26
+++ LVM2/lib/locking/cluster_locking.c	2008/04/15 11:36:46	1.27
@@ -390,7 +390,7 @@
 		if (!*resource)	/* FIXME Deprecated */
 			dm_snprintf(lockname, sizeof(lockname), "P_orphans");
 		else if (*resource == '#')
-			dm_snprintf(lockname, sizeof(lockname), "P_%s", resource + 1);
+			dm_snprintf(lockname, sizeof(lockname), "P_%s", resource);
 		else
 			dm_snprintf(lockname, sizeof(lockname), "V_%s",
 				     resource);


