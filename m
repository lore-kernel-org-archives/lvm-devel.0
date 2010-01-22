From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Jan 2010 14:33:34 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100122143334.4763.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-22 14:33:33

Modified files:
	.              : WHATS_NEW 

Log message:
	Document undocumented commits which fixed some bugs.
	Go WHATS_NEW!

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1402&r2=1.1403

--- LVM2/WHATS_NEW	2010/01/22 09:45:29	1.1402
+++ LVM2/WHATS_NEW	2010/01/22 14:33:33	1.1403
@@ -1,5 +1,8 @@
 Version 2.02.60
 ===================================
+  Disable not thread-safe memory debugging if dmeventd is configured.
+  Fix first log message prefix in syslog for dmeventd plugins.
+  Fix exported symbols names for dmeventd lvm2 wrapper plugin.
   Fix failed locking messages to be more descriptive.
 
 Version 2.02.59 - 21st January 2010


