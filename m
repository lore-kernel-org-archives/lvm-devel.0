From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 29 Sep 2009 20:28:12 -0400
Subject: [RFC][PATCH 2/5] add device list registering interface
Message-ID: <4AC2A61C.6090301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When a LV is registered to dmeventd to be monitored, a list of PVs
associated with the VG which LV belongs to are passed to dmeventd.
The device list is used to generate a filter option string of lvm
commands when dmeventd handles an error.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 daemons/dmeventd/.exported_symbols                    |    1 
 daemons/dmeventd/dmeventd.c                           |   16 +++-
 daemons/dmeventd/libdevmapper-event.c                 |   42 +++++++---
 daemons/dmeventd/libdevmapper-event.h                 |    4 -
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c     |    5 -
 daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c |    3 
 lib/mirror/mirrored.c                                 |   72 +++++++++++++++++-
 7 files changed, 118 insertions(+), 25 deletions(-)

Index: LVM2.02.54-20090928/daemons/dmeventd/.exported_symbols
===================================================================
--- LVM2.02.54-20090928.orig/daemons/dmeventd/.exported_symbols
+++ LVM2.02.54-20090928/daemons/dmeventd/.exported_symbols
@@ -17,3 +17,4 @@ dm_event_unregister_handler
 dm_event_get_registered_device
 dm_event_handler_set_timeout
 dm_event_handler_get_timeout
+dm_event_handler_set_private
Index: LVM2.02.54-20090928/daemons/dmeventd/dmeventd.c
===================================================================
--- LVM2.02.54-20090928.orig/daemons/dmeventd/dmeventd.c
+++ LVM2.02.54-20090928/daemons/dmeventd/dmeventd.c
@@ -130,7 +130,7 @@ struct dso_data {
 	 * and activate a mapping).
 	 */
 	int (*register_device)(const char *device, const char *uuid, int major,
-			       int minor, void **user);
+			       int minor, void **user, void *user_data);
 
 	/*
 	 * Device unregistration.
@@ -148,6 +148,7 @@ static DM_LIST_INIT(_dso_registry);
 struct message_data {
 	char *id;
 	char *dso_name;		/* Name of DSO. */
+	char *dso_private;
 	char *device_uuid;	/* Mapped device path. */
 	union {
 		char *str;	/* Events string as fetched from message. */
@@ -331,6 +332,8 @@ static void _free_message(struct message
 	if (message_data->device_uuid)
 		dm_free(message_data->device_uuid);
 
+	if (message_data->dso_private)
+		dm_free(message_data->dso_private);
 }
 
 /* Parse a register message from the client. */
@@ -372,6 +375,9 @@ static int _parse_message(struct message
 		ret = 1;
 	}
 
+	if (strlen(p))
+		_fetch_string(&message_data->dso_private, &p, ' ');
+
 	dm_free(msg->data);
 	msg->data = NULL;
 	msg->size = 0;
@@ -649,13 +655,14 @@ static int _event_wait(struct thread_sta
 }
 
 /* Register a device with the DSO. */
-static int _do_register_device(struct thread_status *thread)
+static int _do_register_device(struct thread_status *thread, void *priv_data)
 {
 	return thread->dso_data->register_device(thread->device.name,
 						 thread->device.uuid,
 						 thread->device.major,
 						 thread->device.minor,
-						 &(thread->dso_private));
+						 &(thread->dso_private),
+						 priv_data);
 }
 
 /* Unregister a device with the DSO. */
@@ -969,7 +976,8 @@ static int _register_for_event(struct me
 	if (!(thread = _lookup_thread_status(message_data))) {
 		_unlock_mutex();
 
-		if (!(ret = _do_register_device(thread_new)))
+		if (!(ret = _do_register_device(thread_new,
+						message_data->dso_private)))
 			goto out;
 
 		thread = thread_new;
Index: LVM2.02.54-20090928/daemons/dmeventd/libdevmapper-event.c
===================================================================
--- LVM2.02.54-20090928.orig/daemons/dmeventd/libdevmapper-event.c
+++ LVM2.02.54-20090928/daemons/dmeventd/libdevmapper-event.c
@@ -41,6 +41,7 @@ struct dm_event_handler {
 	int major;
 	int minor;
 	uint32_t timeout;
+	char *private;
 
 	enum dm_event_mask mask;
 };
@@ -53,6 +54,8 @@ static void _dm_event_handler_clear_dev_
 		dm_free(dmevh->uuid);
 	dmevh->dev_name = dmevh->uuid = NULL;
 	dmevh->major = dmevh->minor = 0;
+	if (dmevh->private)
+		dm_free(dmevh->private);
 }
 
 struct dm_event_handler *dm_event_handler_create(void)
@@ -66,6 +69,7 @@ struct dm_event_handler *dm_event_handle
 	dmevh->major = dmevh->minor = 0;
 	dmevh->mask = 0;
 	dmevh->timeout = 0;
+	dmevh->private = NULL;
 
 	return dmevh;
 }
