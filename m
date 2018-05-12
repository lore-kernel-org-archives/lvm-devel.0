From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:54 -0400
Subject: master - build: rename device-mapper to device_mapper
Message-ID: <201805121626.w4CGQsBP008401@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79b296139947c43aaf9cc70ae8caf66c1f89f4a6
Commit:        79b296139947c43aaf9cc70ae8caf66c1f89f4a6
Parent:        e2c766d37e20231db48e55edb5e23973df590569
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 11 18:55:55 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 18:18:23 2018 +0200

build: rename device-mapper to device_mapper

As Makefiles already do use target with name 'device-mapper'
rename this new device-mapper dir to non-conflicting name.
We also seem to already use '_' in other dir names.

Also rename device_mapper/Makefile to source for generating Makefile.in
so we can use it for build in other source dirs properly.
---
 Makefile.in                |    8 +-
 configure                  |    3 +-
 configure.ac               |    1 +
 device-mapper/Makefile     |   20 ----
 device-mapper/vdo/status.c |  248 --------------------------------------------
 device-mapper/vdo/target.h |   68 ------------
 device_mapper/Makefile.in  |   23 ++++
 device_mapper/vdo/status.c |  248 ++++++++++++++++++++++++++++++++++++++++++++
 device_mapper/vdo/target.h |   68 ++++++++++++
 test/unit/Makefile.in      |    2 +-
 test/unit/vdo_t.c          |    2 +-
 11 files changed, 348 insertions(+), 343 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index b0bceb0..c2d5122 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -18,7 +18,7 @@ top_builddir = @top_builddir@
 abs_top_builddir = @abs_top_builddir@
 abs_top_srcdir = @abs_top_srcdir@
 
-SUBDIRS = conf daemons include lib libdaemon libdm man scripts tools
+SUBDIRS = conf daemons include lib libdaemon libdm man scripts device_mapper tools
 
 ifeq ("@UDEV_RULES@", "yes")
   SUBDIRS += udev
@@ -43,7 +43,7 @@ endif
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS = conf include man test scripts \
     libdaemon lib tools daemons libdm \
-    udev po liblvm python
+    udev po liblvm python device_mapper
 tools.distclean: test.distclean
 endif
 DISTCLEAN_DIRS += lcov_reports*
@@ -61,7 +61,7 @@ po: tools daemons
 man: tools
 all_man: tools
 scripts: liblvm libdm
-test: lib
+test: tools daemons
 unit-test: lib
 run-unit-test: unit-test
 
@@ -99,7 +99,7 @@ endif
 DISTCLEAN_TARGETS += cscope.out
 CLEAN_DIRS += autom4te.cache
 
-check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock unit-test run-unit-test: all
+check check_system check_cluster check_local check_lvmetad check_lvmpolld check_lvmlockd_test check_lvmlockd_dlm check_lvmlockd_sanlock unit-test run-unit-test: test
 	$(MAKE) -C test $(@)
 
 conf.generate man.generate: tools
diff --git a/configure b/configure
index e874932..ed00809 100755
--- a/configure
+++ b/configure
@@ -15559,7 +15559,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/
 Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lv
 m2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/lvmdb.py daemons/lvmdbusd/lvm_shell_proxy.py daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile device_mapper/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/locking/Makefile include/lvm-version.h libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/
 libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_
 init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16276,6 +16276,7 @@ do
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "daemons/lvmpolld/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmpolld/Makefile" ;;
     "daemons/lvmlockd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmlockd/Makefile" ;;
+    "device_mapper/Makefile") CONFIG_FILES="$CONFIG_FILES device_mapper/Makefile" ;;
     "conf/Makefile") CONFIG_FILES="$CONFIG_FILES conf/Makefile" ;;
     "conf/example.conf") CONFIG_FILES="$CONFIG_FILES conf/example.conf" ;;
     "conf/lvmlocal.conf") CONFIG_FILES="$CONFIG_FILES conf/lvmlocal.conf" ;;
