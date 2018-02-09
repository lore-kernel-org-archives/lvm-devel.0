From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 8 Feb 2018 20:32:24 -0500
Subject: master - device: Queue any aio beyond defined limits.
Message-ID: <201802090132.w191WOdr027484@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e29c80122b8eb1123e42d143f17dd7bddefedcd
Commit:        3e29c80122b8eb1123e42d143f17dd7bddefedcd
Parent:        db41fe6c5dab7ff66db9c0568f0e1e1b31657be3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 22 18:26:03 2018 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Feb 8 20:15:37 2018 +0000

device: Queue any aio beyond defined limits.

---
 WHATS_NEW                    |    1 +
 conf/example.conf.in         |   11 +++++
 lib/config/config_settings.h |    7 +++
 lib/config/defaults.h        |    2 +
 lib/device/dev-io.c          |   85 ++++++++++++++++++++++++++++++++++++++++-
 lib/device/device.h          |    1 +
 6 files changed, 104 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8ae79cf..9e6cb39 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Add devices/use_aio, aio_max, aio_memory to configure AIO limits.
   Support asynchronous I/O when scanning devices.
   Detect asynchronous I/O capability in configure or accept --disable-aio.
   Add AIO_SUPPORTED_CODE_PATH to indicate whether AIO may be used.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 6a491fb..3b0638f 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -64,6 +64,17 @@ devices {
 	# This configuration option has an automatic default value.
 	# use_aio = 1
 
+	# Configuration option devices/aio_max.
+	# Maximum number of asynchronous I/Os to issue concurrently.
+	# This configuration option has an automatic default value.
+	# aio_max = 128
+
+	# Configuration option devices/aio_memory.
+	# Approximate maximum total amount of memory (in MB) used
+	# for asynchronous I/O buffers.
+	# This configuration option has an automatic default value.
+	# aio_memory = 10
+
 	# Configuration option devices/obtain_device_list_from_udev.
 	# Obtain the list of available devices from udev.
 	# This avoids opening or using any inapplicable non-block devices or
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 523e6fe..f1db797 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -229,6 +229,13 @@ cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_
 cfg(devices_use_aio_CFG, "use_aio", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_AIO, vsn(2, 2, 178), NULL, 0, NULL,
 	"Use linux asynchronous I/O for parallel device access where possible.\n")
 
+cfg(devices_aio_max_CFG, "aio_max", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_AIO_MAX, vsn(2, 2, 178), NULL, 0, NULL,
+	"Maximum number of asynchronous I/Os to issue concurrently.\n")
+
+cfg(devices_aio_memory_CFG, "aio_memory", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_AIO_MEMORY, vsn(2, 2, 178), NULL, 0, NULL,
+	"Approximate maximum total amount of memory (in MB) used\n"
+	"for asynchronous I/O buffers.\n")
+
 cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, 0, NULL, NULL)
 
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 5efab11..1c730a9 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -33,6 +33,8 @@
 #define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
 #define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
 #define DEFAULT_USE_AIO 1
+#define DEFAULT_AIO_MAX 128
+#define DEFAULT_AIO_MEMORY 10
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_FW_RAID_COMPONENT_DETECTION 0
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index f2bb128..460c874 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -104,7 +104,11 @@ void devbufs_release(struct device *dev)
 
 static io_context_t _aio_ctx = 0;
 static struct io_event *_aio_events = NULL;
-static int _aio_max = 128;
+static int _aio_max = 0;
+static int64_t _aio_memory_max = 0;
+static int _aio_must_queue = 0;		/* Have we reached AIO capacity? */
+
+static DM_LIST_INIT(_aio_queue);
 
 #define DEFAULT_AIO_COLLECTION_EVENTS 32
 
