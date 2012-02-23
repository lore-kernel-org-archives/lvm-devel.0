From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 13:31:01 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20120223133101.32401.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 13:31:01

Modified files:
	.              : make.tmpl.in 

Log message:
	Add -ldaemon to make.tmpl.in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/make.tmpl.in	2012/02/22 17:55:10	1.130
+++ LVM2/make.tmpl.in	2012/02/23 13:31:01	1.131
@@ -39,7 +39,7 @@
 LDDEPS += @LDDEPS@
 LDFLAGS += @LDFLAGS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(UDEV_LIBS) $(DL_LIBS)
+LVMINTERNAL_LIBS = -llvm-internal -L$(top_builddir)/daemons/common -ldaemon $(UDEV_LIBS) $(DL_LIBS)
 DL_LIBS = @DL_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@


