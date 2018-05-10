From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 08:05:26 -0400
Subject: master - vdo: Code drop for status parsing.
Message-ID: <201805101205.w4AC5Q3P032474@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52ebad31bae64edd92244a244c8928fb2171c209
Commit:        52ebad31bae64edd92244a244c8928fb2171c209
Parent:        9384b2b5c59e9bca8c2054f76b62155a64c51c38
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Apr 30 16:16:58 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 16:16:58 2018 +0100

vdo: Code drop for status parsing.

Doesn't even compile yet.  Squash this patch.
---
 Makefile.in                |    2 +
 device-mapper/Makefile     |   20 ++++
 device-mapper/vdo/status.c |  207 ++++++++++++++++++++++++++++++++++++++++++++
 device-mapper/vdo/target.h |   69 +++++++++++++++
 4 files changed, 298 insertions(+), 0 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 916f54d..1b16945 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -214,6 +214,8 @@ ifeq ("$(TESTING)", "yes")
 include test/unit/Makefile
 endif
 
+include device-mapper/Makefile
+
 ifneq ($(shell which ctags),)
 .PHONY: tags
 tags:
diff --git a/device-mapper/Makefile b/device-mapper/Makefile
new file mode 100644
index 0000000..76e19f0
--- /dev/null
+++ b/device-mapper/Makefile
@@ -0,0 +1,20 @@
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
+DM_SOURCE=\
+	device-mapper/vdo/status.c
+
+DM_DEPENDS=$(subst .c,.d,$(DM_SOURCE))
+DM_OBJECTS=$(DM_SOURCE:%.c=%.o)
+CLEAN_TARGETS+=$(DM_DEPENDS) $(DM_OBJECTS)
+
+-include $(DM_DEPENDS)
diff --git a/device-mapper/vdo/status.c b/device-mapper/vdo/status.c
new file mode 100644
index 0000000..ccebc83
--- /dev/null
+++ b/device-mapper/vdo/status.c
@@ -0,0 +1,207 @@
+#include "target.h"
+
+// For DM_ARRAY_SIZE!
+#include "libdevmapper.h"
+
+#include <stdlib.h>
+
+//----------------------------------------------------------------
+
+static const char *_tok_cpy(const char *b, const char *e, const char *str)
+{
+	char *new = malloc((e - b) + 1);
+	char *ptr = new;
+
+	if (new)
+        	while (b != e)
+                	*ptr++ = *b++;
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
+static bool _parse_operating_mode(const char *b, const char *e,
+                                  enum vdo_operating_mode *r)
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
+static bool _parse_compression_state(const char *b, const char *e,
+                                     enum vdo_compression_state *r)
+{
+	static struct {
+        	const char *str;
+        	enum vdo_compression_state state;
+	} _table[] = {
+        	{"online", VDO_COMPRESSION_ONLINE},
+        	{"offline", VDO_COMPRESSION_OFFLINE}
+	};
+
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
+static bool _parse_recovering(const char *b, const char *e, bool *r)
+{
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
+static bool _parse_index_state(const char *b, const char *e,
+                               enum vdo_index_state *r)
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
+	while (b != e && !isspace(*b))
+        	b++;
+
+        return b == e ? NULL : b;
+}
+
+static bool _parse_field(const char **b, const char *e,
+                         bool (*p_fn)(const char *, const char *, void *)
+                         void *field, const char *field_name,
+                         struct parse_result *result)
+{
+        const char *te;
+
+        te = _next_tok(*b, e);
+        if (!te) {
+                snprintf(result->error, sizeof(result->error),
+                         "couldn't get token for '%s'", field_name);
+                return false;
+        }
+
+        if (!p_fn(*b, te, field) {
+                snprintf(result->error, sizeof(result->error),
+                         "couldn't parse '%s'", field_name);
+                return false;
+        }
+
+	*b = _eat_space(te);
+        return true;
+
+}
+
+bool parse_vdo_status(const char *input, struct parse_result *result)
+{
+	const char *b = _eat_space(input);
+	const char *e = input + strlen(input);
+	const char *te;
+	struct vdo_status *s = malloc(sizeof(*s));
+
+	if (!s) {
+        	result->error = "out of memory";
+        	return false;
+	}
+
+	te = _next_tok(b, e);
+	if (!te) {
+        	result->error = "couldn't get token for device";
+        	free(s);
+        	return false;
+	}
+
+	s->device = _tok_cpy(b, te);
+	if (!s->device) {
+		result->error = "out of memory";
+		free(s);
+		return false;
+	}
+
+	b = _eat_space(te);
+
+#define XX(p, f, fn) if (!_parse_field(&b, e, p, f, fn, result)) goto bad;
+	XX(_parse_recovering, &s->recovering, "recovering");
+	XX(_parse_index, &s->index_state, "index state");
+	XX(_parse_compression_state, &s->compression_state, "compression state");
+	XX(_parse_uint64, &s->used_blocks, "used blocks");
+	XX(_parse_uint64, &s->total_blocks, "total blocks");
+#undef XX
+
+        result->result = s;
+        return true;
+
+bad:
+	free(s->device);
+	free(s);
+	return false;
+}
+
+//----------------------------------------------------------------
diff --git a/device-mapper/vdo/target.h b/device-mapper/vdo/target.h
new file mode 100644
index 0000000..e3c6788
--- /dev/null
+++ b/device-mapper/vdo/target.h
@@ -0,0 +1,69 @@
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
+	const char *device;
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
+struct parse_result {
+	char error[VDO_MAX_ERROR];
+	struct vdo_status *result;
+};
+
+// Parses the status line from the kernel target.
+bool parse_vdo_status(const char *input, struct parse_result *result);
+
+
+//----------------------------------------------------------------
+
+#endif


