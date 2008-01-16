From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 15:25:10 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20080116152510.22467.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 15:25:10

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	reword

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.761&r2=1.762
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166

--- LVM2/WHATS_NEW	2008/01/16 15:24:25	1.761
+++ LVM2/WHATS_NEW	2008/01/16 15:25:10	1.762
@@ -1,6 +1,6 @@
 Version 2.02.30 -
 ===================================
-  Don't use block_on_error with mirror targets above version 1.12.
+  Don't use block_on_error with mirror targets version 1.12 and above.
   Update vgsplit to include vgcreate-style options when new VG is destination.
   Update vgsplit to accept existing VG as destination.
   lvconvert waits for completion of initial sync by default.
--- LVM2/tools/lvcreate.c	2007/12/22 02:13:00	1.165
+++ LVM2/tools/lvcreate.c	2008/01/16 15:25:10	1.166
@@ -705,11 +705,11 @@
 		return 0;
 	}
 
-	if (lp->mirrors > 1 && !activation()) {
-		log_error("Can't create mirror without using "
-			  "device-mapper kernel driver.");
-		return 0;
-	}
+//	if (lp->mirrors > 1 && !activation()) {
+		//log_error("Can't create mirror without using "
+			  //"device-mapper kernel driver.");
+		//return 0;
+	//}
 
 	/* The snapshot segment gets created later */
 	if (lp->snapshot &&


