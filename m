From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Feb 2008 13:29:09 -0000
Subject: LVM2 ./WHATS_NEW tools/lvconvert.c
Message-ID: <20080212132909.8697.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-02-12 13:29:08

Modified files:
	.              : WHATS_NEW 
	tools          : lvconvert.c 

Log message:
	Fix lvconvert detection of mirror conversion in progress.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.792&r2=1.793
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/WHATS_NEW	2008/02/12 13:26:53	1.792
+++ LVM2/WHATS_NEW	2008/02/12 13:29:08	1.793
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Fix lvconvert detection of mirror conversion in progress. (2.02.30)
   Avoid automatic lvconvert polldaemon invocation when -R specified. (2.02.30)
   Fix 'pvs -a' to detect VGs of PVs without metadata areas.
   Divide up internal orphan volume group by format type.
--- LVM2/tools/lvconvert.c	2008/02/12 13:26:53	1.60
+++ LVM2/tools/lvconvert.c	2008/02/12 13:29:08	1.61
@@ -526,6 +526,8 @@
 			log_error("Logical volume %s already has %"
 				  PRIu32 " mirror(s).", lv->name,
 				  lp->mirrors - 1);
+			if (lv->status & CONVERTING)
+				lp->need_polling = 1;
 			return 1;
 		}
 	} else if (lp->mirrors > existing_mirrors) {


