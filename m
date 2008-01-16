From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 15:26:41 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20080116152641.24233.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 15:26:40

Modified files:
	tools          : lvcreate.c 

Log message:
	revert temp change

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.166&r2=1.167

--- LVM2/tools/lvcreate.c	2008/01/16 15:25:10	1.166
+++ LVM2/tools/lvcreate.c	2008/01/16 15:26:40	1.167
@@ -705,11 +705,11 @@
 		return 0;
 	}
 
-//	if (lp->mirrors > 1 && !activation()) {
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


