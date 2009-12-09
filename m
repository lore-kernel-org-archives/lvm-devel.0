From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 18:28:27 -0000
Subject: LVM2/lib/locking cluster_locking.c
Message-ID: <20091209182827.31047.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 18:28:27

Modified files:
	lib/locking    : cluster_locking.c 

Log message:
	Get rid of magic masks in cluster locking code.
	
	Patch should not cause any problems, only real change is
	removing LCK_LOCAL bit from lock type flag, it is never used there.
	(LCK_LOCAL is part arg[1] bits anyway.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/lib/locking/cluster_locking.c	2009/12/09 18:16:38	1.37
+++ LVM2/lib/locking/cluster_locking.c	2009/12/09 18:28:27	1.38
@@ -317,8 +317,9 @@
 	args = alloca(len);
 	strcpy(args + 2, name);
 
-	args[0] = flags & 0x7F; /* Maskoff lock flags */
-	args[1] = flags & 0xC0; /* Bitmap flags */
+	/* Maskoff lock flags */
+	args[0] = flags & (LCK_SCOPE_MASK | LCK_TYPE_MASK | LCK_NONBLOCK | LCK_HOLD); 
+	args[1] = flags & (LCK_LOCAL | LCK_CLUSTER_VG);
 
 	if (mirror_in_sync())
 		args[1] |= LCK_MIRROR_NOSYNC_MODE;