@@ -149,6 +153,16 @@ void dm_event_handler_set_timeout(struct
 	dmevh->timeout = timeout;
 }
 
+int dm_event_handler_set_private(struct dm_event_handler *dmevh, const char *private)
+{
+	if (!private)
+		return 0;
+	dmevh->private = dm_strdup(private);
+	if (!dmevh->private)
+		return -ENOMEM;
+	return 0;
+}
+
 const char *dm_event_handler_get_dso(const struct dm_event_handler *dmevh)
 {
 	return dmevh->dso;
@@ -331,11 +345,12 @@ static int _daemon_write(struct dm_event
 static int _daemon_talk(struct dm_event_fifos *fifos,
 			struct dm_event_daemon_message *msg, int cmd,
 			const char *dso_name, const char *dev_name,
-			enum dm_event_mask evmask, uint32_t timeout)
+			enum dm_event_mask evmask, uint32_t timeout,
+			const char *private)
 {
 	const char *dso = dso_name ? dso_name : "";
 	const char *dev = dev_name ? dev_name : "";
-	const char *fmt = "%d:%d %s %s %u %" PRIu32;
+	const char *fmt = "%d:%d %s %s %u %" PRIu32 " %s";
 	int msg_size;
 	memset(msg, 0, sizeof(*msg));
 
@@ -347,7 +362,7 @@ static int _daemon_talk(struct dm_event_
 	if (cmd == DM_EVENT_CMD_HELLO)
 		fmt = "%d:%d HELLO";
 	if ((msg_size = dm_asprintf(&(msg->data), fmt, getpid(), _sequence_nr,
-				    dso, dev, evmask, timeout)) < 0) {
+				    dso, dev, evmask, timeout, private ?: "")) < 0) {
 		log_error("_daemon_talk: message allocation failed");
 		return -ENOMEM;
 	}
@@ -550,7 +565,8 @@ failed:
 /* Handle the event (de)registration call and return negative error codes. */
 static int _do_event(int cmd, struct dm_event_daemon_message *msg,
 		     const char *dso_name, const char *dev_name,
-		     enum dm_event_mask evmask, uint32_t timeout)
+		     enum dm_event_mask evmask, uint32_t timeout,
+		     const char *private)
 {
 	int ret;
 	struct dm_event_fifos fifos;
@@ -560,14 +576,14 @@ static int _do_event(int cmd, struct dm_
 		return -ESRCH;
 	}
 
-	ret = _daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, 0, 0, 0, 0);
+	ret = _daemon_talk(&fifos, msg, DM_EVENT_CMD_HELLO, 0, 0, 0, 0, 0);
 
 	if (msg->data)
 		dm_free(msg->data);
 	msg->data = 0;
 
 	if (!ret)
-		ret = _daemon_talk(&fifos, msg, cmd, dso_name, dev_name, evmask, timeout);
+		ret = _daemon_talk(&fifos, msg, cmd, dso_name, dev_name, evmask, timeout, private);
 
 	/* what is the opposite of init? */
 	_dtr_client(&fifos);
