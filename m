From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Dec 2009 18:16:39 -0000
Subject: LVM2/lib/locking cluster_locking.c
Message-ID: <20091209181639.27500.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-12-09 18:16:38

Modified files:
	lib/locking    : cluster_locking.c 

Log message:
	Get rid of hardcoded 0xffdf cluster lock flag.
	
	There is hidded change - the upper flags (0xffff0000)
	and now not cleared, but there are unused anyway.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/lib/locking/cluster_locking.c	2009/06/12 08:30:19	1.36
+++ LVM2/lib/locking/cluster_locking.c	2009/12/09 18:16:38	1.37
@@ -415,7 +415,7 @@
 		clvmd_cmd = CLVMD_CMD_LOCK_LV;
 		strcpy(lockname, resource);
 		lock_scope = "LV";
-		flags &= 0xffdf;	/* Mask off HOLD flag */
+		flags &= ~LCK_HOLD;	/* Mask off HOLD flag */
 		break;
 
 	default:


