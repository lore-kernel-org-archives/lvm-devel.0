From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jan 2010 20:30:33 -0000
Subject: LVM2/lib/log log.c
Message-ID: <20100111203033.15294.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-11 20:30:33

Modified files:
	lib/log        : log.c 

Log message:
	Internal errors triggering abort cannot be suppressed. (kabi)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.55&r2=1.56

--- LVM2/lib/log/log.c	2009/12/16 19:22:12	1.55
+++ LVM2/lib/log/log.c	2010/01/11 20:30:32	1.56
@@ -187,8 +187,8 @@
 	    !strncmp(format, INTERNAL_ERROR,
 		     strlen(INTERNAL_ERROR)))
 		internal_error = 1;
-
-	if (_log_suppress == 2)
+	else if (_log_suppress == 2)
+		/* Internal errors triggering abort cannot be suppressed. */
 		return;
 
 	if (level <= _LOG_ERR)


