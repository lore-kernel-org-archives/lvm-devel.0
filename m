From: meyering@sourceware.org <meyering@sourceware.org>
Date: 11 Jun 2008 15:02:53 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20080611150253.5385.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-06-11 15:02:52

Modified files:
	tools          : toollib.c 

Log message:
	break (rather than return) so we have only one point of return
	
	* tools/toollib.c (process_each_segment_in_lv): Upon sigint_caught,
	break rather than returning ret_max.  No semantic change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.135&r2=1.136

--- LVM2/tools/toollib.c	2008/06/10 20:07:04	1.135
+++ LVM2/tools/toollib.c	2008/06/11 15:02:52	1.136
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -404,7 +404,7 @@
 		if (ret > ret_max)
 			ret_max = ret;
 		if (sigint_caught())
-			return ret_max;
+			break;
 	}
 
 	return ret_max;


