From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:20:59 -0000
Subject: LVM2/lib/misc configure.h.in
Message-ID: <20120228182059.20352.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:20:58

Modified files:
	lib/misc       : configure.h.in 

Log message:
	Add LVMETAD_SUPPORT

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/lib/misc/configure.h.in	2012/02/15 11:20:13	1.37
+++ LVM2/lib/misc/configure.h.in	2012/02/28 18:20:58	1.38
@@ -452,6 +452,9 @@
 /* Define to 1 to include built-in support for LVM1 metadata. */
 #undef LVM1_INTERNAL
 
+/* Define to 1 to include code that uses lvmetad. */
+#undef LVMETAD_SUPPORT
+
 /* Path to lvm binary. */
 #undef LVM_PATH
 


