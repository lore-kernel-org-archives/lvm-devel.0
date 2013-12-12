From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:28 +0000 (UTC)
Subject: master - cleanup: self compilable headers
Message-ID: <20131212124328.7BDCF6038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30a81e59894ed6c1fdb4a3bb0823b58de1e431cc
Commit:        30a81e59894ed6c1fdb4a3bb0823b58de1e431cc
Parent:        b53e9ba66a53e68fdad7700bcccb9d38e24e39d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 25 23:26:33 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:28:19 2013 +0100

cleanup: self compilable headers

---
 daemons/clvmd/clvm.h                  |    1 +
 daemons/dmeventd/libdevmapper-event.h |    1 +
 lib/datastruct/lvm-types.h            |    2 ++
 lib/datastruct/str_list.h             |    3 +++
 lib/device/device.h                   |    1 +
 lib/format_text/text_import.h         |    3 +++
 lib/metadata/lv.h                     |    4 ++--
 lib/metadata/lv_alloc.h               |    2 ++
 lib/metadata/pv.h                     |    4 +++-
 lib/metadata/pv_alloc.h               |    9 +++++++++
 lib/metadata/vg.h                     |    6 +++---
 lib/misc/crc.h                        |    2 ++
 lib/uuid/uuid.h                       |    5 +++++
 libdm/misc/dm-log-userspace.h         |    2 ++
 14 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/daemons/clvmd/clvm.h b/daemons/clvmd/clvm.h
index 8e24f15..716af40 100644
--- a/daemons/clvmd/clvm.h
+++ b/daemons/clvmd/clvm.h
@@ -23,6 +23,7 @@
 #define _CLVM_H
 
 #include "configure.h"
