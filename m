From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Jan 2012 18:25:47 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20120126182547.22783.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-26 18:25:47

Modified files:
	test/lib       : aux.sh 

Log message:
	If clvmd is not started, die test instead of skipping it

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/test/lib/aux.sh	2011/12/12 00:01:12	1.35
+++ LVM2/test/lib/aux.sh	2012/01/26 18:25:46	1.36
@@ -1,5 +1,5 @@
 #!/bin/bash
-# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -34,8 +34,8 @@
 
 	# check that it is really running now
 	sleep .1
-	ps $LOCAL_CLVMD || skip
-        echo "$LOCAL_CLVMD" > LOCAL_CLVMD
+	ps $LOCAL_CLVMD || die
+	echo "$LOCAL_CLVMD" > LOCAL_CLVMD
 }
 
 prepare_dmeventd() {


