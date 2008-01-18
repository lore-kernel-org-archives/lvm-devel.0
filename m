From: agk@sourceware.org <agk@sourceware.org>
Date: 18 Jan 2008 21:56:40 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW tools/lvcreate.c
Message-ID: <20080118215640.22709.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-18 21:56:40

Modified files:
	.              : VERSION WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Fix lvcreate -M1 readahead.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.767&r2=1.768
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.168&r2=1.169

--- LVM2/VERSION	2008/01/17 15:02:59	1.161
+++ LVM2/VERSION	2008/01/18 21:56:39	1.162
@@ -1 +1 @@
-2.02.30-cvs (2008-01-17)
+2.02.31-cvs (2008-01-17)
--- LVM2/WHATS_NEW	2008/01/17 17:17:08	1.767
+++ LVM2/WHATS_NEW	2008/01/18 21:56:39	1.768
@@ -1,3 +1,7 @@
+Version 2.02.31 -
+===================================
+  Avoid error message when using default setting of lvcreate -M1. (2.02.30)
+
 Version 2.02.30 - 17th January 2008
 ===================================
   Set default readahead to twice maximium stripe size.
--- LVM2/tools/lvcreate.c	2008/01/17 15:53:01	1.168
+++ LVM2/tools/lvcreate.c	2008/01/18 21:56:39	1.169
@@ -463,16 +463,14 @@
 	/*
 	 * Read ahead.
 	 */
-	if (arg_count(cmd, readahead_ARG)) {
-		lp->read_ahead = arg_uint_value(cmd, readahead_ARG, 0);
-		pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
-		if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
-		    lp->read_ahead != DM_READ_AHEAD_NONE &&
-		    lp->read_ahead % pagesize) {
-			lp->read_ahead = (lp->read_ahead / pagesize) * pagesize;
-			log_verbose("Rounding down readahead to %u sectors, a multiple "
-				    "of page size %u.", lp->read_ahead, pagesize);
-		}
+	lp->read_ahead = arg_uint_value(cmd, readahead_ARG, DM_READ_AHEAD_NONE);
+	pagesize = lvm_getpagesize() >> SECTOR_SHIFT;
+	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
+	    lp->read_ahead != DM_READ_AHEAD_NONE &&
+	    lp->read_ahead % pagesize) {
+		lp->read_ahead = (lp->read_ahead / pagesize) * pagesize;
+		log_verbose("Rounding down readahead to %u sectors, a multiple "
+			    "of page size %u.", lp->read_ahead, pagesize);
 	}
 
 	/*
@@ -547,6 +545,7 @@
 	}
 
 	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
+	    lp->read_ahead != DM_READ_AHEAD_NONE &&
 	    (vg->fid->fmt->features & FMT_RESTRICTED_READAHEAD) &&
 	    (lp->read_ahead < 2 || lp->read_ahead > 120)) {
 		log_error("Metadata only supports readahead values between 2 and 120.");


