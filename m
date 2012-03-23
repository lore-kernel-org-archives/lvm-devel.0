From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2012 09:48:19 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-command.c
Message-ID: <20120323094819.21563.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-23 09:48:18

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-command.c 

Log message:
	Return mem fail if hash insert fails

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2363&r2=1.2364
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68

--- LVM2/WHATS_NEW	2012/03/23 09:42:36	1.2363
+++ LVM2/WHATS_NEW	2012/03/23 09:48:17	1.2364
@@ -1,5 +1,7 @@
 Version 2.02.96 - 
 ================================
+  Check hash insert success in lock_vg clvmd.
+  Check for buffer overwrite in get_cluster_type() clvmd.
   Fix global/detect_internal_vg_cache_corruption config check.
   Update lcov Makefile target to support all dmeventd plugins.
   Fix initializiation of thin monitoring (2.02.92).
--- LVM2/daemons/clvmd/clvmd-command.c	2012/03/01 21:14:43	1.67
+++ LVM2/daemons/clvmd/clvmd-command.c	2012/03/23 09:48:18	1.68
@@ -240,7 +240,8 @@
 	if (status)
 	    status = errno;
 	else
-	    dm_hash_insert(lock_hash, lockname, (void *)(long)lkid);
+	    if (!dm_hash_insert(lock_hash, lockname, (void *)(long)lkid))
+                    return ENOMEM;
     }
 
     return status;


