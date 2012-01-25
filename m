From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 22:37:49 -0000
Subject: LVM2/lib/metadata lv_alloc.h
Message-ID: <20120125223749.7405.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 22:37:48

Modified files:
	lib/metadata   : lv_alloc.h 

Log message:
	Set missing header define

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_alloc.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/metadata/lv_alloc.h	2011/10/23 16:02:02	1.31
+++ LVM2/lib/metadata/lv_alloc.h	2012/01/25 22:37:48	1.32
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -14,6 +14,7 @@
  */
 
 #ifndef _LVM_LV_ALLOC_H
+#define _LVM_LV_ALLOC_H
 
 struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    struct logical_volume *lv,


