From: agk@sourceware.org <agk@sourceware.org>
Date: 21 Dec 2010 01:14:34 -0000
Subject: LVM2/test/api percent.c percent.sh
Message-ID: <20101221011434.18964.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-12-21 01:14:34

Modified files:
	test/api       : percent.c percent.sh 

Log message:
	Copyright notices for new files.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/api/percent.c	2010/12/20 12:29:39	1.2
+++ LVM2/test/api/percent.c	2010/12/21 01:14:34	1.3
@@ -1,3 +1,17 @@
+/*
+ * Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
 #include "lvm2app.h"
 
 #define assert(x) do { if (!(x)) goto bad; } while (0)
--- LVM2/test/api/percent.sh	2010/12/14 23:20:59	1.1
+++ LVM2/test/api/percent.sh	2010/12/21 01:14:34	1.2
@@ -1,3 +1,16 @@
+#
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
+
 . ./test-utils.sh
 aux prepare_devs 2
 vgcreate -c n -s 4k $vg $devs


