From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Jan 2008 12:36:37 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20080119123637.28226.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-19 12:36:37

Modified files:
	.              : WHATS_NEW 

Log message:
	clarify

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.772&r2=1.773

--- LVM2/WHATS_NEW	2008/01/19 12:30:55	1.772
+++ LVM2/WHATS_NEW	2008/01/19 12:36:37	1.773
@@ -5,7 +5,7 @@
 ===================================
   Fix lvcreate --nosync not to wait for non-happening sync. (2.02.30)
   Add very_verbose lvconvert messages.
-  Avoid error message when using default setting of lvcreate -M1. (2.02.29)
+  Avoid readahead error message with default setting of lvcreate -M1. (2.02.29)
 
 Version 2.02.30 - 17th January 2008
 ===================================


