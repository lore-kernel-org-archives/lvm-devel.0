From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 5 Aug 2009 09:12:47 -0000
Subject: LVM2/lib/activate fs.c
Message-ID: <20090805091247.6698.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-08-05 09:12:44

Modified files:
	lib/activate   : fs.c 

Log message:
	Forgotten '%s' in one of _mk_link warning messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/fs.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/lib/activate/fs.c	2009/08/04 21:44:20	1.46
+++ LVM2/lib/activate/fs.c	2009/08/05 09:12:44	1.47
@@ -186,7 +186,7 @@
 			return 0;
 		}
 	} else if (dm_udev_get_sync_support())
-		log_warn("The link should had been created by udev "
+		log_warn("The link %s should had been created by udev "
 			  "but it was not found. Falling back to "
 			  "direct link creation.", lv_path);
 


