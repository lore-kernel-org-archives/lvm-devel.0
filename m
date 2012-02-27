From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 10:02:18 -0000
Subject: LVM2/daemons/clvmd clvmd-command.c
Message-ID: <20120227100218.12655.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 10:02:17

Modified files:
	daemons/clvmd  : clvmd-command.c 

Log message:
	Explicitely ignore result from sync_unlock()
	
	Make it obvious to analyzer - we can't do anything better here anyway.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.65&r2=1.66

--- LVM2/daemons/clvmd/clvmd-command.c	2012/02/23 22:23:12	1.65
+++ LVM2/daemons/clvmd/clvmd-command.c	2012/02/27 10:02:17	1.66
@@ -355,7 +355,7 @@
 		lkid = (int)(long)dm_hash_get_data(lock_hash, v);
 		lockname = dm_hash_get_key(lock_hash, v);
 		DEBUGLOG("cleanup: Unlocking lock %s %x\n", lockname, lkid);
-		sync_unlock(lockname, lkid);
+		(void) sync_unlock(lockname, lkid);
 	}
 
 	dm_hash_destroy(lock_hash);


