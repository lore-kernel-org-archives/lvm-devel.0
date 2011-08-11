From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Aug 2011 19:21:43 -0000
Subject: LVM2/lib/log log.c
Message-ID: <20110811192143.23576.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-11 19:21:42

Modified files:
	lib/log        : log.c 

Log message:
	Trivial, add void to ignore dm_snprinf result

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.64&r2=1.65

--- LVM2/lib/log/log.c	2011/04/29 00:21:14	1.64
+++ LVM2/lib/log/log.c	2011/08/11 19:21:42	1.65
@@ -276,8 +276,8 @@
       log_it:
 	if (!_log_suppress) {
 		if (verbose_level() > _LOG_DEBUG)
-			dm_snprintf(locn, sizeof(locn), "#%s:%d ",
-				     file, line);
+			(void) dm_snprintf(locn, sizeof(locn), "#%s:%d ",
+					   file, line);
 		else
 			locn[0] = '\0';
 


