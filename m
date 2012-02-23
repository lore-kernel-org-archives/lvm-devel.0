From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Feb 2012 13:58:57 -0000
Subject: LVM2/daemons Makefile.in
Message-ID: <20120223135857.31093.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-23 13:58:56

Modified files:
	daemons        : Makefile.in 

Log message:
	Add a missed dependency that is required to pull in dameons/common in an early
	part of the build.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/daemons/Makefile.in	2012/02/23 13:41:11	1.23
+++ LVM2/daemons/Makefile.in	2012/02/23 13:58:56	1.24
@@ -52,3 +52,4 @@
 lvmetad: common.device-mapper
 endif
 
+device-mapper: common.device-mapper


