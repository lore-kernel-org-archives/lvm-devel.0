From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Sep 2007 19:51:03 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20070917195103.15834.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-09-17 19:51:03

Modified files:
	.              : WHATS_NEW 

Log message:
	Moved the obsolete test subdirectory to old-tests.
	If you're using the CVS repository you'll need to remove it and check
	it out again when we repopulate it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.709&r2=1.710

--- LVM2/WHATS_NEW	2007/09/17 17:18:37	1.709
+++ LVM2/WHATS_NEW	2007/09/17 19:51:02	1.710
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Moved the obsolete test subdirectory to old-tests.
   Remove no-longer-correct restrictions on PV arg count with stripes/mirrors.
   Fix strdup memory leak in str_list_dup().
   Link with -lpthread when static SELinux libraries require that.


