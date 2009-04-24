From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Apr 2009 21:44:16 -0000
Subject: LVM2 configure configure.in
Message-ID: <20090424214416.23394.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-04-24 21:44:15

Modified files:
	.              : configure configure.in 

Log message:
	Fix linux configure --enable-debug to exclude -O2.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/configure	2009/03/06 16:19:52	1.92
+++ LVM2/configure	2009/04/24 21:44:15	1.93
@@ -2129,6 +2129,7 @@
 
 case "$host_os" in
 	linux*)
+		CFLAGS="$CFLAGS"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"
--- LVM2/configure.in	2009/03/06 16:19:53	1.97
+++ LVM2/configure.in	2009/04/24 21:44:15	1.98
@@ -28,6 +28,7 @@
 
 case "$host_os" in
 	linux*)
+		CFLAGS="$CFLAGS"
 		COPTIMISE_FLAG="-O2"
 		CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"
 		CLDWHOLEARCHIVE="-Wl,-whole-archive"


