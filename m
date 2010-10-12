From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Oct 2010 16:17:27 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20101012161727.29587.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-12 16:17:26

Modified files:
	test           : Makefile.in 

Log message:
	Add an option to skip some tests in make check (regex based, like T=): eg.
	$ sudo make check S='mirror-basic|fsadm'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/test/Makefile.in	2010/05/12 11:59:46	1.42
+++ LVM2/test/Makefile.in	2010/10/12 16:17:25	1.43
@@ -26,7 +26,8 @@
 abs_top_srcdir = @abs_top_srcdir@
 
 T ?= .
-RUN = $(shell find -regextype posix-egrep -name t-\*.sh -and -regex ".*($(T)).*" | sort)
+S ?= @ # never match anything by default
+RUN = $(shell find -regextype posix-egrep -name t-\*.sh -and -regex ".*($(T)).*" -and -not -regex ".*($(S)).*" | sort)
 
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))


