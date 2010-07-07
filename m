From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Jul 2010 02:24:05 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100707022405.30169.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-07 02:24:05

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1654&r2=1.1655

--- LVM2/WHATS_NEW	2010/07/06 17:02:03	1.1654
+++ LVM2/WHATS_NEW	2010/07/07 02:24:05	1.1655
@@ -1,6 +1,6 @@
 Version 2.02.70 - 6th July 2010
 ===============================
-  Change logic to handle double failure of a "mirrored" mirror log.
+  Remove log directly if all mirror images of a mirrored log fail.
   Randomly select which mdas to use or ignore.
   Add some missing standard configure.in checks.
   Add printf format attributes to yes_no_prompt and fix a caller.


