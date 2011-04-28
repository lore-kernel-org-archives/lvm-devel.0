From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Apr 2011 19:59:18 -0000
Subject: LVM2/lib/device dev-cache.c
Message-ID: <20110428195918.29719.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-28 19:59:17

Modified files:
	lib/device     : dev-cache.c 

Log message:
	Missing space in debug message

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/dev-cache.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/lib/device/dev-cache.c	2011/04/22 12:05:33	1.64
+++ LVM2/lib/device/dev-cache.c	2011/04/28 19:59:17	1.65
@@ -546,7 +546,7 @@
 					  "cache fully", dl->dir);
 		}
 		else if (!_insert_dir(dl->dir))
-			log_debug("%s: Failed to insert devices to"
+			log_debug("%s: Failed to insert devices to "
 				  "device cache fully", dl->dir);
 	}
 }

