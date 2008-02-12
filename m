From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2008 13:26:54 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20080212132654.7992.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-02-12 13:26:53

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Avoid automatic lvconvert polldaemon invocation when -R specified.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.791&r2=1.792
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60

--- LVM2/WHATS_NEW	2008/02/06 16:09:51	1.791
+++ LVM2/WHATS_NEW	2008/02/12 13:26:53	1.792
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Avoid automatic lvconvert polldaemon invocation when -R specified. (2.02.30)
   Fix 'pvs -a' to detect VGs of PVs without metadata areas.
   Divide up internal orphan volume group by format type.
   Update usage message for clvmd.
--- LVM2/tools/lvconvert.c	2008/01/30 14:00:01	1.59
+++ LVM2/tools/lvconvert.c	2008/02/12 13:26:53	1.60
@@ -389,7 +389,7 @@
 
 	/* If called with no argument, try collapsing the resync layers */
 	if (!arg_count(cmd, mirrors_ARG) && !arg_count(cmd, mirrorlog_ARG) &&
-	    !arg_count(cmd, corelog_ARG)) {
+	    !arg_count(cmd, corelog_ARG) && !arg_count(cmd, regionsize_ARG)) {
 		lp->need_polling = 1;
 		return 1;
 	}


