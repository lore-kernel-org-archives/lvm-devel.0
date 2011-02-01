From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 1 Feb 2011 17:31:40 -0000
Subject: LVM2/lib/locking cluster_locking.c
Message-ID: <20110201173140.2138.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-02-01 17:31:40

Modified files:
	lib/locking    : cluster_locking.c 

Log message:
	fix bad 'strcmp's in 'decode_lock_type' - missing !'s
	
	There was no effect from having this wrong yet, because the
	tree of callers only ever cared about the answer to the first
	condition (!response), which determines whether a lock is
	held or not.  Correct responses, however, are needed soon.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/lib/locking/cluster_locking.c	2011/01/28 10:16:04	1.50
+++ LVM2/lib/locking/cluster_locking.c	2011/02/01 17:31:40	1.51
@@ -490,11 +490,11 @@
 {
 	if (!response)
 		return LCK_NULL;
-	else if (strcmp(response, "EX"))
+	else if (!strcmp(response, "EX"))
 		return LCK_EXCL;
-	else if (strcmp(response, "CR"))
+	else if (!strcmp(response, "CR"))
 		return LCK_READ;
-	else if (strcmp(response, "PR"))
+	else if (!strcmp(response, "PR"))
 		return LCK_PREAD;
 
 	stack;
@@ -532,8 +532,8 @@
 
 		/*
 		 * All nodes should use CR, or exactly one node
-		 * should held EX. (PR is obsolete)
-		 * If two nodes node reports different locks,
+		 * should hold EX. (PR is obsolete)
+		 * If two nodes report different locks,
 		 * something is broken - just return more important mode.
 		 */
 		if (decode_lock_type(response[i].response) > *mode)


