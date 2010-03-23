From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Mar 2010 18:18:50 -0000
Subject: LVM2/lib/log log.c
Message-ID: <20100323181850.351.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-03-23 18:18:50

Modified files:
	lib/log        : log.c 

Log message:
	Also honour abort_on_internal_errors when log_fn is set.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/lib/log/log.c	2010/01/11 20:41:39	1.57
+++ LVM2/lib/log/log.c	2010/03/23 18:18:49	1.58
@@ -231,7 +231,8 @@
 
 	if (_lvm2_log_fn) {
 		_lvm2_log_fn(level, file, line, 0, message);
-
+		if (fatal_internal_error)
+			abort();
 		return;
 	}
 


