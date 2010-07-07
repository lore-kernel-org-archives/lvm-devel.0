From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Jul 2010 02:37:29 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM
Message-ID: <20100707023729.2226.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-07 02:37:28

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1655&r2=1.1656
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.390&r2=1.391
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.245&r2=1.246
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2010/07/07 02:24:05	1.1655
+++ LVM2/WHATS_NEW	2010/07/07 02:37:28	1.1656
@@ -1,3 +1,6 @@
+Version 2.02.71 -
+===============================
+
 Version 2.02.70 - 6th July 2010
 ===============================
   Remove log directly if all mirror images of a mirrored log fail.
@@ -6,7 +9,7 @@
   Add printf format attributes to yes_no_prompt and fix a caller.
   Always pass unsuspended dm devices through persistent filter to other filters.
   Move test for suspended dm devices ahead of other filters.
-  Fix another segfault in clvmd -R if no response from daemon received. (2.02.68)
+  Fix another segfault in clvmd -R if no response from daemon. (2.02.68)
   Remove superfluous suspended device counter from clvmd.
   Fix lvm shell crash when input is entirely whitespace.
   Update partial mode warning message.
--- LVM2/WHATS_NEW_DM	2010/07/06 16:49:39	1.390
+++ LVM2/WHATS_NEW_DM	2010/07/07 02:37:28	1.391
@@ -1,3 +1,6 @@
+Version 1.02.53 -
+===============================
+
 Version 1.02.52 - 6th July 2010
 ===============================
   Fix dmlosetup snprintf %llu compiler warning.
--- LVM2/VERSION	2010/07/06 16:49:38	1.245
+++ LVM2/VERSION	2010/07/07 02:37:28	1.246
@@ -1 +1 @@
-2.02.70(2)-cvs (2010-07-06)
+2.02.71(2)-cvs (2010-07-07)
--- LVM2/VERSION_DM	2010/07/06 16:49:38	1.56
+++ LVM2/VERSION_DM	2010/07/07 02:37:28	1.57
@@ -1 +1 @@
-1.02.52-cvs (2010-07-06)
+1.02.53-cvs (2010-07-07)


