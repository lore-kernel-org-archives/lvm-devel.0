From: Jim Meyering <jim@meyering.net>
Date: Wed, 03 Oct 2007 16:59:51 +0200
Subject: Re: LVM2/tools/fsadm Makefile.in
In-Reply-To: <20071003095830.GH18444@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Wed, 3 Oct 2007 10:58:30 +0100")
References: <20071003094658.15588.qmail@sourceware.org>
	<20071003095830.GH18444@agk.fab.redhat.com>
Message-ID: <87fy0s2qhk.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> On Wed, Oct 03, 2007 at 09:46:58AM -0000, meyering at sourceware.org wrote:
>> 	* tools/fsadm/Makefile.in (LVMLIBS): Define.
>> 	(fsadm): Link with $(LVMLIBS).
>
>>  fsadm: $(OBJECTS)
>> -	$(CC) -o $@ $(CFLAGS) $(OBJECTS) -rdynamic
>> +	$(CC) -o $@ $(CFLAGS) $(OBJECTS) $(LDFLAGS) $(LVMLIBS) -rdynamic
>
> fsadm is meant to be independent of LVM2 so should not be using LVMLIBS.
> What should be done to deal with this?

Unless I hear otherwise, I'll fix it by reverting the
Makefile.in change and applying this one instead:
-------------

Fix fsadm build failure a different way, so that fsadm doesn't use -llvm.

* lib/misc/util.c (last_path_component): Move definition to ...
* lib/misc/last-path-component.h (last_path_component): ...here.
New file.  Make the function "static inline".
* include/.symlinks: Add last-path-component.h.
* lib/misc/util.h (last_path_component): Remove declaration.
* tools/fsadm/fsadm.c: Include "last-path-component.h".
* tools/lvmcmdline.c: Likewise.

Signed-off-by: Jim Meyering <meyering@redhat.com>
---
 include/.symlinks              |    1 +
 lib/misc/last-path-component.h |   27 +++++++++++++++++++++++++++
 lib/misc/util.c                |    7 +------
 lib/misc/util.h                |    2 --
 tools/fsadm/fsadm.c            |    1 +
 tools/lvmcmdline.c             |    1 +
 6 files changed, 31 insertions(+), 8 deletions(-)
 create mode 100644 lib/misc/last-path-component.h

diff --git a/include/.symlinks b/include/.symlinks
index a127e2c..7c54d9e 100644
--- a/include/.symlinks
+++ b/include/.symlinks
@@ -39,6 +39,7 @@
 ../lib/misc/crc.h
 ../lib/misc/intl.h
 ../lib/misc/util.h
+../lib/misc/last-path-component.h
 ../lib/misc/lib.h
 ../lib/misc/lvm-exec.h
 ../lib/misc/lvm-file.h
diff --git a/lib/misc/last-path-component.h b/lib/misc/last-path-component.h
new file mode 100644
index 0000000..69a1ce0
--- /dev/null
+++ b/lib/misc/last-path-component.h
@@ -0,0 +1,27 @@
+/*
+ * Copyright (C) 2007 Red Hat, Inc. All rights reserved.
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
+/*
+ * Return the address of the last file name component of NAME.
+ * If NAME ends in a slash, return the empty string.
+ */
+
+#include <string.h>
+
+static inline char *last_path_component(char const *name)
+{
+	char const *slash = strrchr (name, '/');
+	char const *res = slash ? slash + 1 : name;
+	return (char *) res;
+}
diff --git a/lib/misc/util.c b/lib/misc/util.c
index b134c5e..75c7afa 100644
--- a/lib/misc/util.c
+++ b/lib/misc/util.c
@@ -19,9 +19,4 @@

 #include "lib.h"

-char *last_path_component(char const *name)
-{
-	char const *slash = strrchr (name, '/');
-	char const *res = slash ? slash + 1 : name;
-	return (char *) res;
-}
+/* empty for now.  */
diff --git a/lib/misc/util.h b/lib/misc/util.h
index 694864c..5e5677d 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -25,6 +25,4 @@
 		     (void) (&_a == &_b); \
 		     _a > _b ? _a : _b; })

-char *last_path_component(char const *name);
-
 #endif
diff --git a/tools/fsadm/fsadm.c b/tools/fsadm/fsadm.c
index 8621164..619228a 100644
--- a/tools/fsadm/fsadm.c
+++ b/tools/fsadm/fsadm.c
@@ -39,6 +39,7 @@
 #include <sys/vfs.h>

 #include "util.h"
+#include "last-path-component.h"

 #define log_error(str, x...) fprintf(stderr, "%s(%u):  " str "\n", __FILE__, __LINE__, x)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 35a1266..94575f3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -20,6 +20,7 @@

 #include "stub.h"
 #include "lvm2cmd.h"
+#include "last-path-component.h"

 #include <signal.h>
 #include <syslog.h>
--
1.5.3.3.131.g34c6d


