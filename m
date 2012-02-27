From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 11:31:31 -0000
Subject: LVM2/lib/log log.c
Message-ID: <20120227113131.4429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 11:31:31

Modified files:
	lib/log        : log.c 

Log message:
	Explicitely ignore fail error on hash_insert
	
	We cannot do anything better here anyway - we are already in logging function,
	so just ignore this issue here - it will most likely stop application later.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/lib/log/log.c	2012/02/08 11:31:29	1.68
+++ LVM2/lib/log/log.c	2012/02/27 11:31:30	1.69
@@ -262,7 +262,7 @@
 		if (_duplicated) {
 			if (dm_hash_lookup(_duplicated, message))
 				level = _LOG_NOTICE;
-			dm_hash_insert(_duplicated, message, (void*)1);
+			(void) dm_hash_insert(_duplicated, message, (void*)1);
 		}
 	}
 


