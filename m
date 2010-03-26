From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Mar 2010 13:21:28 -0000
Subject: LVM2/test lvm-utils.sh
Message-ID: <20100326132128.1572.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-26 13:21:28

Modified files:
	test           : lvm-utils.sh 

Log message:
	Updates .so links for plugins

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/test/lvm-utils.sh	2010/03/25 12:17:10	1.22
+++ LVM2/test/lvm-utils.sh	2010/03/26 13:21:28	1.23
@@ -196,10 +196,10 @@
   for i in 0 1 2 3 4 5 6 7; do
     mknod $G_root_/dev/loop$i b 7 $i
   done
-  for i in $abs_top_builddir/dmeventd/mirror/*.so $abs_top_builddir/dmeventd/snapshot/*.so
+  for i in $abs_top_builddir/daemons/dmeventd/plugins/*/*.so
   do
     # NOTE: This check is necessary because the loop above will give us the value
-    # "$abs_top_builddir/dmeventd/mirror/*.so" if no files ending in 'so' exist.
+    # "$abs_top_builddir/daemons/dmeventd/plugins/*/*.so" if no files ending in 'so' exist.
     # This is the best way I could quickly determine to skip over this bogus value.
     if [ -f $i ]; then
       echo Setting up symlink from $i to $G_root_/lib


