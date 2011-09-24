From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Sep 2011 20:54:36 -0000
Subject: LVM2/test t-000-basic.sh lib/aux.sh lib/test.sh
Message-ID: <20110924205436.30741.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-24 20:54:36

Modified files:
	test           : t-000-basic.sh 
	test/lib       : aux.sh test.sh 

Log message:
	Detect unusable nodes on fs
	
	Test whether nodes could be used on given filesystem where TMP
	dir is being used and skip teardown quicker in fail case.
	(makes the problem quickly obvious if you try to such fs).
	
	Skip teardown_dev if we have not created any devs yet.
	
	and do not mkdir /dev/mapper dir  when LVM_TEST_DEVDIR is set.
	
	Drop this test from t-000-basic.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/test.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-000-basic.sh	2011/01/05 00:16:20	1.11
+++ LVM2/test/t-000-basic.sh	2011/09/24 20:54:35	1.12
@@ -1,4 +1,4 @@
-# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009-2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -20,11 +20,6 @@
 # ensure they are the same
 diff -u actual expected
 
-mknod $DM_DEV_DIR/null c 1 3 || \
-  error "Can't create nodes on filesystem"
-echo >$DM_DEV_DIR/null || \
-  error "Filesystem for tests does not allow using device nodes (check nodev)"
-
 # ensure we can create devices (uses dmsetup, etc)
 aux prepare_devs 5
 
--- LVM2/test/lib/aux.sh	2011/08/31 11:31:58	1.29
+++ LVM2/test/lib/aux.sh	2011/09/24 20:54:36	1.30
@@ -164,7 +164,7 @@
 
     echo -n .
 
-    teardown_devs
+    test -d $DM_DEV_DIR/mapper && teardown_devs
 
     echo -n .
 
--- LVM2/test/lib/test.sh	2011/08/31 12:42:55	1.6
+++ LVM2/test/lib/test.sh	2011/09/24 20:54:36	1.7
@@ -34,10 +34,15 @@
 
 export LVM_SYSTEM_DIR=$TESTDIR/etc
 DM_DEV_DIR=$TESTDIR/dev
-test -n "$LVM_TEST_DEVDIR" && DM_DEV_DIR="$LVM_TEST_DEVDIR"
+mkdir $LVM_SYSTEM_DIR $TESTDIR/lib $DM_DEV_DIR
+if test -n "$LVM_TEST_DEVDIR" ; then
+	DM_DEV_DIR="$LVM_TEST_DEVDIR"
+else
+	mknod $DM_DEV_DIR/testnull c 1 3 || exit 1;
+	echo >$DM_DEV_DIR/testnull || { echo "Filesystem does support devices in $DM_DEV_DIR (mounted with nodev?)"; exit 1; }
+	mkdir -p $DM_DEV_DIR/mapper
+fi
 export DM_DEV_DIR
-mkdir $LVM_SYSTEM_DIR $TESTDIR/lib
-mkdir -p $DM_DEV_DIR $DM_DEV_DIR/mapper
 
 cd $TESTDIR
 


