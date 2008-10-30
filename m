From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Oct 2008 17:54:13 -0000
Subject: LVM2 include/.symlinks libdm/misc/dm-logging.h
Message-ID: <20081030175413.23118.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-30 17:54:12

Modified files:
	include        : .symlinks 
Added files:
	libdm/misc     : dm-logging.h 

Log message:
	Add dm-logging.h ready for libdevmapper.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-logging.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/include/.symlinks	2008/10/30 17:27:28	1.49
+++ LVM2/include/.symlinks	2008/10/30 17:54:11	1.50
@@ -51,6 +51,7 @@
 ../lib/report/report.h
 ../lib/uuid/uuid.h
 ../libdm/misc/dm-ioctl.h
+../libdm/misc/dm-logging.h
 ../libdm/misc/kdev_t.h
 ../po/pogen.h
 ../tools/version.h
/cvs/lvm2/LVM2/libdm/misc/dm-logging.h,v  -->  standard output
revision 1.1
--- LVM2/libdm/misc/dm-logging.h
+++ -	2008-10-30 17:54:13.164822000 +0000
@@ -0,0 +1,27 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
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
+#ifndef _DM_LOGGING_H
+#define _DM_LOGGING_H
+
+#include "libdevmapper.h"
+
+extern dm_log_fn dm_log;
+
+#define plog(l, x...) dm_log(l, __FILE__, __LINE__, ## x)
+
+#include "log.h"
+
+#endif


