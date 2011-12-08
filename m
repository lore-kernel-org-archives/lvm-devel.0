From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Dec 2011 18:19:06 -0000
Subject: LVM2/lib/locking cluster_locking.c
Message-ID: <20111208181906.8968.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-12-08 18:19:05

Modified files:
	lib/locking    : cluster_locking.c 

Log message:
	Don't pass LCK_LOCAL to clvmd - it's unused.
	Pass LCK_CLUSTER_VG in args[0] instead of args[1].

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.62&r2=1.63

--- LVM2/lib/locking/cluster_locking.c	2011/11/30 17:02:37	1.62
+++ LVM2/lib/locking/cluster_locking.c	2011/12/08 18:19:05	1.63
@@ -320,9 +320,10 @@
 	args = alloca(len);
 	strcpy(args + 2, name);
 
-	/* Mask off lock flags */
-	args[0] = flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK | LCK_NONBLOCK | LCK_HOLD); 
-	args[1] = flags & (LCK_LOCAL | LCK_CLUSTER_VG);
+	/* args[0] holds bottom 8 bits except LCK_LOCAL (0x40). */
+	args[0] = flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK | LCK_NONBLOCK | LCK_HOLD | LCK_CLUSTER_VG); 
+
+	args[1] = 0;
 
 	if (flags & LCK_ORIGIN_ONLY)
 		args[1] |= LCK_ORIGIN_ONLY_MODE;
@@ -492,7 +493,7 @@
 		return 0;
 	}
 
-	log_very_verbose("Locking %s %s %s (%s%s%s%s%s%s%s) (0x%x)", lock_scope, lockname,
+	log_very_verbose("Locking %s %s %s (%s%s%s%s%s%s%s%s) (0x%x)", lock_scope, lockname,
 			 lock_type, lock_scope,
 			 flags & LCK_NONBLOCK ? "|NONBLOCK" : "",
 			 flags & LCK_HOLD ? "|HOLD" : "",
@@ -500,6 +501,7 @@
 			 flags & LCK_CLUSTER_VG ? "|CLUSTER" : "",
 			 flags & LCK_CACHE ? "|CACHE" : "",
 			 flags & LCK_ORIGIN_ONLY ? "|ORIGIN_ONLY" : "",
+			 flags & LCK_REVERT ? "|REVERT" : "",
 			 flags);
 
 	/* Send a message to the cluster manager */


