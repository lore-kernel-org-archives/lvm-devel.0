From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 May 2010 11:59:49 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20100512115949.6205.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-12 11:59:46

Modified files:
	test           : Makefile.in 

Log message:
	Run tests in alphabetical (and thus stable across machines) order.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/test/Makefile.in	2010/05/12 11:23:16	1.41
+++ LVM2/test/Makefile.in	2010/05/12 11:59:46	1.42
@@ -26,7 +26,7 @@
 abs_top_srcdir = @abs_top_srcdir@
 
 T ?= .
-RUN = $(shell find -regextype posix-egrep -name t-\*.sh -and -regex ".*($(T)).*")
+RUN = $(shell find -regextype posix-egrep -name t-\*.sh -and -regex ".*($(T)).*" | sort)
 
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))


