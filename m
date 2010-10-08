From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Oct 2010 12:36:01 -0000
Subject: LVM2 ./WHATS_NEW scripts/fsadm.sh
Message-ID: <20101008123601.29034.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-08 12:35:59

Modified files:
	.              : WHATS_NEW 
	scripts        : fsadm.sh 

Log message:
	Fix a serious bug in the behavior of fasdm tool when breaked.
	
	Under certain conditions it was possible to break (^C) fsadm before actually
	resizing filesystem, but lvresize which executed fsadm will think resize
	was succesful and shrinks partitions with unresized filesystem on it.
	
	Fix by returning error (1) for this case - this stops lvresize from futher
	proceding in resize operation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1747&r2=1.1748
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/fsadm.sh.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2010/10/07 16:33:34	1.1747
+++ LVM2/WHATS_NEW	2010/10/08 12:35:56	1.1748
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Fix fsadm return error code from user's break action.
   Allow CC to be overridden at build time (for 'scan-build make').
   Rename 'flags' to 'status' in struct metadata_area.
   Avoid segfault by limiting partial mode for lvm1 metadata. (2.02.74)
--- LVM2/scripts/fsadm.sh	2010/10/08 11:18:29	1.13
+++ LVM2/scripts/fsadm.sh	2010/10/08 12:35:59	1.14
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -129,7 +129,8 @@
 	# and allow recursive call of fsadm
 	unset FSADM_RUNNING
 	test "$DO_LVRESIZE" -eq 2 && exec $LVM lvresize $VERB -r -L$(( $NEWSIZE / 1048576 )) $VOLUME
-	exit ${1:-0}
+	# error exit status for break
+	exit ${1:-1}
 }
 
 # convert parameter from Exa/Peta/Tera/Giga/Mega/Kilo/Bytes and blocks


