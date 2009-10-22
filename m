From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Oct 2009 11:25:47 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20091022112547.16273.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-22 11:25:47

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1297&r2=1.1298

--- LVM2/WHATS_NEW	2009/10/16 17:41:49	1.1297
+++ LVM2/WHATS_NEW	2009/10/22 11:25:46	1.1298
@@ -1,5 +1,6 @@
 Version 2.02.54 -
 =====================================
+  Delay announcing mirror monitoring to syslog until initialisation succeeded.
   Handle metadata with unknown segment types more gracefully.
   Set default owner and group to null.
   Add dmeventd.static to the build.


