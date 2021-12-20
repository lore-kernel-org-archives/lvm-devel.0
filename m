From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:12 +0000 (GMT)
Subject: main - libdm: unmangling UUID for DM_DEVICE_LIST
Message-ID: <20211220151412.D8D6D3858025@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90da953fd22437a8abfff02eb590a621efcc007c
Commit:        90da953fd22437a8abfff02eb590a621efcc007c
Parent:        65236ee7226930bcbabac0d2dc1979a90bcf2d19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 8 10:45:13 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

libdm: unmangling UUID for DM_DEVICE_LIST

Properly unmangle UUID if they are provided as result
of DM_DEVICE_LIST ioctl on newer linux kernels.
---
 WHATS_NEW_DM                      |  1 +
 device_mapper/ioctl/libdm-iface.c | 52 +++++++++++++++++++++++++++++++++------
 libdm/ioctl/libdm-iface.c         | 51 ++++++++++++++++++++++++++++++++------
 3 files changed, 88 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8e06ee9b9..dfb075dcc 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.183 - 
 ====================================
+  Unmangle UUIDs for DM_DEVICE_LIST ioctl.
 
 Version 1.02.181 - 20th October 2021
 ====================================
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 925f18c6b..acc0f557c 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -754,6 +754,31 @@ struct dm_deps *dm_task_get_deps(struct dm_task *dmt)
 				   dmt->dmi.v4->data_start);
 }
 
