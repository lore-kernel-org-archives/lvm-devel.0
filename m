From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 13 Feb 2012 07:30:27 -0000
Subject: LVM2 configure
Message-ID: <20120213073027.6381.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-02-13 07:30:27

Modified files:
	.              : configure 

Log message:
	Update autoconf.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.165&r2=1.166

--- LVM2/configure	2012/01/31 21:21:53	1.165
+++ LVM2/configure	2012/02/13 07:30:24	1.166
@@ -8099,6 +8099,12 @@
 	fi
 fi
 
+if [ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]; then
+   if test x$HAVE_CMAP = xyes; then
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS dlm"
+   fi
+fi
+
 ################################################################################
 if test "x$CLVMD" != xnone; then
 


