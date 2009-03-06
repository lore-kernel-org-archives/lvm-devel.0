From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Mar 2009 22:49:49 -0000
Subject: LVM2 include/.symlinks liblvm/lvm.h lib/lvm.h
Message-ID: <20090306224949.9096.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-06 22:49:49

Modified files:
	include        : .symlinks 
Added files:
	liblvm         : lvm.h 
Removed files:
	lib            : lvm.h 

Log message:
	Move lvm.h from lib to liblvm.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/lvm.h.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/include/.symlinks	2009/02/24 13:13:56	1.57
+++ LVM2/include/.symlinks	2009/03/06 22:49:48	1.58
@@ -1,6 +1,6 @@
 ../daemons/clvmd/clvm.h
 ../daemons/dmeventd/libdevmapper-event.h
-../lib/lvm.h
+../liblvm/lvm.h
 ../lib/activate/activate.h
 ../lib/activate/targets.h
 ../lib/cache/lvmcache.h
/cvs/lvm2/LVM2/liblvm/lvm.h,v  -->  standard output
revision 1.1
--- LVM2/liblvm/lvm.h
+++ -	2009-03-06 22:49:49.840864000 +0000
@@ -0,0 +1,57 @@
+/*
+ * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
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
+#ifndef _LIB_LVM_H
+#define _LIB_LVM_H
+
+#include "lvm-version.h"
+
+#include <stdint.h>
+
+struct lvm; /* internal data */
+
+/**
+ * The lvm handle.
+ */
+typedef struct lvm *lvm_t;
+
+/**
+ * Create a LVM handle.
+ *
+ * \param   system_dir
+ *          Set an alternative LVM system directory. Use NULL to use the 
+ *          default value. If the environment variable LVM_SYSTEM_DIR is set, 
+ *          it will override any LVM system directory setting.
+ * \return  A valid LVM handle is returned or NULL if there has been a
+ *          memory allocation problem. You have to check if an error occured
+ *          with the lvm_error function.
+ */
+lvm_t lvm_create(const char *system_dir);
+
+/**
+ * Destroy a LVM handle allocated with lvm_create.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ */
+void lvm_destroy(lvm_t libh);
+
+/**
+ * Reload the original configuration from the system directory.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ */
+int lvm_reload_config(lvm_t libh);
+
+#endif /* _LIB_LVM_H */