+
+/*
+ * Round up the ptr to an 8-byte boundary.
+ * Follow kernel pattern.
+ */
+#define ALIGN_MASK 7
+static size_t _align_val(size_t val)
+{
+	return (val + ALIGN_MASK) & ~ALIGN_MASK;
+}
+static void *_align_ptr(void *ptr)
+{
+	return (void *)_align_val((size_t)ptr);
+}
+
+static int _check_has_event_nr(void) {
+	static int _has_event_nr = -1;
+
+	if (_has_event_nr < 0)
+		_has_event_nr = dm_check_version() &&
+			((_dm_version == 4) ?  _dm_version_minor >= 38 : _dm_version > 4);
+
+	return _has_event_nr;
+}
+
 struct dm_names *dm_task_get_names(struct dm_task *dmt)
 {
 	return (struct dm_names *) (((char *) dmt->dmi.v4) +
@@ -1806,23 +1831,34 @@ static int _do_dm_ioctl_unmangle_string(char *str, const char *str_name,
 static int _dm_ioctl_unmangle_names(int type, struct dm_ioctl *dmi)
 {
 	char buf[DM_NAME_LEN];
-	struct dm_names *names;
+	char buf_uuid[DM_UUID_LEN];
+	struct dm_name_list *names;
 	unsigned next = 0;
 	char *name;
 	int r = 1;
+	uint32_t *event_nr;
+	char *uuid_ptr;
+	dm_string_mangling_t mangling_mode = dm_get_name_mangling_mode();
 
 	if ((name = dmi->name))
-		r = _do_dm_ioctl_unmangle_string(name, "name", buf, sizeof(buf),
-						 dm_get_name_mangling_mode());
+		r &= _do_dm_ioctl_unmangle_string(name, "name", buf, sizeof(buf),
+						  mangling_mode);
 
 	if (type == DM_DEVICE_LIST &&
-	    ((names = ((struct dm_names *) ((char *)dmi + dmi->data_start)))) &&
+	    ((names = ((struct dm_name_list *) ((char *)dmi + dmi->data_start)))) &&
 	    names->dev) {
 		do {
-			names = (struct dm_names *)((char *) names + next);
-			r = _do_dm_ioctl_unmangle_string(names->name, "name",
-							 buf, sizeof(buf),
-							 dm_get_name_mangling_mode());
+			names = (struct dm_name_list *)((char *) names + next);
+			event_nr = _align_ptr(names->name + strlen(names->name) + 1);
+			r &= _do_dm_ioctl_unmangle_string(names->name, "name",
+							  buf, sizeof(buf), mangling_mode);
+			/* Unmangle also UUID within same loop */
+			if (_check_has_event_nr() &&
+			    (event_nr[1] & DM_NAME_LIST_FLAG_HAS_UUID)) {
+				uuid_ptr = _align_ptr(event_nr + 2);
+				r &= _do_dm_ioctl_unmangle_string(uuid_ptr, "UUID", buf_uuid,
+								  sizeof(buf_uuid), mangling_mode);
+			}
 			next = names->next;
 		} while (next);
 	}
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index a3a1bdc66..0fba79ce4 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -762,6 +762,30 @@ struct dm_deps *dm_task_get_deps(struct dm_task *dmt)
 				   dmt->dmi.v4->data_start);
 }
 
+/*
+ * Round up the ptr to an 8-byte boundary.
+ * Follow kernel pattern.
+ */
+#define ALIGN_MASK 7
+static size_t _align_val(size_t val)
+{
+	return (val + ALIGN_MASK) & ~ALIGN_MASK;
+}
+static void *_align_ptr(void *ptr)
+{
+	return (void *)_align_val((size_t)ptr);
+}
+
+static int _check_has_event_nr(void) {
+	static int _has_event_nr = -1;
+
+	if (_has_event_nr < 0)
+		_has_event_nr = dm_check_version() &&
+			((_dm_version == 4) ?  _dm_version_minor >= 38 : _dm_version > 4);
+
+	return _has_event_nr;
+}
+
 struct dm_names *dm_task_get_names(struct dm_task *dmt)
 {
 	return (struct dm_names *) (((char *) dmt->dmi.v4) +
@@ -1782,23 +1806,34 @@ static int _do_dm_ioctl_unmangle_string(char *str, const char *str_name,
 static int _dm_ioctl_unmangle_names(int type, struct dm_ioctl *dmi)
 {
 	char buf[DM_NAME_LEN];
-	struct dm_names *names;
+	char buf_uuid[DM_UUID_LEN];
+	struct dm_name_list *names;
 	unsigned next = 0;
 	char *name;
 	int r = 1;
+	uint32_t *event_nr;
+	char *uuid_ptr;
+	dm_string_mangling_t mangling_mode = dm_get_name_mangling_mode();
 
 	if ((name = dmi->name))
-		r = _do_dm_ioctl_unmangle_string(name, "name", buf, sizeof(buf),
-						 dm_get_name_mangling_mode());
+		r &= _do_dm_ioctl_unmangle_string(name, "name", buf, sizeof(buf),
+						  mangling_mode);
 
 	if (type == DM_DEVICE_LIST &&
-	    ((names = ((struct dm_names *) ((char *)dmi + dmi->data_start)))) &&
+	    ((names = ((struct dm_name_list *) ((char *)dmi + dmi->data_start)))) &&
 	    names->dev) {
 		do {
-			names = (struct dm_names *)((char *) names + next);
-			r = _do_dm_ioctl_unmangle_string(names->name, "name",
-							 buf, sizeof(buf),
-							 dm_get_name_mangling_mode());
+			names = (struct dm_name_list *)((char *) names + next);
+			event_nr = _align_ptr(names->name + strlen(names->name) + 1);
+			r &= _do_dm_ioctl_unmangle_string(names->name, "name",
+							  buf, sizeof(buf), mangling_mode);
+			/* Unmangle also UUID within same loop */
+			if (_check_has_event_nr() &&
+			    (event_nr[1] & DM_NAME_LIST_FLAG_HAS_UUID)) {
+				uuid_ptr = _align_ptr(event_nr + 2);
+				r &= _do_dm_ioctl_unmangle_string(uuid_ptr, "UUID", buf_uuid,
+								  sizeof(buf_uuid), mangling_mode);
+			}
 			next = names->next;
 		} while (next);
 	}


