From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Jul 2008 09:50:24 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20080710095024.18491.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-10 09:50:23

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.926&r2=1.927

--- LVM2/WHATS_NEW	2008/07/09 09:59:41	1.926
+++ LVM2/WHATS_NEW	2008/07/10 09:50:23	1.927
@@ -1,7 +1,6 @@
 Version 2.02.40 - 
 ================================
-  Fix dmeventd regression where mirror and snapshot monitoring libraries
-  failed to link against liblvm2cmd.
+  Fix dmeventd monitoring libraries to link against liblvm2cmd again. (2.02.39)
 
 Version 2.02.39 - 27th June 2008
 ================================


