From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Jun 2009 22:06:54 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20090606220654.3307.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-06 22:06:54

Modified files:
	tools          : lvcreate.c 

Log message:
	Fix the same readahead rounding in lvcreate.
	
	(fixes previous commit)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.192&r2=1.193

--- LVM2/tools/lvcreate.c	2009/05/27 18:19:21	1.192
+++ LVM2/tools/lvcreate.c	2009/06/06 22:06:54	1.193
@@ -477,9 +477,12 @@
 	if (lp->read_ahead != DM_READ_AHEAD_AUTO &&
 	    lp->read_ahead != DM_READ_AHEAD_NONE &&
 	    lp->read_ahead % pagesize) {
-		lp->read_ahead = (lp->read_ahead / pagesize) * pagesize;
-		log_verbose("Rounding down readahead to %u sectors, a multiple "
-			    "of page size %u.", lp->read_ahead, pagesize);
+		if (lp->read_ahead < pagesize)
+			lp->read_ahead = pagesize;
+		else
+			lp->read_ahead = (lp->read_ahead / pagesize) * pagesize;
+		log_warn("WARNING: Overriding readahead to %u sectors, a multiple "
+			    "of %uK page size.", lp->read_ahead, pagesize >> 1);
 	}
 
 	/*


