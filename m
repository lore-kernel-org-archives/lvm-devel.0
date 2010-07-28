From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Jul 2010 21:58:08 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20100728215808.23551.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-28 21:58:08

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.249&r2=1.250
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1676&r2=1.1677
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.399&r2=1.400

--- LVM2/VERSION	2010/07/28 13:55:42	1.249
+++ LVM2/VERSION	2010/07/28 21:58:08	1.250
@@ -1 +1 @@
-2.02.72(2)-cvs (2010-07-28)
+2.02.73(2)-cvs (2010-07-28)
--- LVM2/VERSION_DM	2010/07/28 11:49:42	1.59
+++ LVM2/VERSION_DM	2010/07/28 21:58:08	1.60
@@ -1 +1 @@
-1.02.53-cvs (2010-07-28)
+1.02.54-cvs (2010-07-28)
--- LVM2/WHATS_NEW	2010/07/28 14:01:40	1.1676
+++ LVM2/WHATS_NEW	2010/07/28 21:58:08	1.1677
@@ -1,3 +1,6 @@
+Version 2.02.73 - 
+================================
+
 Version 2.02.72 - 28th July 2010  [CVE-2010-2526]
 =================================================
   Change clvmd to communicate with lvm2 via a socket in /var/run/lvm.
--- LVM2/WHATS_NEW_DM	2010/07/28 11:49:42	1.399
+++ LVM2/WHATS_NEW_DM	2010/07/28 21:58:08	1.400
@@ -1,3 +1,6 @@
+Version 1.02.54 - 
+================================
+
 Version 1.02.53 - 28th July 2010
 ================================
   Revert failed table load preparation after "create, load and resume".


