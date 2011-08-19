From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 23:01:20 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20110819230120.7244.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 23:01:20

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2082&r2=1.2083

--- LVM2/WHATS_NEW	2011/08/19 19:42:39	1.2082
+++ LVM2/WHATS_NEW	2011/08/19 23:01:20	1.2083
@@ -3,6 +3,7 @@
 
 Version 2.02.88 - 19th August 2011
 ==================================
+  Remove incorrect 'Breaking' error message from allocation code (2.02.87).
   Add lvconvert --merge support for raid1 devices split with --trackchanges.
   Support lvconvert of -m1 raid1 devices to a higher number.
   Add --trackchanges support to lvconvert --splitmirrors option for raid1.


