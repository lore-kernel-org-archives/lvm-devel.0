From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2010 16:30:14 -0000
Subject: LVM2 ./WHATS_NEW test/Makefile.in test/test-ut ...
Message-ID: <20100215163014.919.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-02-15 16:30:13

Modified files:
	.              : WHATS_NEW 
	test           : Makefile.in test-utils.sh 

Log message:
	Use udev transactions in testsuite.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1427&r2=1.1428
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/WHATS_NEW	2010/02/15 16:26:48	1.1427
+++ LVM2/WHATS_NEW	2010/02/15 16:30:13	1.1428
@@ -1,5 +1,6 @@
 Version 2.02.61 - 
 ===================================
+  Use udev transactions in testsuite.
   Don't use LVM_UDEV_DISABLE_CHECKING env. var. anymore and set the state automatically.
   Add lvm2app exports lvm_pv_get_size(), lvm_pv_get_free(), and lvm_pv_get_dev_size().
   Fix off by 512 sizes for lvm2app.
--- LVM2/test/Makefile.in	2010/01/11 15:48:50	1.25
+++ LVM2/test/Makefile.in	2010/02/15 16:30:13	1.26
@@ -31,8 +31,7 @@
 T = $(wildcard $(srcdir)/t-*.sh)
 
 ifeq ("@UDEV_SYNC@", "yes")
-dm_udev_disable_checking = 1
-lvm_udev_disable_checking = 1
+dm_udev_synchronisation = 1
 endif
 
 ifeq ("@APPLIB@", "yes")
@@ -61,8 +60,7 @@
 	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
 	echo 'abs_builddir=$(abs_builddir)' >> $@-t
 	echo 'export PATH' >> $@-t
-	echo 'export DM_UDEV_DISABLE_CHECKING=$(dm_udev_disable_checking)' >> $@-t
-	echo 'export LVM_UDEV_DISABLE_CHECKING=$(lvm_udev_disable_checking)' >> $@-t
+	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	chmod a-w $@-t
 	mv $@-t $@
 	if test "$(srcdir)" != "."; then cp $(srcdir)/test-utils.sh \
--- LVM2/test/test-utils.sh	2010/02/01 19:43:22	1.19
+++ LVM2/test/test-utils.sh	2010/02/15 16:30:13	1.20
@@ -24,7 +24,20 @@
 		echo "$i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
 		i=$(($i + 1));
 	done
-}	
+}
+
+init_udev_transaction() {
+	if test "$DM_UDEV_SYNCHRONISATION" = 1; then
+		export DM_UDEV_COOKIE=$(dmsetup udevcreatecookie)
+	fi
+}
+
+finish_udev_transaction() {
+	if test "$DM_UDEV_SYNCHRONISATION" = 1; then
+		dmsetup udevreleasecookie
+		unset DM_UDEV_COOKIE
+	fi
+}
 
 teardown() {
 	echo $LOOP
@@ -32,12 +45,15 @@
 
 	test -n "$PREFIX" && {
 		rm -rf $G_root_/dev/$PREFIX*
+
+		init_udev_transaction
 		while dmsetup table | grep -q ^$PREFIX; do
 			for s in `dmsetup table | grep ^$PREFIX| awk '{ print substr($1,1,length($1)-1) }'`; do
-				dmsetup resume $s 2>/dev/null > /dev/null || true
 				dmsetup remove $s 2>/dev/null > /dev/null || true
 			done
 		done
+		finish_udev_transaction
+
 	}
 
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
@@ -180,6 +196,7 @@
 
 	local size=$(($loopsz/$n))
 
+	init_udev_transaction
 	for i in `seq 1 $n`; do
 		local name="${PREFIX}$pvname$i"
 		local dev="$G_dev_/mapper/$name"
@@ -188,6 +205,7 @@
 		echo 0 $size linear $LOOP $((($i-1)*$size)) > $name.table
 		dmsetup create $name $name.table
 	done
+	finish_udev_transaction
 
     # set up some default names
 	vg=${PREFIX}vg
@@ -201,6 +219,8 @@
 }
 
 disable_dev() {
+
+	init_udev_transaction
 	for dev in "$@"; do
         # first we make the device inaccessible
 		echo 0 10000000 error | dmsetup load $dev
@@ -208,14 +228,19 @@
         # now let's try to get rid of it if it's unused
         #dmsetup remove $dev
 	done
+	finish_udev_transaction
+
 }
 
 enable_dev() {
+
+	init_udev_transaction
 	for dev in "$@"; do
 		local name=`echo "$dev" | sed -e 's,.*/,,'`
 		dmsetup create $name $name.table || dmsetup load $name $name.table
 		dmsetup resume $dev
 	done
+	finish_udev_transaction
 }
 
 backup_dev() {


