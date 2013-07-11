From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 11 Jul 2013 07:48:30 +0000 (UTC)
Subject: master - lvm2api: Make the vg_list_* functions work with lvmetad (+ test).
Message-ID: <20130711074830.825DE60D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e4a3dd9cb73e71df5f782f844da4cf461d76de6
Commit:        8e4a3dd9cb73e71df5f782f844da4cf461d76de6
Parent:        618d13705c233b8ab7290653228b17ee111479f4
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Jul 11 08:01:04 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Jul 11 09:38:46 2013 +0200

lvm2api: Make the vg_list_* functions work with lvmetad (+ test).

---
 liblvm/lvm_vg.c      |    3 ++
 test/api/Makefile.in |    2 +
 test/api/vglist.c    |   74 ++++++++++++++++++++++++++++++++++++++++++++++++++
 test/api/vglist.sh   |   15 ++++++++++
 4 files changed, 94 insertions(+), 0 deletions(-)

diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index 4a5fdf5..35c7eea 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -18,6 +18,7 @@
 #include "archiver.h"
 #include "locking.h"
 #include "lvmcache.h"
+#include "lvmetad.h"
 #include "lvm_misc.h"
 #include "lvm2app.h"
 
@@ -361,11 +362,13 @@ int lvm_vg_set_property(const vg_t vg, const char *name,
 
 struct dm_list *lvm_list_vg_names(lvm_t libh)
 {
+	lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh);
 	return get_vgnames((struct cmd_context *)libh, 0);
 }
 
 struct dm_list *lvm_list_vg_uuids(lvm_t libh)
 {
+	lvmetad_vg_list_to_lvmcache((struct cmd_context *)libh);
 	return get_vgids((struct cmd_context *)libh, 0);
 }
 
diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index 7ad6743..9a43548 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -22,6 +22,7 @@ SOURCES = test.c
 
 TARGETS += \
 	lvtest.t \
+	vglist.t \
 	percent.t \
 	pe_start.t \
 	thin_percent.t \
@@ -29,6 +30,7 @@ TARGETS += \
 
 SOURCES2 = \
 	lvtest.c \
+	vglist.c \
 	percent.c \
 	pe_start.c \
 	thin_percent.c \
diff --git a/test/api/vglist.c b/test/api/vglist.c
new file mode 100644
index 0000000..5939340
--- /dev/null
+++ b/test/api/vglist.c
@@ -0,0 +1,74 @@
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
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
+#include <stdio.h>
+#include <unistd.h>
+#include <inttypes.h>
+#include <assert.h>
+
+#include "lvm2app.h"
+
+lvm_t handle;
+vg_t vg;
+
+static void start() {
+	handle = lvm_init(NULL);
+	if (!handle) {
+		fprintf(stderr, "Unable to lvm_init\n");
+		abort();
+	}
+}
+
+static void done(int ok) {
+	if (handle && lvm_errno(handle)) {
+		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
+		ok = 0;
+	}
+	if (handle)
+		lvm_quit(handle);
+	if (!ok)
+		abort();
+}
+
+int main(int argc, char *argv[])
+{
+	int status;
+
+	if (argc != 3)
+		abort();
+
+	lvm_str_list_t *str;
+
+	int i = 0;
+
+	start();
+	struct dm_list *vgnames = lvm_list_vg_names(handle);
+	dm_list_iterate_items(str, vgnames) {
+		assert(++i <= 1);
+		assert(!strcmp(str->str, argv[1]));
+	}
+	assert(i == 1);
+	done(1);
+
+	i = 0;
+	start();
+	struct dm_list *vgids = lvm_list_vg_uuids(handle);
+	dm_list_iterate_items(str, vgids) {
+		assert(++i <= 1);
+		assert(!strcmp(str->str, argv[2]));
+	}
+	assert(i == 1);
+	done(1);
+	return 0;
+}
diff --git a/test/api/vglist.sh b/test/api/vglist.sh
new file mode 100644
index 0000000..275c9d2
--- /dev/null
+++ b/test/api/vglist.sh
@@ -0,0 +1,15 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 2
+aux apitest vglist $vg `get vg_field $vg vg_uuid | sed -e s,-,,g`


