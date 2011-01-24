From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2011 23:24:08 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW
Message-ID: <20110124232408.13200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-01-24 23:24:06

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.270&r2=1.271
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1889&r2=1.1890

--- LVM2/VERSION	2011/01/17 18:16:18	1.270
+++ LVM2/VERSION	2011/01/24 23:24:06	1.271
@@ -1 +1 @@
-2.02.82(2)-cvs (2011-01-17)
+2.02.82(2)-cvs (2011-01-24)
--- LVM2/VERSION_DM	2011/01/17 18:16:18	1.78
+++ LVM2/VERSION_DM	2011/01/24 23:24:06	1.79
@@ -1 +1 @@
-1.02.62-cvs (2011-01-17)
+1.02.62-cvs (2011-01-24)
--- LVM2/WHATS_NEW	2011/01/24 20:02:07	1.1889
+++ LVM2/WHATS_NEW	2011/01/24 23:24:06	1.1890
@@ -1,12 +1,12 @@
-Version 2.02.82 -
+Version 2.02.82 - 24th January 2011
 ===================================
   Bring lvscan man page up-to-date.
   Fix lvchange --test to exit cleanly.
   Add change_tag to toollib.
   Allow multiple pvchange command line options to be specified together.
+  Do not fail pvmove polling if another process cleaned up first.
+  Avoid clvmd incrementing dlm lockspace reference count more than once.
   Add -f (don't fork) option to clvmd and fix clvmd -d<num> description.
-  Fix possible clvmd DLM lockspace increasing reference count.
-  Do not fail polling if pvmove finished in another process.
 
 Version 2.02.81 - 17th January 2011
 ===================================