@@ -590,8 +606,8 @@ int dm_event_register_handler(const stru
 
 	uuid = dm_task_get_uuid(dmt);
 
-	if ((err = _do_event(DM_EVENT_CMD_REGISTER_FOR_EVENT, &msg,
-			     dmevh->dso, uuid, dmevh->mask, dmevh->timeout)) < 0) {
+	if ((err = _do_event(DM_EVENT_CMD_REGISTER_FOR_EVENT, &msg, dmevh->dso,
+			     uuid, dmevh->mask, dmevh->timeout, dmevh->private)) < 0) {
 		log_error("%s: event registration failed: %s",
 			  dm_task_get_name(dmt),
 			  msg.data ? msg.data : strerror(-err));
@@ -621,7 +637,7 @@ int dm_event_unregister_handler(const st
 	uuid = dm_task_get_uuid(dmt);
 
 	if ((err = _do_event(DM_EVENT_CMD_UNREGISTER_FOR_EVENT, &msg,
-			    dmevh->dso, uuid, dmevh->mask, dmevh->timeout)) < 0) {
+			     dmevh->dso, uuid, dmevh->mask, dmevh->timeout, NULL)) < 0) {
 		log_error("%s: event deregistration failed: %s",
 			  dm_task_get_name(dmt),
 			  msg.data ? msg.data : strerror(-err));
@@ -695,8 +711,8 @@ int dm_event_get_registered_device(struc
 	uuid = dm_task_get_uuid(dmt);
 
 	if (!(ret = _do_event(next ? DM_EVENT_CMD_GET_NEXT_REGISTERED_DEVICE :
-			     DM_EVENT_CMD_GET_REGISTERED_DEVICE,
-			      &msg, dmevh->dso, uuid, dmevh->mask, 0))) {
+			      DM_EVENT_CMD_GET_REGISTERED_DEVICE, &msg,
+			      dmevh->dso, uuid, dmevh->mask, 0, dmevh->private))) {
 		/* FIXME this will probably horribly break if we get
 		   ill-formatted reply */
 		ret = _parse_message(&msg, &reply_dso, &reply_uuid, &reply_mask);
@@ -788,7 +804,7 @@ int dm_event_set_timeout(const char *dev
 		return -ENODEV;
 
 	return _do_event(DM_EVENT_CMD_SET_TIMEOUT, &msg,
-			 NULL, device_path, 0, timeout);
+			 NULL, device_path, 0, timeout, NULL);
 }
 
 int dm_event_get_timeout(const char *device_path, uint32_t *timeout)
@@ -799,7 +815,7 @@ int dm_event_get_timeout(const char *dev
 	if (!device_exists(device_path))
 		return -ENODEV;
 	if (!(ret = _do_event(DM_EVENT_CMD_GET_TIMEOUT, &msg, NULL, device_path,
-			     0, 0))) {
+			      0, 0, NULL))) {
 		char *p = _skip_string(msg.data, ' ');
 		if (!p) {
 			log_error("malformed reply from dmeventd '%s'\n",
Index: LVM2.02.54-20090928/daemons/dmeventd/libdevmapper-event.h
===================================================================
--- LVM2.02.54-20090928.orig/daemons/dmeventd/libdevmapper-event.h
+++ LVM2.02.54-20090928/daemons/dmeventd/libdevmapper-event.h
@@ -72,6 +72,7 @@ int dm_event_handler_set_uuid(struct dm_
 void dm_event_handler_set_major(struct dm_event_handler *dmevh, int major);
 void dm_event_handler_set_minor(struct dm_event_handler *dmevh, int minor);
 void dm_event_handler_set_timeout(struct dm_event_handler *dmevh, int timeout);
+int dm_event_handler_set_private(struct dm_event_handler *dmevh, const char *private);
 
 /*
  * Specify mask for events to monitor.
@@ -99,7 +100,8 @@ int dm_event_unregister_handler(const st
 /* Prototypes for DSO interface, see dmeventd.c, struct dso_data for
    detailed descriptions. */
 void process_event(struct dm_task *dmt, enum dm_event_mask evmask, void **user);
-int register_device(const char *device_name, const char *uuid, int major, int minor, void **user);
+int register_device(const char *device_name, const char *uuid, int major,
+		    int minor, void **user, void *user_data);
 int unregister_device(const char *device_name, const char *uuid, int major,
 		      int minor, void **user);
 
Index: LVM2.02.54-20090928/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
===================================================================
--- LVM2.02.54-20090928.orig/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ LVM2.02.54-20090928/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -237,7 +237,8 @@ int register_device(const char *device,
 		    const char *uuid __attribute((unused)),
 		    int major __attribute((unused)),
 		    int minor __attribute((unused)),
-		    void **unused __attribute((unused)))
+		    void **priv_ptr __attribute((unused)),
+		    void *priv_data __attribute((unused)))
 {
 	int r = 0;
 
@@ -277,7 +278,7 @@ int unregister_device(const char *device
 		      const char *uuid __attribute((unused)),
 		      int major __attribute((unused)),
 		      int minor __attribute((unused)),
-		      void **unused __attribute((unused)))
+		      void **priv_ptr __attribute((unused)))
 {
 	pthread_mutex_lock(&_register_mutex);
 
Index: LVM2.02.54-20090928/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
===================================================================
--- LVM2.02.54-20090928.orig/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ LVM2.02.54-20090928/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -150,7 +150,8 @@ int register_device(const char *device,
 		    const char *uuid __attribute((unused)),
 		    int major __attribute((unused)),
 		    int minor __attribute((unused)),
-		    void **private)
+		    void **private,
+		    void *unused __attribute((unused)))
 {
 	int r = 0;
 	int *percent_warning = (int*)private;
Index: LVM2.02.54-20090928/lib/mirror/mirrored.c
===================================================================
--- LVM2.02.54-20090928.orig/lib/mirror/mirrored.c
+++ LVM2.02.54-20090928/lib/mirror/mirrored.c
@@ -27,6 +27,7 @@
 #include "activate.h"
 #include "sharedlib.h"
 #include "str_list.h"
+#include "kdev_t.h"
 
 #ifdef DMEVENTD
 #  include "libdevmapper-event.h"
@@ -421,7 +422,8 @@ static int _get_mirror_dso_path(struct c
 
 static struct dm_event_handler *_create_dm_event_handler(const char *dmname,
 							 const char *dso,
-							 enum dm_event_mask mask)
+							 enum dm_event_mask mask,
+							 const char *private)
 {
 	struct dm_event_handler *dmevh;
 
@@ -435,6 +437,10 @@ static struct dm_event_handler *_create_
 		goto fail;
 
 	dm_event_handler_set_event_mask(dmevh, mask);
+
+	if (dm_event_handler_set_private(dmevh, private))
+		goto fail;
+
 	return dmevh;
 
 fail:
@@ -460,7 +466,7 @@ static int _target_monitored(struct lv_s
 	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS)))
+	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS, NULL)))
 		return_0;
 
 	if (dm_event_get_registered_device(dmevh, 0)) {
@@ -479,11 +485,63 @@ static int _target_monitored(struct lv_s
 	return evmask;
 }
 
+/*
+ * create device list
+ *
+ * dev/sda,8:0;/dev/sdb,8:1;
+ *
+ */
+static char *build_device_list(struct dm_pool *mem, struct volume_group *vg,
+			       struct logical_volume *lv)
+{
+	struct pv_list *pvl;
+	size_t len = 1, size;
+	char *devs;
+#define	TMP_SIZE	256	/* FIXME: set max device name len */
+	char dummy[TMP_SIZE];
+
+
+	/* count lengths of device string */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (pvl->pv->status & MISSING_PV)
+			continue;
+
+		size = dm_snprintf(dummy, TMP_SIZE, "%s,%u:%u;",
+				   pv_dev_name(pvl->pv),
+				   (unsigned int)MAJOR(pv_dev(pvl->pv)->dev),
+				   (unsigned int)MINOR(pv_dev(pvl->pv)->dev));
+		if (size < 0)
+			return NULL;
+
+		len += size;
+	}
+
+	devs = dm_pool_alloc(mem, len);
+	if (!devs)
+		return NULL;
+
+	memset(devs, 0, len);
+	len = 0;
+
+	/* create device lists like /dev/sda,8:0;/dev/sdb,8:1; */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (pvl->pv->status & MISSING_PV)
+			continue;
+		len += dm_snprintf(devs + len, TMP_SIZE, "%s,%u:%u;",
+				   pv_dev_name(pvl->pv),
+				   (unsigned int)MAJOR(pv_dev(pvl->pv)->dev),
+				   (unsigned int)MINOR(pv_dev(pvl->pv)->dev));
+	}
+
+	return devs;
+#undef	TMP_SIZE
+}
+
 /* FIXME This gets run while suspended and performs banned operations. */
 static int _target_set_events(struct lv_segment *seg,
 			      int evmask __attribute((unused)), int set)
 {
-	char *dso, *name;
+	char *dso, *name, *devl;
 	struct logical_volume *lv;
 	struct volume_group *vg;
 	struct dm_event_handler *dmevh;
@@ -498,8 +556,14 @@ static int _target_set_events(struct lv_
 	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS)))
+	if (!(devl = build_device_list(vg->cmd->mem, vg, lv)))
+		return_0;
+
+	if (!(dmevh = _create_dm_event_handler(name, dso, DM_EVENT_ALL_ERRORS,
+					       devl))) {
+		dm_free(devl);
 		return_0;
+	}
 
 	r = set ? dm_event_register_handler(dmevh) : dm_event_unregister_handler(dmevh);
 	dm_event_handler_destroy(dmevh);

-- 
Takahiro Yasui
Hitachi Computer Products (America), Inc.


