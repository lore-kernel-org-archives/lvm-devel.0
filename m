From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2007 23:44:44 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20070124234444.22281.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-24 23:44:44

Modified files:
	.              : WHATS_NEW 

Log message:
	Add init script for dmeventd monitoring.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.556&r2=1.557

--- LVM2/WHATS_NEW	2007/01/24 23:43:26	1.556
+++ LVM2/WHATS_NEW	2007/01/24 23:44:43	1.557
@@ -1,5 +1,6 @@
 Version 2.02.20 -
 ===================================
+  Add init script for dmeventd monitoring.
   lvm.static no longer interacts with dmeventd unless explicitly asked to.
   Add field definitions to report help text.
   Remove unnecessary cmd arg from target_*monitor_events().


