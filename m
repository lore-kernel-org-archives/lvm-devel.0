From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 00:20:39 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20080919002039.9899.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 00:20:39

Modified files:
	lib/metadata   : mirror.c 

Log message:
	fix last patch return code

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/lib/metadata/mirror.c	2008/09/18 19:56:50	1.75
+++ LVM2/lib/metadata/mirror.c	2008/09/19 00:20:39	1.76
@@ -179,7 +179,7 @@
 	/* Place this one at the end */
 	mirrored_seg->areas[i-1] = area;
 
-	return 0;
+	return 1;
 }
 
 /*


