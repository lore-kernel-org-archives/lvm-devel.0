From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 13 Jun 2008 07:44:15 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20080613074415.15242.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2008-06-13 07:44:15

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Don't call openlog for every invocation of debuglog.
	Patch from Masatake YAMATO

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.901&r2=1.902
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2008/06/12 13:24:02	1.901
+++ LVM2/WHATS_NEW	2008/06/13 07:44:14	1.902
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Don't call openlog for every debug line output by clvmd.
   Add --force to lvextend and lvresize.
   Fix vgchange to not activate mirror leg and log volumes directly.
   Fix test directory clean up in make distclean.
--- LVM2/daemons/clvmd/clvmd.c	2008/06/05 14:24:28	1.47
+++ LVM2/daemons/clvmd/clvmd.c	2008/06/13 07:44:14	1.48
@@ -182,8 +182,10 @@
 		va_end(ap);
 	}
 	if (debug == DEBUG_SYSLOG) {
-		if (!syslog_init)
+		if (!syslog_init) {
 			openlog("clvmd", LOG_PID, LOG_DAEMON);
+			syslog_init = 1;
+		}
 
 		va_start(ap,fmt);
 		vsyslog(LOG_DEBUG, fmt, ap);


