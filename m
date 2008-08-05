From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Aug 2008 11:39:55 -0000
Subject: LVM2/test lvm-utils.sh test-lib.sh
Message-ID: <20080805113955.433.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2008-08-05 11:39:55

Modified files:
	test           : lvm-utils.sh test-lib.sh 

Log message:
	avoid endless option parsing loop
	add support for lvm verbose operation -vvvv
	add dlsym path to the test config file

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-lib.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/lvm-utils.sh	2008/06/25 16:51:26	1.13
+++ LVM2/test/lvm-utils.sh	2008/08/05 11:39:54	1.14
@@ -148,10 +148,12 @@
   export DM_DEV_DIR=$G_dev_
 
   # Only the first caller does anything.
-  mkdir -p $G_root_/etc $G_dev_ $G_dev_/mapper
+  mkdir -p $G_root_/etc $G_dev_ $G_dev_/mapper $G_root_/lib
   for i in 0 1 2 3 4 5 6 7; do
     mknod $G_root_/dev/loop$i b 7 $i
   done
+  ln -s $abs_top_builddir/dmeventd/mirror/*.so $G_root_/lib
+  ln -s $abs_top_builddir/dmeventd/snapshot/*.so $G_root_/lib
   cat > $G_root_/etc/lvm.conf <<-EOF
   devices {
     dir = "$G_dev_"
@@ -160,6 +162,18 @@
     cache_dir = "$G_root_/etc"
     sysfs_scan = 0
   }
+  log {
+    verbose = $verboselevel
+    syslog = 0
+    indent = 1
+  }
+  backup {
+    backup = 0
+    archive = 0
+  }
+  global {
+    library_dir = "$G_root_/lib"
+  }
 EOF
 }
 
--- LVM2/test/test-lib.sh	2007/10/09 13:13:06	1.3
+++ LVM2/test/test-lib.sh	2008/08/05 11:39:54	1.4
@@ -42,19 +42,28 @@
 test "${test_description}" != "" ||
 error "Test script did not set test_description."
 
+verboselevel=0
 while test "$#" -ne 0
 do
 	case "$1" in
 	-d|--d|--de|--deb|--debu|--debug)
-		debug=t; shift ;;
+		debug=t ;;
 	-i|--i|--im|--imm|--imme|--immed|--immedi|--immedia|--immediat|--immediate)
-		immediate=t; shift ;;
+		immediate=t ;;
 	-h|--h|--he|--hel|--help)
 		echo "$test_description"
 		exit 0 ;;
 	-v|--v|--ve|--ver|--verb|--verbo|--verbos|--verbose)
-		verbose=t; shift ;;
+		verbose=t ;;
+	-vv|-vvv|-vvvv)
+		verboselevel=${#1}
+		verboselevel=$(($verboselevel - 1))
+		verbose=t ;;
+	*)
+		echo "$0: unsupported option $1"
+		exit 0 ;;
 	esac
+        shift
 done
 
 exec 5>&1


