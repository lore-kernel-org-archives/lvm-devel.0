From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Oct 2006 16:44:28 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW tools/lvcreate.c
Message-ID: <20061016164428.1013.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-16 16:44:28

Modified files:
	.              : VERSION WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.471&r2=1.472
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/VERSION	2006/10/12 18:20:45	1.122
+++ LVM2/VERSION	2006/10/16 16:44:28	1.123
@@ -1 +1 @@
-2.02.12-cvs (2006-10-12)
+2.02.12-cvs (2006-10-16)
--- LVM2/WHATS_NEW	2006/10/16 16:29:39	1.471
+++ LVM2/WHATS_NEW	2006/10/16 16:44:28	1.472
@@ -1,4 +1,4 @@
-Version 2.02.12 -
+Version 2.02.12 - 16th October 2006
 ===================================
   Fix pvdisplay to use vg_read() for non-orphans.
   Fall back to internal locking if external locking lib is missing or fails.
--- LVM2/tools/lvcreate.c	2006/09/26 09:35:43	1.125
+++ LVM2/tools/lvcreate.c	2006/10/16 16:44:28	1.126
@@ -637,11 +637,11 @@
 		return 0;
 	}
 
-	if (lp->mirrors > 1 && !activation()) {
-		log_error("Can't create mirror without using "
-			  "device-mapper kernel driver.");
-		return 0;
-	}
+	////if (lp->mirrors > 1 && !activation()) {
+		//log_error("Can't create mirror without using "
+			  //"device-mapper kernel driver.");
+		//return 0;
+	//}
 
 	/* The snapshot segment gets created later */
 	if (lp->snapshot &&


