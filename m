From: Thomas Woerner <twoerner@redhat.com>
Date: Fri, 20 Feb 2009 17:41:50 +0100
Subject: [PATCH 2/3] Rename version.h to lvm-version.h, move it to lib/misc, add more version defines.
In-Reply-To: <1235148111-10652-2-git-send-email-twoerner@redhat.com>
References: <1235148111-10652-1-git-send-email-twoerner@redhat.com>
	<1235148111-10652-2-git-send-email-twoerner@redhat.com>
Message-ID: <1235148111-10652-3-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Rename version.h to lvm-version.h, move it to lib/misc and add more version
defines. New defines are LVM_MAJOR, LVM_MINOR, LVM_PATCHLEVEL, LVM_RELEASE and
LVM_RELEASE_DATE generated in configure. New GPL header. Fixed all occurances
of version.h in the code.

Use $AWK for DM_LIB_PATCHLEVEL in configure.

TODO: recreate configure

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 configure.in              |   20 +++++++++++++++++---
 daemons/clvmd/clvmd.c     |    4 ++--
 include/.symlinks         |    2 +-
 lib/format_text/export.c  |    4 ++--
 lib/misc/lvm-version.h.in |   29 +++++++++++++++++++++++++++++
 make.tmpl.in              |    4 ++--
 test/t-000-basic.sh       |    4 ++--
 tools/lvmcmdlib.c         |    4 ++--
 tools/lvmcmdline.c        |    2 +-
 tools/version.h.in        |    3 ---
 10 files changed, 58 insertions(+), 18 deletions(-)
 create mode 100644 lib/misc/lvm-version.h.in
 delete mode 100644 tools/version.h.in

diff --git a/configure.in b/configure.in
index ea77eff..a117dea 100644
--- a/configure.in
+++ b/configure.in
@@ -1,6 +1,6 @@
 ###############################################################################
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
-## Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+## Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
@@ -719,10 +719,19 @@ AC_MSG_RESULT($interface)
 DM_LIB_VERSION="\"`cat VERSION_DM 2>/dev/null || echo Unknown`\""
 AC_DEFINE_UNQUOTED(DM_LIB_VERSION, $DM_LIB_VERSION, [Library version])
 
-DM_LIB_PATCHLEVEL=`cat VERSION_DM | awk -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
+DM_LIB_PATCHLEVEL=`cat VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
+VER=`cat VERSION`
+LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.*(//;s/).*//'`\""
+VER=`echo "$VER" | $AWK '{print $1}'`
+LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
+VER=`echo "$VER" | $AWK -F '-' '{print $1}'`
+LVM_MAJOR=`echo "$VER" | $AWK -F '.' '{print $1}'`
+LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
+LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
+
 ################################################################################
 AC_SUBST(BUILD_DMEVENTD)
 AC_SUBST(CFLAGS)
@@ -761,6 +770,11 @@ AC_SUBST(LVM1)
 AC_SUBST(LVM1_FALLBACK)
 AC_SUBST(CONFDIR)
 AC_SUBST(LVM_VERSION)
+AC_SUBST(LVM_MAJOR)
+AC_SUBST(LVM_MINOR)
+AC_SUBST(LVM_PATCHLEVEL)
+AC_SUBST(LVM_RELEASE)
+AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
 AC_SUBST(MSGFMT)
 AC_SUBST(OWNER)
@@ -798,6 +812,7 @@ lib/format1/Makefile
 lib/format_pool/Makefile
 lib/locking/Makefile
 lib/mirror/Makefile
+lib/misc/lvm-version.h
 lib/snapshot/Makefile
 libdm/Makefile
 libdm/libdevmapper.pc
@@ -808,7 +823,6 @@ scripts/Makefile
 test/Makefile
 test/api/Makefile
 tools/Makefile
-tools/version.h
 ])
 AC_OUTPUT
 
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index faa1755..29df425 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -49,7 +49,7 @@
 #include "clvmd-comms.h"
 #include "lvm-functions.h"
 #include "clvm.h"