+#include <inttypes.h>
 
 struct clvm_header {
 	uint8_t  cmd;	        /* See below */
diff --git a/daemons/dmeventd/libdevmapper-event.h b/daemons/dmeventd/libdevmapper-event.h
index 7ce3f39..9c1cc6f 100644
--- a/daemons/dmeventd/libdevmapper-event.h
+++ b/daemons/dmeventd/libdevmapper-event.h
@@ -48,6 +48,7 @@ enum dm_event_mask {
 #define DM_EVENT_ALL_ERRORS DM_EVENT_ERROR_MASK
 #define DM_EVENT_PROTOCOL_VERSION 1
 
+struct dm_task;
 struct dm_event_handler;
 
 struct dm_event_handler *dm_event_handler_create(void);
diff --git a/lib/datastruct/lvm-types.h b/lib/datastruct/lvm-types.h
index 5358850..e96009d 100644
--- a/lib/datastruct/lvm-types.h
+++ b/lib/datastruct/lvm-types.h
@@ -19,6 +19,8 @@
 #include <sys/types.h>
 #include <inttypes.h>
 
+#include "libdevmapper.h"
+
 /* Define some portable printing types */
 #define PRIsize_t "zu"
 #define PRIptrdiff_t "td"
diff --git a/lib/datastruct/str_list.h b/lib/datastruct/str_list.h
index 42f47da..82141e1 100644
--- a/lib/datastruct/str_list.h
+++ b/lib/datastruct/str_list.h
@@ -16,6 +16,9 @@
 #ifndef _LVM_STR_LIST_H
 #define _LVM_STR_LIST_H
 
+struct dm_list;
+struct dm_pool;
+
 struct dm_list *str_list_create(struct dm_pool *mem);
 int str_list_add(struct dm_pool *mem, struct dm_list *sll, const char *str);
 void str_list_del(struct dm_list *sll, const char *str);
diff --git a/lib/device/device.h b/lib/device/device.h
index 1d6304d..e42f664 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -17,6 +17,7 @@
 #define _LVM_DEVICE_H
 
 #include "uuid.h"
+#include "lvm-types.h"
 
 #include <fcntl.h>
 
diff --git a/lib/format_text/text_import.h b/lib/format_text/text_import.h
index faebc07..1308a15 100644
--- a/lib/format_text/text_import.h
+++ b/lib/format_text/text_import.h
@@ -16,6 +16,9 @@
 #ifndef _LVM_TEXT_IMPORT_H
 #define _LVM_TEXT_IMPORT_H
 
+#include <inttypes.h>
+
+struct dm_hash_table;
 struct lv_segment;
 struct dm_config_node;
 
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index 06f8c60..51920b0 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -15,9 +15,9 @@
 #ifndef _LVM_LV_H
 #define _LVM_LV_H
 
+#include "vg.h"
+
 union lvid;
-struct volume_group;
-struct dm_list;
 struct lv_segment;
 struct replicator_device;
 enum activation_change;
diff --git a/lib/metadata/lv_alloc.h b/lib/metadata/lv_alloc.h
index 9f8e0e3..acfebca 100644
--- a/lib/metadata/lv_alloc.h
+++ b/lib/metadata/lv_alloc.h
@@ -16,6 +16,8 @@
 #ifndef _LVM_LV_ALLOC_H
 #define _LVM_LV_ALLOC_H
 
+#include "metadata-exported.h"
+
 struct lv_segment *alloc_lv_segment(const struct segment_type *segtype,
 				    struct logical_volume *lv,
 				    uint32_t le, uint32_t len,
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 8fd3061..2d436cb 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -15,7 +15,9 @@
 #ifndef _LVM_PV_H
 #define _LVM_PV_H
 
-struct id;
+#include "uuid.h"
+#include "libdevmapper.h"
+
 struct device;
 struct format_type;
 struct volume_group;
diff --git a/lib/metadata/pv_alloc.h b/lib/metadata/pv_alloc.h
index 2318473..929302e 100644
--- a/lib/metadata/pv_alloc.h
+++ b/lib/metadata/pv_alloc.h
@@ -14,6 +14,15 @@
 
 #ifndef _LVM_PV_ALLOC_H
 
+#include <inttypes.h>
+
+struct dm_list;
+struct dm_pool;
+struct lv_segment;
+struct physical_volume;
+struct pv_segment;
+struct volume_group;
+
 int alloc_pv_segment_whole_pv(struct dm_pool *mem, struct physical_volume *pv);
 int peg_dup(struct dm_pool *mem, struct dm_list *peg_new, struct dm_list *peg_old);
 struct pv_segment *assign_peg_to_lvseg(struct physical_volume *pv, uint32_t pe,
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 5cc5f6d..43d27bf 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -15,11 +15,11 @@
 #ifndef _LVM_VG_H
 #define _LVM_VG_H
 
+#include "uuid.h"
+#include "libdevmapper.h"
+
 struct cmd_context;
-struct dm_pool;
 struct format_instance;
-struct dm_list;
-struct id;
 struct logical_volume;
 
 typedef enum {
diff --git a/lib/misc/crc.h b/lib/misc/crc.h
index 2910bc5..007c610 100644
--- a/lib/misc/crc.h
+++ b/lib/misc/crc.h
@@ -16,6 +16,8 @@
 #ifndef _LVM_CRC_H
 #define _LVM_CRC_H
 
+#include <inttypes.h>
+
 #define INITIAL_CRC 0xf597a6cf
 
 uint32_t calc_crc(uint32_t initial, const uint8_t *buf, uint32_t size);
diff --git a/lib/uuid/uuid.h b/lib/uuid/uuid.h
index 5c8382d..60bec65 100644
--- a/lib/uuid/uuid.h
+++ b/lib/uuid/uuid.h
@@ -19,6 +19,11 @@
 #define ID_LEN 32
 #define ID_LEN_S "32"
 
+#include <inttypes.h>
+#include <sys/types.h>
+
+struct dm_pool;
+
 struct id {
 	int8_t uuid[ID_LEN];
 };
diff --git a/libdm/misc/dm-log-userspace.h b/libdm/misc/dm-log-userspace.h
index 3317938..6418300 100644
--- a/libdm/misc/dm-log-userspace.h
+++ b/libdm/misc/dm-log-userspace.h
@@ -7,6 +7,8 @@
 #ifndef __DM_LOG_USERSPACE_H__
 #define __DM_LOG_USERSPACE_H__
 
+#include <inttypes.h>
+
 #include "dm-ioctl.h" /* For DM_UUID_LEN */
 
 /*


