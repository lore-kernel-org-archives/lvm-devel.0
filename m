From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:18:39 -0000
Subject: LVM2/daemons/clvmd lvm-functions.c
Message-ID: <20120301211839.10866.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:18:39

Modified files:
	daemons/clvmd  : lvm-functions.c 

Log message:
	Debug log for hold_lock failure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132

--- LVM2/daemons/clvmd/lvm-functions.c	2012/03/01 09:54:24	1.131
+++ LVM2/daemons/clvmd/lvm-functions.c	2012/03/01 21:18:38	1.132
@@ -767,7 +767,8 @@
 					LCK_EXCL : LCK_READ;
 
 				DEBUGLOG("getting initial lock for %s\n", uuid);
-				hold_lock(uuid, lock_mode, LCKF_NOQUEUE);
+				if (hold_lock(uuid, lock_mode, LCKF_NOQUEUE))
+					DEBUGLOG("Failed to hold lock %s\n", uuid);
 			}
 		}
 	}


