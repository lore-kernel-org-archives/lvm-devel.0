From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Aug 2007 19:56:19 -0000
Subject: LVM2 ./WHATS_NEW tools/args.h
Message-ID: <20070821195619.22025.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-08-21 19:56:18

Modified files:
	.              : WHATS_NEW 
	tools          : args.h 

Log message:
	Fix (C) !

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.688&r2=1.689
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/WHATS_NEW	2007/08/21 19:46:35	1.688
+++ LVM2/WHATS_NEW	2007/08/21 19:56:18	1.689
@@ -1,3 +1,8 @@
+DO NOT RELEASE UNTIL FOLLOWING FIXED/REVIEWED:
+
+changed text also needs fixing - some poor English
+lvcreate page needs fixing too - emphasis on best behaviour (disk log) got inverted!
+
 Version 2.02.28 -
 ================================
   Only permit --force, --verbose and --debug arguments to be repeated.
--- LVM2/tools/args.h	2007/08/21 19:46:36	1.54
+++ LVM2/tools/args.h	2007/08/21 19:56:18	1.55
@@ -1,6 +1,6 @@
 /*
- * Copyright (C, 0) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C, 0) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *


