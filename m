From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Apr 2011 19:06:17 -0000
Subject: LVM2/lib format_text/import_vsn1.c metadata/vg.h
Message-ID: <20110429190617.29509.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-04-29 19:06:17

Modified files:
	lib/format_text: import_vsn1.c 
	lib/metadata   : vg.h 

Log message:
	test update without WHATS_NEW to check it gives warning now

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/lib/format_text/import_vsn1.c	2011/03/27 13:44:08	1.86
+++ LVM2/lib/format_text/import_vsn1.c	2011/04/29 19:06:17	1.87
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
--- LVM2/lib/metadata/vg.h	2011/03/10 12:43:30	1.10
+++ LVM2/lib/metadata/vg.h	2011/04/29 19:06:17	1.11
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *

