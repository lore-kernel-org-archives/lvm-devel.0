From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Mar 2010 13:42:30 -0000
Subject: LVM2 ./WHATS_NEW man/dmsetup.8.in
Message-ID: <20100309134230.16301.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-09 13:42:29

Modified files:
	.              : WHATS_NEW 
	man            : dmsetup.8.in 

Log message:
	pre-release cleanups

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1457&r2=1.1458
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/WHATS_NEW	2010/03/09 13:13:08	1.1457
+++ LVM2/WHATS_NEW	2010/03/09 13:42:28	1.1458
@@ -16,7 +16,7 @@
   Extend core allocation code in preparation for mirrored log areas.
   Rewrite clvmd init script.
   Remove lvs_in_vg_activated_by_uuid_only call.
-  Run device info query device by uuid only.
+  No longer fall back to looking up active devices by name if uuid not found.
   Don't touch /dev in vgmknodes if activation is disabled.
   Update lvm2app.h Doxygen comments and add lvm2app Doxygen config file.
   Update nightly tests and lvm2app unit tests to cover tags.
--- LVM2/man/dmsetup.8.in	2010/03/08 16:05:08	1.33
+++ LVM2/man/dmsetup.8.in	2010/03/09 13:42:29	1.34
@@ -324,8 +324,8 @@
 back in using the create or load commands.
 With --target, only information relating to the specified target type
 is displayed.
-By default encryption keys are suppressed in table output (crypt target)
-unless --showkeys parameter is supplied.
+Encryption keys are suppressed in the table output for the crypt
+target unless the --showkeys parameter is supplied.
 .IP \fBtargets
 .br
 Displays the names and versions of the currently-loaded targets.