-#include "version.h"
+#include "lvm-version.h"
 #include "clvmd.h"
 #include "refresh_clvmd.h"
 #include "lvm-logging.h"
diff --git a/include/.symlinks b/include/.symlinks
index 1a4bd93..97acfed 100644
--- a/include/.symlinks
+++ b/include/.symlinks
@@ -47,6 +47,7 @@
 ../lib/misc/lvm-file.h
 ../lib/misc/lvm-globals.h
 ../lib/misc/lvm-string.h
+../lib/misc/lvm-version.h
 ../lib/misc/lvm-wrappers.h
 ../lib/misc/sharedlib.h
 ../lib/report/report.h
@@ -57,4 +58,3 @@
 ../libdm/misc/dmlib.h
 ../libdm/misc/kdev_t.h
 ../po/pogen.h
-../tools/version.h
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 6f16143..604138c 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -20,7 +20,7 @@
 #include "lvm-string.h"
 #include "segtype.h"
 #include "text_export.h"
-#include "version.h"
+#include "lvm-version.h"
 
 #include <stdarg.h>
 #include <time.h>
diff --git a/lib/misc/lvm-version.h.in b/lib/misc/lvm-version.h.in
new file mode 100644
index 0000000..0c59852
--- /dev/null
+++ b/lib/misc/lvm-version.h.in
@@ -0,0 +1,29 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
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
+#ifndef _LVM_VERSION_H
+/**
+ * The LVM version number
+ *
+ * LVM_MAJOR.LVM_MINOR.LVM_PATCHLEVEL[-LVM_RELEASE]
+ */
+
+#define LVM_VERSION @LVM_VERSION@
+#define LVM_MAJOR @LVM_MAJOR@
+#define LVM_MINOR @LVM_MINOR@
+#define LVM_PATCHLEVEL @LVM_PATCHLEVEL@
+#define LVM_RELEASE @LVM_RELEASE@
+#define LVM_RELEASE_DATE @LVM_RELEASE_DATE@
+#endif
diff --git a/make.tmpl.in b/make.tmpl.in
index b269adf..ea2432c 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -1,7 +1,7 @@
 # @configure_input@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004, 2008 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004, 2009 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -244,7 +244,7 @@ distclean: $(SUBDIRS.distclean)
 	      $(SOURCES:%.c=%.gcda) $(LDDEPS) \
 	      config.cache config.log config.status \
 	      Makefile make.tmpl core \
-	      version.h lvm2.po
+	      lvm-version.h lvm2.po
 
 .export.sym: .exported_symbols
 	set -e; (echo "Base {"; echo "	global:"; \
diff --git a/test/t-000-basic.sh b/test/t-000-basic.sh
index ed311de..b1d637d 100755
--- a/test/t-000-basic.sh
+++ b/test/t-000-basic.sh
@@ -1,4 +1,4 @@
-# Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2009 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -12,7 +12,7 @@
 
 lvm version
 
-v=$abs_top_srcdir/tools/version.h
+v=$abs_top_srcdir/lib/misc/lvm-version.h
 sed -n "/#define LVM_VERSION ./s///p" "$v" | sed "s/ .*//" > expected
 
 lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 1a90c92..5cde0c4 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,7 +17,7 @@
 #include "lvm2cmdline.h"
 #include "label.h"
 #include "memlock.h"
-#include "version.h"
+#include "lvm-version.h"
 
 #include "lvm2cmd.h"
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index cb1bfc6..a96ef3c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -16,7 +16,7 @@
 #include "tools.h"
 #include "lvm2cmdline.h"
 #include "label.h"
-#include "version.h"
+#include "lvm-version.h"
 
 #include "stub.h"
 #include "lvm2cmd.h"
diff --git a/tools/version.h.in b/tools/version.h.in
deleted file mode 100644
index a122792..0000000
--- a/tools/version.h.in
+++ /dev/null
@@ -1,3 +0,0 @@
-#ifndef _LVM_VERSION_H
-#define LVM_VERSION @LVM_VERSION@
-#endif
-- 
1.6.1.3


