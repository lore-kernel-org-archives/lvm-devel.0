From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:02:21 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20111011090221.31590.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:02:20

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Skip backtrace after log_error

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.241&r2=1.242

--- LVM2/lib/activate/dev_manager.c	2011/10/11 09:01:38	1.241
+++ LVM2/lib/activate/dev_manager.c	2011/10/11 09:02:20	1.242
@@ -1193,7 +1193,7 @@
 
 	if (segno < 0) {
 		log_error("_add_error_device called with bad segment");
-		return_NULL;
+		return NULL;
 	}
 
 	sprintf(errid, "missing_%d_%d", segno, s);


