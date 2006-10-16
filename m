From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Oct 2006 16:47:56 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20061016164756.5582.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-16 16:47:56

Modified files:
	tools          : lvcreate.c 

Log message:
	revert

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.126&r2=1.127

--- LVM2/tools/lvcreate.c	2006/10/16 16:44:28	1.126
+++ LVM2/tools/lvcreate.c	2006/10/16 16:47:56	1.127
@@ -637,11 +637,11 @@
 		return 0;
 	}
 
-	////if (lp->mirrors > 1 && !activation()) {
-		//log_error("Can't create mirror without using "
-			  //"device-mapper kernel driver.");
-		//return 0;
-	//}
+	if (lp->mirrors > 1 && !activation()) {
+		log_error("Can't create mirror without using "
+			  "device-mapper kernel driver.");
+		return 0;
+	}
 
 	/* The snapshot segment gets created later */
 	if (lp->snapshot &&


