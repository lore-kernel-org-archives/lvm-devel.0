From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Jan 2011 15:06:10 -0000
Subject: LVM2/lib/format_text archiver.c
Message-ID: <20110105150610.12612.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-05 15:06:10

Modified files:
	lib/format_text: archiver.c 

Log message:
	Add sys_debug loging for unlink
	
	This unlink intentionally silently ignores any errors.
	It's still worth to trace its error status in debug mode.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/lib/format_text/archiver.c	2010/12/22 13:45:33	1.36
+++ LVM2/lib/format_text/archiver.c	2011/01/05 15:06:10	1.37
@@ -261,7 +261,9 @@
 	/*
 	 * Let this fail silently.
 	 */
-	unlink(path);
+	if (unlink(path))
+		log_sys_debug("unlink", path);
+
 	return 1;
 }
 


