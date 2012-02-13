From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 14:26:15 -0000
Subject: LVM2/lib/cache lvmcache.c
Message-ID: <20120213142615.2001.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 14:26:15

Modified files:
	lib/cache      : lvmcache.c 

Log message:
	Add internal error to guard vgname2 NULL dereference

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.125&r2=1.126

--- LVM2/lib/cache/lvmcache.c	2012/02/12 23:01:19	1.125
+++ LVM2/lib/cache/lvmcache.c	2012/02/13 14:26:15	1.126
@@ -321,13 +321,17 @@
 		if (!dm_hash_get_data(_lock_hash, n))
 			return_0;
 
-		vgname2 = dm_hash_get_key(_lock_hash, n);
+		if (!(vgname2 = dm_hash_get_key(_lock_hash, n))) {
+			log_error(INTERNAL_ERROR "VG lock %s hits NULL.",
+				 vgname);
+			return 0;
+		}
 
 		if (!_vgname_order_correct(vgname2, vgname)) {
 			log_errno(EDEADLK, INTERNAL_ERROR "VG lock %s must "
 				  "be requested before %s, not after.",
 				  vgname, vgname2);
-			return_0;
+			return 0;
 		}
 	}
 


