From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 04:34:28 -0400
Subject: master - device_mapper: convert vdo to use dm_ prefix
Message-ID: <201807090834.w698YSqx024646@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b6b4f14d89c661683b2095999126e652fb92f53
Commit:        9b6b4f14d89c661683b2095999126e652fb92f53
Parent:        4a64bb9573bb3c54cfac0b4f588cd80dba01d60d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 9 10:04:51 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 10:30:34 2018 +0200

device_mapper: convert vdo to use dm_ prefix

Keep using DM_/dm_ prefixes for device_mapper code.
---
 device_mapper/vdo/status.c |   49 ++++++++++++++++++++++---------------------
 device_mapper/vdo/target.h |   48 +++++++++++++++++++++---------------------
 2 files changed, 49 insertions(+), 48 deletions(-)

diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index a0eba49..6831195 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -3,6 +3,7 @@
 
 // For DM_ARRAY_SIZE!
 #include "device_mapper/all.h"
+#include "base/memory/zalloc.h"
 
 #include <ctype.h>
 #include <stdlib.h>
@@ -27,14 +28,14 @@ static bool _parse_operating_mode(const char *b, const char *e, void *context)
 {
 	static const struct {
 		const char str[12];
-		enum vdo_operating_mode mode;
+		enum dm_vdo_operating_mode mode;
 	} _table[] = {
-		{"recovering", VDO_MODE_RECOVERING},
-		{"read-only", VDO_MODE_READ_ONLY},
-		{"normal", VDO_MODE_NORMAL}
+		{"recovering", DM_VDO_MODE_RECOVERING},
+		{"read-only", DM_VDO_MODE_READ_ONLY},
+		{"normal", DM_VDO_MODE_NORMAL}
 	};
 
-	enum vdo_operating_mode *r = context;
+	enum dm_vdo_operating_mode *r = context;
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
 		if (_tok_eq(b, e, _table[i].str)) {
@@ -50,13 +51,13 @@ static bool _parse_compression_state(const char *b, const char *e, void *context
 {
 	static const struct {
 		const char str[8];
-		enum vdo_compression_state state;
+		enum dm_vdo_compression_state state;
 	} _table[] = {
-		{"online", VDO_COMPRESSION_ONLINE},
-		{"offline", VDO_COMPRESSION_OFFLINE}
+		{"online", DM_VDO_COMPRESSION_ONLINE},
+		{"offline", DM_VDO_COMPRESSION_OFFLINE}
 	};
 
-	enum vdo_compression_state *r = context;
+	enum dm_vdo_compression_state *r = context;
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
 		if (_tok_eq(b, e, _table[i].str)) {
@@ -88,18 +89,18 @@ static bool _parse_index_state(const char *b, const char *e, void *context)
 {
 	static const struct {
 		const char str[8];
-		enum vdo_index_state state;
+		enum dm_vdo_index_state state;
 	} _table[] = {
-		{"error", VDO_INDEX_ERROR},
-		{"closed", VDO_INDEX_CLOSED},
-		{"opening", VDO_INDEX_OPENING},
-		{"closing", VDO_INDEX_CLOSING},
-		{"offline", VDO_INDEX_OFFLINE},
-		{"online", VDO_INDEX_ONLINE},
-		{"unknown", VDO_INDEX_UNKNOWN}
+		{"error", DM_VDO_INDEX_ERROR},
+		{"closed", DM_VDO_INDEX_CLOSED},
+		{"opening", DM_VDO_INDEX_OPENING},
+		{"closing", DM_VDO_INDEX_CLOSING},
+		{"offline", DM_VDO_INDEX_OFFLINE},
+		{"online", DM_VDO_INDEX_ONLINE},
+		{"unknown", DM_VDO_INDEX_UNKNOWN}
 	};
 
-	enum vdo_index_state *r = context;
+	enum dm_vdo_index_state *r = context;
 	unsigned i;
 	for (i = 0; i < DM_ARRAY_SIZE(_table); i++) {
 		if (_tok_eq(b, e, _table[i].str)) {
@@ -145,10 +146,10 @@ static const char *_next_tok(const char *b, const char *e)
 	return te == b ? NULL : te;
 }
 
-static void _set_error(struct vdo_status_parse_result *result, const char *fmt, ...)
+static void _set_error(struct dm_vdo_status_parse_result *result, const char *fmt, ...)
 __attribute__ ((format(printf, 2, 3)));
 
-static void _set_error(struct vdo_status_parse_result *result, const char *fmt, ...)
+static void _set_error(struct dm_vdo_status_parse_result *result, const char *fmt, ...)
 {
 	va_list ap;
 
@@ -160,7 +161,7 @@ static void _set_error(struct vdo_status_parse_result *result, const char *fmt,
 static bool _parse_field(const char **b, const char *e,
 			 bool (*p_fn)(const char *, const char *, void *),
 			 void *field, const char *field_name,
-			 struct vdo_status_parse_result *result)
+			 struct dm_vdo_status_parse_result *result)
 {
 	const char *te;
 
@@ -180,13 +181,13 @@ static bool _parse_field(const char **b, const char *e,
 
 }
 
-bool vdo_status_parse(struct dm_pool *mem, const char *input,
-		      struct vdo_status_parse_result *result)
+bool dm_vdo_status_parse(struct dm_pool *mem, const char *input,
+			 struct dm_vdo_status_parse_result *result)
 {
 	const char *b = b = input;
 	const char *e = input + strlen(input);
 	const char *te;
-	struct vdo_status *s;
+	struct dm_vdo_status *s;
 
 	s = (!mem) ? zalloc(sizeof(*s)) : dm_pool_zalloc(mem, sizeof(*s));
 
diff --git a/device_mapper/vdo/target.h b/device_mapper/vdo/target.h
index edf72a6..3d8722b 100644
--- a/device_mapper/vdo/target.h
+++ b/device_mapper/vdo/target.h
@@ -20,51 +20,51 @@
 
 //----------------------------------------------------------------
 
-enum vdo_operating_mode {
-	VDO_MODE_RECOVERING,
-	VDO_MODE_READ_ONLY,
-	VDO_MODE_NORMAL
+enum dm_vdo_operating_mode {
+	DM_VDO_MODE_RECOVERING,
+	DM_VDO_MODE_READ_ONLY,
+	DM_VDO_MODE_NORMAL
 };
 
-enum vdo_compression_state {
-	VDO_COMPRESSION_ONLINE,
-	VDO_COMPRESSION_OFFLINE
+enum dm_vdo_compression_state {
+	DM_VDO_COMPRESSION_ONLINE,
+	DM_VDO_COMPRESSION_OFFLINE
 };
 
-enum vdo_index_state {
-	VDO_INDEX_ERROR,
-	VDO_INDEX_CLOSED,
-	VDO_INDEX_OPENING,
-	VDO_INDEX_CLOSING,
-	VDO_INDEX_OFFLINE,
-	VDO_INDEX_ONLINE,
-	VDO_INDEX_UNKNOWN
+enum dm_vdo_index_state {
+	DM_VDO_INDEX_ERROR,
+	DM_VDO_INDEX_CLOSED,
+	DM_VDO_INDEX_OPENING,
+	DM_VDO_INDEX_CLOSING,
+	DM_VDO_INDEX_OFFLINE,
+	DM_VDO_INDEX_ONLINE,
+	DM_VDO_INDEX_UNKNOWN
 };
 
-struct vdo_status {
+struct dm_vdo_status {
 	char *device;
-	enum vdo_operating_mode operating_mode;
+	enum dm_vdo_operating_mode operating_mode;
 	bool recovering;
-	enum vdo_index_state index_state;
-	enum vdo_compression_state compression_state;
+	enum dm_vdo_index_state index_state;
+	enum dm_vdo_compression_state compression_state;
 	uint64_t used_blocks;
 	uint64_t total_blocks;
 };
 
-void vdo_status_destroy(struct vdo_status *s);
+void dm_vdo_status_destroy(struct dm_vdo_status *s);
 
 #define VDO_MAX_ERROR 256
 
-struct vdo_status_parse_result {
+struct dm_vdo_status_parse_result {
 	char error[VDO_MAX_ERROR];
-	struct vdo_status *status;
+	struct dm_vdo_status *status;
 };
 
 struct dm_pool;
 
 // Parses the status line from the kernel target.
-bool vdo_status_parse(struct dm_pool *mem, const char *input,
-		      struct vdo_status_parse_result *result);
+bool dm_vdo_status_parse(struct dm_pool *mem, const char *input,
+			 struct dm_vdo_status_parse_result *result);
 
 //----------------------------------------------------------------
 


