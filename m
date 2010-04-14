From: agk@sourceware.org <agk@sourceware.org>
Date: 14 Apr 2010 20:03:48 -0000
Subject: LVM2/scripts lvmdump.sh
Message-ID: <20100414200348.18028.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-14 20:03:47

Modified files:
	scripts        : lvmdump.sh 

Log message:
	touch file

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmdump.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/scripts/lvmdump.sh	2009/01/06 18:02:58	1.14
+++ LVM2/scripts/lvmdump.sh	2010/04/14 20:03:46	1.15
@@ -1,7 +1,7 @@
 #!/bin/bash
 # We use some bash-isms (getopts?)
 
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #


