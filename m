From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 22:32:54 -0000
Subject: LVM2/po pogen.h
Message-ID: <20081031223254.20339.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 22:32:54

Modified files:
	po             : pogen.h 

Log message:
	dm+lvm2 macros

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/po/pogen.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/po/pogen.h	2004/03/30 19:35:41	1.2
+++ LVM2/po/pogen.h	2008/10/31 22:32:54	1.3
@@ -13,11 +13,11 @@
  */
 
 /*
- * Macro to change log messages into a format that xgettext can handle.
+ * Macros to change log messages into a format that xgettext can handle.
  *
  * Note that different PRI* definitions lead to different strings for
  * different architectures.
  */
 
 #define print_log(level, file, line, format, args...) print_log(format, args)
-
+#define dm_log(level, file, line, format, args...) dm_log(format, args)


