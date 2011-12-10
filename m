From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Dec 2011 14:55:31 -0000
Subject: LVM2/test/shell 000-basic.sh
Message-ID: <20111210145531.5298.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-12-10 14:55:31

Modified files:
	test/shell     : 000-basic.sh 

Log message:
	Nowadays, lvm-version.h is generated from lvm-version.h.in, and lives in the
	build directory, not the source one -> fix test/shell/000-basic.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/000-basic.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/shell/000-basic.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/000-basic.sh	2011/12/10 14:55:31	1.2
@@ -12,7 +12,7 @@
 
 lvm version
 
-v=$abs_top_srcdir/lib/misc/lvm-version.h
+v=$abs_top_builddir/lib/misc/lvm-version.h
 sed -n "/#define LVM_VERSION ./s///p" "$v" | sed "s/ .*//" > expected
 
 lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual


