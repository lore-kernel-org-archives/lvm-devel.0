From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:14 +0000 (GMT)
Subject: main - devicemapper: add dm_task_get_device_list
Message-ID: <20211220151414.05FBC3857C4C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=988ea0e94c79a496f2619eab878fd9db6168711d
Commit:        988ea0e94c79a496f2619eab878fd9db6168711d
Parent:        90da953fd22437a8abfff02eb590a621efcc007c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 15 11:34:50 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

devicemapper: add dm_task_get_device_list

New API extension (internal ATM) for getting a list
of active DM device with extra features like i.e. uuid.

To easily lookout for existing UUID in device list,
there is: dm_device_list_find_by_uuid()

Once the returned structure is no longer usable call:
dm_device_list_destroy()

Struct dm_active_device {} holds all the info,
but is always allocated and destroyed within library.

TODO: once it's stable, copy to libdm
---
 WHATS_NEW                         |   1 +
 device_mapper/all.h               |  29 +++++++++
 device_mapper/ioctl/libdm-iface.c | 128 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 158 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index fc327dffd..0b206f067 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.15 - 
 ===================================
+  Introduce function to utilize UUIDs from DM_DEVICE_LIST.
   Increase some hash table size to better support large device sets.
 
 Version 2.03.14 - 20th October 2021
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 17f78d989..c8f040b80 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -173,6 +173,16 @@ struct dm_names {
 	char name[];
 };
 
+struct dm_active_device {
+	struct dm_list list;
+	int major;
+	int minor;
+	char *name;	/* device name */
+
+	uint32_t event_nr; /* valid when DM_DEVICE_LIST_HAS_EVENT_NR is set */
+	char *uuid;	/* valid uuid when DM_DEVICE_LIST_HAS_UUID is set */
+};
+
 struct dm_versions {
 	uint32_t next;		/* Offset to next struct from start of this struct */
 	uint32_t version[3];
@@ -210,6 +220,25 @@ const char *dm_task_get_message_response(struct dm_task *dmt);
  */
 const char *dm_task_get_name(const struct dm_task *dmt);
 struct dm_names *dm_task_get_names(struct dm_task *dmt);
+/*
+ * Retrieve the list of devices and put them into easily accessible
+ * struct dm_active_device list elements.
+ * devs_features provides flag-set with used features so it's easy to check
+ * whether the kernel provides i.e. UUID info together with DM names
+ */
+#define DM_DEVICE_LIST_HAS_EVENT_NR	1
+#define DM_DEVICE_LIST_HAS_UUID		2
+int dm_task_get_device_list(struct dm_task *dmt, struct dm_list **devs_list,
+			    unsigned *devs_features);
+/*
+ * -1: no idea about uuid (not provided by DM_DEVICE_LIST ioctl)
+ *  0: uuid not present
+ *  1: listed and dm_active_device will be set for not NULL pointer
+ */
+int dm_device_list_find_by_uuid(struct dm_list *devs_list, const char *uuid,
+				const struct dm_active_device **dev);
+/* Release all associated memory with list of active DM devices */
+void dm_device_list_destroy(struct dm_list **devs_list);
 
 int dm_task_set_ro(struct dm_task *dmt);
 int dm_task_set_newname(struct dm_task *dmt, const char *newname);
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index acc0f557c..738807f8f 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -779,6 +779,134 @@ static int _check_has_event_nr(void) {
 	return _has_event_nr;
 }
 
+struct dm_device_list {
+	struct dm_list list;
+	unsigned count;
+	unsigned features;
+	struct dm_hash_table *uuids;
+};
+
+int dm_task_get_device_list(struct dm_task *dmt, struct dm_list **devs_list,
+			    unsigned *devs_features)
+{
+	struct dm_names *names, *names1;
+	struct dm_active_device *dm_dev, *dm_new_dev;
+	struct dm_device_list *devs;
+	unsigned next = 0;
+	uint32_t *event_nr;
+	char *uuid_ptr;
+	size_t len;
+	int cnt = 0;
+
+	*devs_list = 0;
+	*devs_features = 0;
+
+	if ((names = dm_task_get_names(dmt)) && names->dev) {
+		names1 = names;
+		if (!names->name[0])
+			cnt = -1; /* -> cnt == 0 when no device is really present */
+		do {
+			names1 = (struct dm_names *)((char *) names1 + next);
+			next = names1->next;
+			++cnt;
+		} while (next);
+	}
+
+	if (!(devs = malloc(sizeof(*devs) + (cnt ? cnt * sizeof(*dm_dev) + (char*)names1 - (char*)names + 256 : 0))))
+		return_0;
+
+	dm_list_init(&devs->list);
+	devs->count = cnt;
+	devs->uuids = NULL;
+
+	if (!cnt) {
+		/* nothing in the list -> mark all features present */
+		*devs_features |= (DM_DEVICE_LIST_HAS_EVENT_NR | DM_DEVICE_LIST_HAS_UUID);
+		goto out; /* nothing else to do */
+	}
+
+	dm_dev = (struct dm_active_device *) (devs + 1);
+
+	do {
+		names = (struct dm_names *)((char *) names + next);
+
+		dm_dev->major = MAJOR(names->dev);
+		dm_dev->minor = MINOR(names->dev);
+		dm_dev->name = (char*)(dm_dev + 1);
+		dm_dev->event_nr = 0;
+		dm_dev->uuid = NULL;
+
+		strcpy(dm_dev->name, names->name);
+		len = strlen(names->name) + 1;
+
+		dm_new_dev = _align_ptr((char*)(dm_dev + 1) + len);
+		if (_check_has_event_nr()) {
+			/* Hash for UUIDs with some more bits to reduce colision count */
+			if (!devs->uuids && !(devs->uuids = dm_hash_create(cnt * 8))) {
+				free(devs);
+				return_0;
+			}
+
+			*devs_features |= DM_DEVICE_LIST_HAS_EVENT_NR;
+			event_nr = _align_ptr(names->name + len);
+			dm_dev->event_nr = event_nr[0];
+
+			if ((event_nr[1] & DM_NAME_LIST_FLAG_HAS_UUID)) {
+				*devs_features |= DM_DEVICE_LIST_HAS_UUID;
+				uuid_ptr = _align_ptr(event_nr + 2);
+				dm_dev->uuid = (char*) dm_new_dev;
+				dm_new_dev = _align_ptr((char*)dm_new_dev + strlen(uuid_ptr) + 1);
+				strcpy(dm_dev->uuid, uuid_ptr);
+				if (!dm_hash_insert(devs->uuids, dm_dev->uuid, dm_dev))
+					return_0; // FIXME
+#if 0
+				log_debug("Active %s (%s) %d:%d event:%u",
+					  dm_dev->name, dm_dev->uuid,
+					  dm_dev->major, dm_dev->minor, dm_dev->event_nr);
+#endif
+			}
+		}
+
+		dm_list_add(&devs->list, &dm_dev->list);
+		dm_dev = dm_new_dev;
+		next = names->next;
+	} while (next);
+
+    out:
+	*devs_list = (struct dm_list *)devs;
+
+	return 1;
+}
+
+int dm_device_list_find_by_uuid(struct dm_list *devs_list, const char *uuid,
+				const struct dm_active_device **dev)
+{
+	struct dm_device_list *devs = (struct dm_device_list *) devs_list;
+	struct dm_active_device *dm_dev;
+
+	if (devs->uuids &&
+	    (dm_dev = dm_hash_lookup(devs->uuids, uuid))) {
+		if (dev)
+			*dev = dm_dev;
+		return 1;
+	}
+
+	return 0;
+}
+
+void dm_device_list_destroy(struct dm_list **devs_list)
+{
+	struct dm_device_list *devs = (struct dm_device_list *) *devs_list;
+
+	if (devs) {
+		if (devs->uuids)
+			dm_hash_destroy(devs->uuids);
+
+		free(devs);
+		*devs_list = NULL;
+	}
+}
+
 struct dm_names *dm_task_get_names(struct dm_task *dmt)
 {
 	return (struct dm_names *) (((char *) dmt->dmi.v4) +