@@ -112,11 +116,21 @@ int dev_async_setup(struct cmd_context *cmd)
 {
 	int r;
 
+	_aio_max = find_config_tree_int(cmd, devices_aio_max_CFG, NULL);
+	_aio_memory_max = find_config_tree_int(cmd, devices_aio_memory_CFG, NULL) * 1024 * 1024;
+
+	/* Threshold is zero? */
+	if (!_aio_max || !_aio_memory_max) {
+		if (_aio_ctx)
+			dev_async_exit();
+		return 1;
+	}
+
 	/* Already set up? */
 	if (_aio_ctx)
 		return 1;
 
-	log_debug_io("Setting up aio context for up to %d events.", _aio_max);
+	log_debug_io("Setting up aio context for up to %" PRId64 " MB across %d events.", _aio_memory_max, _aio_max);
 
 	if (!_aio_events && !(_aio_events = dm_zalloc(sizeof(*_aio_events) * DEFAULT_AIO_COLLECTION_EVENTS))) {
 		log_error("Failed to allocate io_event array for asynchronous I/O.");
@@ -154,11 +168,29 @@ int dev_async_reset(struct cmd_context *cmd)
 	return dev_async_setup(cmd);
 }
 
+/*
+ * Track the amount of in-flight async I/O.
+ * If it exceeds the defined threshold set _aio_must_queue.
+ */
+static void _update_aio_counters(int nr, ssize_t bytes)
+{
+	static int64_t aio_bytes = 0;
+	static int aio_count = 0;
+
+	aio_bytes += bytes;
+	aio_count += nr;
+
+	if (aio_count >= _aio_max || aio_bytes > _aio_memory_max)
+		_aio_must_queue = 1;
+	else
+		_aio_must_queue = 0;
+}
+
 static int _io(struct device_buffer *devbuf, unsigned ioflags);
 
 int dev_async_getevents(void)
 {
-	struct device_buffer *devbuf;
+	struct device_buffer *devbuf, *tmp;
 	lvm_callback_fn_t dev_read_callback_fn;
 	void *dev_read_callback_context;
 	int r, event_nr;
@@ -192,6 +224,8 @@ int dev_async_getevents(void)
 		devbuf = _aio_events[event_nr].obj->data;
 		dm_free(_aio_events[event_nr].obj);
 
+		_update_aio_counters(-1, -devbuf->where.size);
+
 		dev_read_callback_fn = devbuf->dev_read_callback_fn;
 		dev_read_callback_context = devbuf->dev_read_callback_context;
 
@@ -215,6 +249,14 @@ int dev_async_getevents(void)
 		}
 	}
 
+	/* Submit further queued events if we can */
+        dm_list_iterate_items_gen_safe(devbuf, tmp, &_aio_queue, aio_queued) {
+		if (_aio_must_queue)
+			break;
+                dm_list_del(&devbuf->aio_queued);
+		_io(devbuf, 1);
+        }
+
 	return 1;
 }
 
@@ -224,6 +266,8 @@ static int _io_async(struct device_buffer *devbuf)
 	struct iocb *iocb;
 	int r;
 
+	_update_aio_counters(1, devbuf->where.size);
+
 	if (!(iocb = dm_malloc(sizeof(*iocb)))) {
 		log_error("Failed to allocate I/O control block array for asynchronous I/O.");
 		return 0;
@@ -260,11 +304,29 @@ static int _io_async(struct device_buffer *devbuf)
 
 void dev_async_exit(void)
 {
+	struct device_buffer *devbuf, *tmp;
+	lvm_callback_fn_t dev_read_callback_fn;
+	void *dev_read_callback_context;
 	int r;
 
 	if (!_aio_ctx)
 		return;
 
+	/* Discard any queued requests */
+        dm_list_iterate_items_gen_safe(devbuf, tmp, &_aio_queue, aio_queued) {
+                dm_list_del(&devbuf->aio_queued);
+
+		_update_aio_counters(-1, -devbuf->where.size);
+
+		dev_read_callback_fn = devbuf->dev_read_callback_fn;
+		dev_read_callback_context = devbuf->dev_read_callback_context;
+
+		_release_devbuf(devbuf);
+
+		if (dev_read_callback_fn)
+			dev_read_callback_fn(1, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, NULL);
+        }
+
 	log_debug_io("Destroying aio context.");
 	if ((r = io_destroy(_aio_ctx)) < 0)
 		/* Returns -ENOSYS if aio not in kernel or -EINVAL if _aio_ctx invalid */
@@ -276,9 +338,16 @@ void dev_async_exit(void)
 	_aio_ctx = 0;
 }
 
+static void _queue_aio(struct device_buffer *devbuf)
+{
+	dm_list_add(&_aio_queue, &devbuf->aio_queued);
+	log_debug_io("Queueing aio.");
+}
+
 #else
 
 static int _aio_ctx = 0;
+static int _aio_must_queue = 0;
 
 int dev_async_setup(struct cmd_context *cmd)
 {
@@ -304,6 +373,10 @@ static int _io_async(struct device_buffer *devbuf)
 	return 0;
 }
 
+static void _queue_aio(struct device_buffer *devbuf)
+{
+}
+
 #endif /* AIO_SUPPORT */
 
 /*-----------------------------------------------------------------
@@ -542,6 +615,12 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 			devbuf->buf = (char *) ((((uintptr_t) devbuf->buf) + mask) & ~mask);
 	}
 
+	/* If we've reached our concurrent AIO limit, add this request to the queue */
+	if (!devbuf->write && _aio_ctx && aio_supported_code_path(ioflags) && dev_read_callback_fn && _aio_must_queue) {
+		_queue_aio(devbuf);
+		return 1;
+	}
+
 	devbuf->write = 0;
 
 	/* Do we need to read into the bounce buffer? */
diff --git a/lib/device/device.h b/lib/device/device.h
index b52522d..9061139 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -100,6 +100,7 @@ struct device_buffer {
 
 	lvm_callback_fn_t dev_read_callback_fn;
 	void *dev_read_callback_context;
+	struct dm_list aio_queued;	/* Queue of async I/O waiting to be issued */
 };
 
 /*


