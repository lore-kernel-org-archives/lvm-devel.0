From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 20:47:19 -0000
Subject: LVM2/lib/metadata lv.c lv.h metadata.c metadat ...
Message-ID: <20100930204719.4998.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 20:47:18

Modified files:
	lib/metadata   : lv.c lv.h metadata.c metadata.h pv.c pv.h vg.c 
	                 vg.h 

Log message:
	Fix copyright dates on new files lib/metadata/{lv|vg|pv}.[ch].

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.402&r2=1.403
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.221&r2=1.222
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/metadata/lv.c	2010/09/30 14:08:19	1.5
+++ LVM2/lib/metadata/lv.c	2010/09/30 20:47:18	1.6
@@ -1,5 +1,6 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/metadata/lv.h	2010/09/30 14:08:20	1.4
+++ LVM2/lib/metadata/lv.h	2010/09/30 20:47:18	1.5
@@ -1,5 +1,6 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/metadata/metadata.c	2010/09/30 14:08:07	1.402
+++ LVM2/lib/metadata/metadata.c	2010/09/30 20:47:18	1.403
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/metadata/metadata.h	2010/09/30 14:08:07	1.221
+++ LVM2/lib/metadata/metadata.h	2010/09/30 20:47:18	1.222
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/metadata/pv.c	2010/09/30 14:09:22	1.7
+++ LVM2/lib/metadata/pv.c	2010/09/30 20:47:18	1.8
@@ -1,5 +1,6 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/metadata/pv.h	2010/09/30 14:09:22	1.6
+++ LVM2/lib/metadata/pv.h	2010/09/30 20:47:18	1.7
@@ -1,5 +1,6 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/metadata/vg.c	2010/09/30 14:08:33	1.6
+++ LVM2/lib/metadata/vg.c	2010/09/30 20:47:18	1.7
@@ -1,5 +1,6 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/metadata/vg.h	2010/09/30 14:08:33	1.5
+++ LVM2/lib/metadata/vg.h	2010/09/30 20:47:18	1.6
@@ -1,5 +1,6 @@
 /*
- * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *


