From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 21 Aug 2008 14:33:49 -0000
Subject: LVM2/test lvm-utils.sh
Message-ID: <20080821143349.14478.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-08-21 14:33:48

Modified files:
	test           : lvm-utils.sh 

Log message:
	Fix symbolic link creation in test infrastructure.
	
	Original code would create "*.so" symbolic links if there were no actual
	files ending in "so".  The second iteration would then cause an error
	in the test logs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/test/lvm-utils.sh	2008/08/05 11:39:54	1.14
+++ LVM2/test/lvm-utils.sh	2008/08/21 14:33:48	1.15
@@ -152,8 +152,16 @@
   for i in 0 1 2 3 4 5 6 7; do
     mknod $G_root_/dev/loop$i b 7 $i
   done
-  ln -s $abs_top_builddir/dmeventd/mirror/*.so $G_root_/lib
-  ln -s $abs_top_builddir/dmeventd/snapshot/*.so $G_root_/lib
+  for i in $abs_top_builddir/dmeventd/mirror/*.so $abs_top_builddir/dmeventd/snapshot/*.so
+  do
+    # NOTE: This check is necessary because the loop above will give us the value
+    # "$abs_top_builddir/dmeventd/mirror/*.so" if no files ending in 'so' exist.
+    # This is the best way I could quickly determine to skip over this bogus value.
+    if [ -f $i ]; then
+      echo Setting up symlink from $i to $G_root_/lib
+      ln -s $i $G_root_/lib
+    fi
+  done
   cat > $G_root_/etc/lvm.conf <<-EOF
   devices {
     dir = "$G_dev_"


