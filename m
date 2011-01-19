From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 19 Jan 2011 19:24:07 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20110119192407.7010.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-01-19 19:24:07

Modified files:
	tools          : lvconvert.c 

Log message:
	Remove duplicate statement (pasted twice by patch at some point?)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.155&r2=1.156

--- LVM2/tools/lvconvert.c	2011/01/11 17:05:10	1.155
+++ LVM2/tools/lvconvert.c	2011/01/19 19:24:07	1.156
@@ -1081,16 +1081,6 @@
 		}
 
 		/*
-		 * Is there already a convert in progress?  We do not
-		 * currently allow more than one.
-		 */
-		if (find_temporary_mirror(lv) || (lv->status & CONVERTING)) {
-			log_error("%s is already being converted.  Unable to start another conversion.",
-				  lv->name);
-			return 0;
-		}
-
-		/*
 		 * Log addition/removal should be done before the layer
 		 * insertion to make the end result consistent with
 		 * linear-to-mirror conversion.


