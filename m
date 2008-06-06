From: meyering@sourceware.org <meyering@sourceware.org>
Date: 6 Jun 2008 13:48:58 -0000
Subject: LVM2/test lvm-utils.sh
Message-ID: <20080606134858.13107.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-06-06 13:48:58

Modified files:
	test           : lvm-utils.sh 

Log message:
	* lvm-utils.sh (init_root_dir_): Correct a diagnostic.
	
	Author: Jim Meyering <meyering@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/lvm-utils.sh	2008/04/23 13:02:03	1.11
+++ LVM2/test/lvm-utils.sh	2008/06/06 13:48:57	1.12
@@ -1,7 +1,7 @@
 # Put lvm-related utilities here.
 # This file is sourced from test-lib.sh.
 
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007, 2008 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -112,7 +112,7 @@
 {
   test -n "$test_dir_rand_" \
     || error "Internal error: called init_root_dir_ before" \
-      " defining $test_dir_rand_"
+      "defining \$test_dir_rand_"
 
   # Define these two globals.
   G_root_=$test_dir_rand_/root