diff --git a/configure.ac b/configure.ac
index 5738b05..41e612f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -2108,6 +2108,7 @@ daemons/lvmdbusd/path.py
 daemons/lvmetad/Makefile
 daemons/lvmpolld/Makefile
 daemons/lvmlockd/Makefile
+device_mapper/Makefile
 conf/Makefile
 conf/example.conf
 conf/lvmlocal.conf
diff --git a/device-mapper/Makefile b/device-mapper/Makefile
deleted file mode 100644
index 76e19f0..0000000
--- a/device-mapper/Makefile
+++ /dev/null
@@ -1,20 +0,0 @@
-# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
-#
-# This file is part of LVM2.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program; if not, write to the Free Software Foundation,
-# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
-
-DM_SOURCE=\
-	device-mapper/vdo/status.c
-
-DM_DEPENDS=$(subst .c,.d,$(DM_SOURCE))
-DM_OBJECTS=$(DM_SOURCE:%.c=%.o)
-CLEAN_TARGETS+=$(DM_DEPENDS) $(DM_OBJECTS)
-
--include $(DM_DEPENDS)
diff --git a/device-mapper/vdo/status.c b/device-mapper/vdo/status.c
deleted file mode 100644
index 157111f..0000000
--- a/device-mapper/vdo/status.c
+++ /dev/null
@@ -1,248 +0,0 @@
-#include "target.h"
-
-// For DM_ARRAY_SIZE!
-#include "libdevmapper.h"
-
-#include <ctype.h>
-#include <stdlib.h>
-#include <string.h>
-
-//----------------------------------------------------------------
-
-static char *_tok_cpy(const char *b, const char *e)
-{
-	char *new = malloc((e - b) + 1);
-	char *ptr = new;
-
-	if (new) {
-        	while (b != e)
-                	*ptr++ = *b++;
-                *ptr = '\0';
-	}
-
-	return new;
-}
-
-static bool _tok_eq(const char *b, const char *e, const char *str)
-{
-	while (b != e) {
-		if (!*str || *b != *str)
-        		return false;
-
-        	b++;
-        	str++;
-	}
-
-	return !*str;
-}
-
-static bool _parse_operating_mode(const char *b, const char *e, void *context)
-{
-	static struct {
-        	const char *str;
-        	enum vdo_operating_mode mode;
-	} _table[] = {
-        	{"recovering", VDO_MODE_RECOVERING},
-        	{"read-only", VDO_MODE_READ_ONLY},
-        	{"normal", VDO_MODE_NORMAL}
-	};
-
-        enum vdo_operating_mode *r = context;
-	unsigned i;
-	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
-        	if (_tok_eq(b, e, _table[i].str)) {
-                	*r = _table[i].mode;
-                	return true;
-        	}
-	}
-
-	return false;
-}
-
-static bool _parse_compression_state(const char *b, const char *e, void *context)
-{
-	static struct {
-        	const char *str;
-        	enum vdo_compression_state state;
-	} _table[] = {
-        	{"online", VDO_COMPRESSION_ONLINE},
-        	{"offline", VDO_COMPRESSION_OFFLINE}
-	};
-
-        enum vdo_compression_state *r = context;
-	unsigned i;
-	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
-        	if (_tok_eq(b, e, _table[i].str)) {
-                	*r = _table[i].state;
-                	return true;
-        	}
-	}
-
-	return false;
-}
-
-static bool _parse_recovering(const char *b, const char *e, void *context)
-{
-        bool *r = context;
-
-	if (_tok_eq(b, e, "recovering"))
-		*r = true;
-
-	else if (_tok_eq(b, e, "-"))
-        	*r = false;
-
-        else
-        	return false;
-
-        return true;
-}
-
-static bool _parse_index_state(const char *b, const char *e, void *context)
-{
-        static struct {
-                const char *str;
-                enum vdo_index_state state;
-        } _table[] = {
-                {"error", VDO_INDEX_ERROR},
-                {"closed", VDO_INDEX_CLOSED},
-                {"opening", VDO_INDEX_OPENING},
-                {"closing", VDO_INDEX_CLOSING},
-                {"offline", VDO_INDEX_OFFLINE},
-                {"online", VDO_INDEX_ONLINE},
-                {"unknown", VDO_INDEX_UNKNOWN}
-        };
-
-        enum vdo_index_state *r = context;
-	unsigned i;
-	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
-        	if (_tok_eq(b, e, _table[i].str)) {
-                	*r = _table[i].state;
-                	return true;
-        	}
-	}
-
-        return false;
-}
-
-static bool _parse_uint64(const char *b, const char *e, void *context)
-{
-        uint64_t *r = context, n;
-
-	n = 0;
-	while (b != e) {
-        	if (!isdigit(*b))
-                	return false;
-
-		n = (n * 10) + (*b - '0');
-		b++;
-	}
-
-	*r = n;
-	return true;
-}
-
-static const char *_eat_space(const char *b, const char *e)
-{
-	while (b != e && isspace(*b))
-        	b++;
-
-        return b;
-}
-
-static const char *_next_tok(const char *b, const char *e)
-{
-        const char *te = b;
-	while (te != e && !isspace(*te))
-        	te++;
-
-        return te == b ? NULL : te;
-}
-
-static void _set_error(struct vdo_status_parse_result *result, const char *fmt, ...)
-	__attribute__ ((format(printf, 2, 3)));
-
-static void _set_error(struct vdo_status_parse_result *result, const char *fmt, ...)
-{
-        va_list ap;
-
-        va_start(ap, fmt);
-	vsnprintf(result->error, sizeof(result->error), fmt, ap);
-        va_end(ap);
-}
-
-static bool _parse_field(const char **b, const char *e,
-                         bool (*p_fn)(const char *, const char *, void *),
-                         void *field, const char *field_name,
-                         struct vdo_status_parse_result *result)
-{
-        const char *te;
-
-        te = _next_tok(*b, e);
-        if (!te) {
-                _set_error(result, "couldn't get token for '%s'", field_name);
-                return false;
-        }
-
-        if (!p_fn(*b, te, field)) {
-                _set_error(result, "couldn't parse '%s'", field_name);
-                return false;
-        }
-
-	*b = _eat_space(te, e);
-        return true;
-
-}
-
-bool vdo_status_parse(const char *input, struct vdo_status_parse_result *result)
-{
-	const char *b = b = input;
-	const char *e = input + strlen(input);
-	const char *te;
-	struct vdo_status *s = malloc(sizeof(*s));
-
-	if (!s) {
-        	_set_error(result, "out of memory");
-        	return false;
-	}
-
-	b = _eat_space(b, e);
-	te = _next_tok(b, e);
-	if (!te) {
-        	_set_error(result, "couldn't get token for device");
-        	free(s);
-        	return false;
-	}
-
-	s->device = _tok_cpy(b, te);
-	if (!s->device) {
-		_set_error(result, "out of memory");
-		free(s);
-		return false;
-	}
-
-	b = _eat_space(te, e);
-
-#define XX(p, f, fn) if (!_parse_field(&b, e, p, f, fn, result)) goto bad;
-	XX(_parse_operating_mode, &s->operating_mode, "operating mode");
-	XX(_parse_recovering, &s->recovering, "recovering");
-	XX(_parse_index_state, &s->index_state, "index state");
-	XX(_parse_compression_state, &s->compression_state, "compression state");
-	XX(_parse_uint64, &s->used_blocks, "used blocks");
-	XX(_parse_uint64, &s->total_blocks, "total blocks");
-#undef XX
-
-	if (b != e) {
-		_set_error(result, "too many tokens");
-		goto bad;
-	}
-
-        result->status = s;
-        return true;
-
-bad:
-	free(s->device);
-	free(s);
-	return false;
-}
-
-//----------------------------------------------------------------
diff --git a/device-mapper/vdo/target.h b/device-mapper/vdo/target.h
deleted file mode 100644
index 3137e2c..0000000
--- a/device-mapper/vdo/target.h
+++ /dev/null
@@ -1,68 +0,0 @@
-/*
- * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
- *
- * This file is part of the device-mapper userspace tools.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
- */
-
-#ifndef DEVICE_MAPPER_VDO_TARGET_H
-#define DEVICE_MAPPER_VDO_TARGET_H
-
-#include <stdbool.h>
-#include <stdint.h>
-
-//----------------------------------------------------------------
-
-enum vdo_operating_mode {
-	VDO_MODE_RECOVERING,
-	VDO_MODE_READ_ONLY,
-	VDO_MODE_NORMAL
-};
-
-enum vdo_compression_state {
-	VDO_COMPRESSION_ONLINE,
-	VDO_COMPRESSION_OFFLINE
-};
-
-enum vdo_index_state {
-	VDO_INDEX_ERROR,
-	VDO_INDEX_CLOSED,
-	VDO_INDEX_OPENING,
-	VDO_INDEX_CLOSING,
-	VDO_INDEX_OFFLINE,
-	VDO_INDEX_ONLINE,
-	VDO_INDEX_UNKNOWN
-};
-
-struct vdo_status {
-	char *device;
-	enum vdo_operating_mode operating_mode;
-	bool recovering;
-	enum vdo_index_state index_state;
-	enum vdo_compression_state compression_state;
-	uint64_t used_blocks;
-	uint64_t total_blocks;
-};
-
-void vdo_status_destroy(struct vdo_status *s);
-
-#define VDO_MAX_ERROR 256
-
-struct vdo_status_parse_result {
-	char error[VDO_MAX_ERROR];
-	struct vdo_status *status;
-};
-
-// Parses the status line from the kernel target.
-bool vdo_status_parse(const char *input, struct vdo_status_parse_result *result);
-
-//----------------------------------------------------------------
-
-#endif
diff --git a/device_mapper/Makefile.in b/device_mapper/Makefile.in
new file mode 100644
index 0000000..8d914ff
--- /dev/null
+++ b/device_mapper/Makefile.in
@@ -0,0 +1,23 @@
+# Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+top_builddir = @top_builddir@
+
+SOURCES=\
+	vdo/status.c
+
+include $(top_builddir)/make.tmpl
+
+LIB_NAME = libdevicemapper
+LIB_STATIC = $(LIB_NAME).a
diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
new file mode 100644
index 0000000..157111f
--- /dev/null
+++ b/device_mapper/vdo/status.c
@@ -0,0 +1,248 @@
+#include "target.h"
+
+// For DM_ARRAY_SIZE!
+#include "libdevmapper.h"
+
+#include <ctype.h>
+#include <stdlib.h>
+#include <string.h>
+
+//----------------------------------------------------------------
+
+static char *_tok_cpy(const char *b, const char *e)
+{
+	char *new = malloc((e - b) + 1);
+	char *ptr = new;
+
+	if (new) {
+        	while (b != e)
+                	*ptr++ = *b++;
+                *ptr = '\0';
+	}
+
+	return new;
+}
+
+static bool _tok_eq(const char *b, const char *e, const char *str)
+{
+	while (b != e) {
+		if (!*str || *b != *str)
+        		return false;
+
+        	b++;
+        	str++;
+	}
+
+	return !*str;
+}
+
+static bool _parse_operating_mode(const char *b, const char *e, void *context)
+{
+	static struct {
+        	const char *str;
+        	enum vdo_operating_mode mode;
+	} _table[] = {
+        	{"recovering", VDO_MODE_RECOVERING},
+        	{"read-only", VDO_MODE_READ_ONLY},
+        	{"normal", VDO_MODE_NORMAL}
+	};
+
+        enum vdo_operating_mode *r = context;
+	unsigned i;
+	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
+        	if (_tok_eq(b, e, _table[i].str)) {
+                	*r = _table[i].mode;
+                	return true;
+        	}
+	}
+
+	return false;
+}
+
+static bool _parse_compression_state(const char *b, const char *e, void *context)
+{
+	static struct {
+        	const char *str;
+        	enum vdo_compression_state state;
+	} _table[] = {
+        	{"online", VDO_COMPRESSION_ONLINE},
+        	{"offline", VDO_COMPRESSION_OFFLINE}
+	};
+
+        enum vdo_compression_state *r = context;
+	unsigned i;
+	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
+        	if (_tok_eq(b, e, _table[i].str)) {
+                	*r = _table[i].state;
+                	return true;
+        	}
+	}
+
+	return false;
+}
+
+static bool _parse_recovering(const char *b, const char *e, void *context)
+{
+        bool *r = context;
+
+	if (_tok_eq(b, e, "recovering"))
+		*r = true;
+
+	else if (_tok_eq(b, e, "-"))
+        	*r = false;
+
+        else
+        	return false;
+
+        return true;
+}
+
+static bool _parse_index_state(const char *b, const char *e, void *context)
+{
+        static struct {
+                const char *str;
+                enum vdo_index_state state;
+        } _table[] = {
+                {"error", VDO_INDEX_ERROR},
+                {"closed", VDO_INDEX_CLOSED},
+                {"opening", VDO_INDEX_OPENING},
+                {"closing", VDO_INDEX_CLOSING},
+                {"offline", VDO_INDEX_OFFLINE},
+                {"online", VDO_INDEX_ONLINE},
+                {"unknown", VDO_INDEX_UNKNOWN}
+        };
+
+        enum vdo_index_state *r = context;
+	unsigned i;
+	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
+        	if (_tok_eq(b, e, _table[i].str)) {
+                	*r = _table[i].state;
+                	return true;
+        	}
+	}
+
+        return false;
+}
+
+static bool _parse_uint64(const char *b, const char *e, void *context)
+{
+        uint64_t *r = context, n;
+
+	n = 0;
+	while (b != e) {
+        	if (!isdigit(*b))
+                	return false;
+
+		n = (n * 10) + (*b - '0');
+		b++;
+	}
+
+	*r = n;
+	return true;
+}
+
+static const char *_eat_space(const char *b, const char *e)
+{
+	while (b != e && isspace(*b))
+        	b++;
+
+        return b;
+}
+
+static const char *_next_tok(const char *b, const char *e)
+{
+        const char *te = b;
+	while (te != e && !isspace(*te))
+        	te++;
+
+        return te == b ? NULL : te;
+}
+
+static void _set_error(struct vdo_status_parse_result *result, const char *fmt, ...)
+	__attribute__ ((format(printf, 2, 3)));
+
+static void _set_error(struct vdo_status_parse_result *result, const char *fmt, ...)
+{
+        va_list ap;
+
+        va_start(ap, fmt);
+	vsnprintf(result->error, sizeof(result->error), fmt, ap);
+        va_end(ap);
+}
+
+static bool _parse_field(const char **b, const char *e,
+                         bool (*p_fn)(const char *, const char *, void *),
+                         void *field, const char *field_name,
+                         struct vdo_status_parse_result *result)
+{
+        const char *te;
+
+        te = _next_tok(*b, e);
+        if (!te) {
+                _set_error(result, "couldn't get token for '%s'", field_name);
+                return false;
+        }
+
+        if (!p_fn(*b, te, field)) {
+                _set_error(result, "couldn't parse '%s'", field_name);
+                return false;
+        }
+
+	*b = _eat_space(te, e);
+        return true;
+
+}
+
+bool vdo_status_parse(const char *input, struct vdo_status_parse_result *result)
+{
+	const char *b = b = input;
+	const char *e = input + strlen(input);
+	const char *te;
+	struct vdo_status *s = malloc(sizeof(*s));
+
+	if (!s) {
+        	_set_error(result, "out of memory");
+        	return false;
+	}
+
+	b = _eat_space(b, e);
+	te = _next_tok(b, e);
+	if (!te) {
+        	_set_error(result, "couldn't get token for device");
+        	free(s);
+        	return false;
+	}
+
+	s->device = _tok_cpy(b, te);
+	if (!s->device) {
+		_set_error(result, "out of memory");
+		free(s);
+		return false;
+	}
+
+	b = _eat_space(te, e);
+
+#define XX(p, f, fn) if (!_parse_field(&b, e, p, f, fn, result)) goto bad;
+	XX(_parse_operating_mode, &s->operating_mode, "operating mode");
+	XX(_parse_recovering, &s->recovering, "recovering");
+	XX(_parse_index_state, &s->index_state, "index state");
+	XX(_parse_compression_state, &s->compression_state, "compression state");
+	XX(_parse_uint64, &s->used_blocks, "used blocks");
+	XX(_parse_uint64, &s->total_blocks, "total blocks");
+#undef XX
+
+	if (b != e) {
+		_set_error(result, "too many tokens");
+		goto bad;
+	}
+
+        result->status = s;
+        return true;
+
+bad:
+	free(s->device);
+	free(s);
+	return false;
+}
+
+//----------------------------------------------------------------
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
new file mode 100644
index 0000000..3137e2c
--- /dev/null
+++ b/device_mapper/vdo/target.h
@@ -0,0 +1,68 @@
+/*
+ * Copyright (C) 2018 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the device-mapper userspace tools.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#ifndef DEVICE_MAPPER_VDO_TARGET_H
+#define DEVICE_MAPPER_VDO_TARGET_H
+
+#include <stdbool.h>
+#include <stdint.h>
+
+//----------------------------------------------------------------
+
+enum vdo_operating_mode {
+	VDO_MODE_RECOVERING,
+	VDO_MODE_READ_ONLY,
+	VDO_MODE_NORMAL
+};
+
+enum vdo_compression_state {
+	VDO_COMPRESSION_ONLINE,
+	VDO_COMPRESSION_OFFLINE
+};
+
+enum vdo_index_state {
+	VDO_INDEX_ERROR,
+	VDO_INDEX_CLOSED,
+	VDO_INDEX_OPENING,
+	VDO_INDEX_CLOSING,
+	VDO_INDEX_OFFLINE,
+	VDO_INDEX_ONLINE,
+	VDO_INDEX_UNKNOWN
+};
+
+struct vdo_status {
+	char *device;
+	enum vdo_operating_mode operating_mode;
+	bool recovering;
+	enum vdo_index_state index_state;
+	enum vdo_compression_state compression_state;
+	uint64_t used_blocks;
+	uint64_t total_blocks;
+};
+
+void vdo_status_destroy(struct vdo_status *s);
+
+#define VDO_MAX_ERROR 256
+
+struct vdo_status_parse_result {
+	char error[VDO_MAX_ERROR];
+	struct vdo_status *status;
+};
+
+// Parses the status line from the kernel target.
+bool vdo_status_parse(const char *input, struct vdo_status_parse_result *result);
+
+//----------------------------------------------------------------
+
+#endif
diff --git a/test/unit/Makefile.in b/test/unit/Makefile.in
index 017afaa..cb92fb1 100644
--- a/test/unit/Makefile.in
+++ b/test/unit/Makefile.in
@@ -40,7 +40,7 @@ TARGETS += unit-test
 # via usage of vpath
 vpath %.c \
 	$(top_srcdir)/base/data-struct \
-	$(top_srcdir)/device-mapper/vdo
+	$(top_srcdir)/device_mapper/vdo
 
 include $(top_builddir)/make.tmpl
 
diff --git a/test/unit/vdo_t.c b/test/unit/vdo_t.c
index 21ecd1a..9c41887 100644
--- a/test/unit/vdo_t.c
+++ b/test/unit/vdo_t.c
@@ -12,7 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "device-mapper/vdo/target.h"
+#include "device_mapper/vdo/target.h"
 #include "framework.h"
 #include "units.h"
 


