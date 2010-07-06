From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jul 2010 16:49:40 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100706164940.18826.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-06 16:49:39

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.244&r2=1.245
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.55&r2=1.56
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1652&r2=1.1653
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.389&r2=1.390

--- LVM2/VERSION	2010/06/30 14:50:32	1.244
+++ LVM2/VERSION	2010/07/06 16:49:38	1.245
@@ -1 +1 @@
-2.02.70(2)-cvs (2010-06-30)
+2.02.70(2)-cvs (2010-07-06)
--- LVM2/VERSION_DM	2010/06/30 14:50:32	1.55
+++ LVM2/VERSION_DM	2010/07/06 16:49:38	1.56
@@ -1 +1 @@
-1.02.52-cvs (2010-06-30)
+1.02.52-cvs (2010-07-06)
--- LVM2/WHATS_NEW	2010/07/05 22:23:15	1.1652
+++ LVM2/WHATS_NEW	2010/07/06 16:49:38	1.1653
@@ -1,5 +1,5 @@
-Version 2.02.70 - 
-================================
+Version 2.02.70 - 6th July 2010
+===============================
   Randomly select which mdas to use or ignore.
   Add some missing standard configure.in checks.
   Add printf format attributes to yes_no_prompt and fix a caller.
@@ -10,7 +10,7 @@
   Fix lvm shell crash when input is entirely whitespace.
   Update partial mode warning message.
   Preserve memlock balance in clvmd when activation triggers a resume.
-  Restore the "removemissing" behaviour of lvconvert --repair --use-policies.
+  Restore the removemissing behaviour of lvconvert --repair --use-policies.
 
 Version 2.02.69 - 30th June 2010
 ================================
--- LVM2/WHATS_NEW_DM	2010/07/05 22:56:45	1.389
+++ LVM2/WHATS_NEW_DM	2010/07/06 16:49:39	1.390
@@ -1,5 +1,5 @@
-Version 1.02.52 -
-================================
+Version 1.02.52 - 6th July 2010
+===============================
   Fix dmlosetup snprintf %llu compiler warning.
   Add parentheses to some libdevmapper.h macro arguments.
   Add printf format attributes to dm_{sn,as}printf and fix a caller.


