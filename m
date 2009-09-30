From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 29 Sep 2009 20:28:15 -0400
Subject: [RFC][PATCH 3/5] add filtering function to dmeventd
Message-ID: <4AC2A61F.7000204@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds a device structure to maintain a device list in dmeventd.
When dmeventd detects an error, a filter string is generated and passed to
lvconvert and vgreduce commands by "--config" option.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |  205 +++++++++++++++++++++-
 1 file changed, 196 insertions(+), 9 deletions(-)

Index: LVM2.02.54-20090928/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
===================================================================
--- LVM2.02.54-20090928.orig/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ LVM2.02.54-20090928/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -32,6 +32,23 @@
 #define ME_INSYNC    1
 #define ME_FAILURE   2
 
+#define CMD_SIZE 256	/* FIXME Use system restriction */
+
+/*
+ * private data structure
+ */
+struct device {
+	struct dm_list list;
+	char *dname;			/* device name (ex: /dev/sda) */
+	unsigned int major;
+	unsigned int minor;
+};
+
+struct device_info {
+	struct dm_list dev_all;		/* all devices in the vg */
+	char filter_str[CMD_SIZE];
+};
+
 /*
  * register_device() is called first and performs initialisation.
  * Only one device may be registered or unregistered at a time.
@@ -51,6 +68,57 @@ static void *_lvm_handle = NULL;
  */
 static pthread_mutex_t _event_mutex = PTHREAD_MUTEX_INITIALIZER;
 
+
+#define DEVICE_FILTER_STR(devi)	\
+	((devi) && strlen((devi)->filter_str) ? (devi)->filter_str : "")
+
+#define DEVICE_CONFIG_PREP_STR(devi) \
+	((devi) && strlen((devi)->filter_str) ? "--config devices{" : "")
+
+#define DEVICE_CONFIG_POST_STR(devi) \
+	((devi) && strlen((devi)->filter_str) ? "}" : "")
+
+
+static void _build_filter_str(struct device_info *devi)
+{
+	struct device *dev;
+	int len = 0, size, ct = 0;
+
+	dm_list_iterate_items(dev, &devi->dev_all) {
+		size = dm_snprintf(devi->filter_str+len, CMD_SIZE-len,
+				   "%s\"a|%s$|\"",
+				   ct++ ? "," : "filter=[", dev->dname);
+		if (size < 0)
+			goto err;
+		len += size;
+	}
+
+	size = dm_snprintf(devi->filter_str+len, CMD_SIZE-len,
+			   "%s\"r|.*|\"]", ct ? "," : "");
+	if (size < 0)
+		goto err;
+
+	return;
+
+err:
+	syslog(LOG_ERR, "Unable to form filter string");
+	devi->filter_str[0] = '\0';
+	return;
+}
+
+static void _create_filter(struct device_info *devi)
+{
+	if (!devi)
+		return;
+	_build_filter_str(devi);
+}
+
+static void _destroy_filter(struct device_info *devi)
+{
+	if (devi)
+		devi->filter_str[0] = '\0';
+}
+
 static int _get_mirror_event(char *params)
 {
 	int i, r = ME_INSYNC;
@@ -138,10 +206,9 @@ static void _temporary_log_fn(int level,
 		syslog(LOG_DEBUG, "%s", format);
 }
 
-static int _remove_failed_devices(const char *device)
+static int _remove_failed_devices(const char *device, struct device_info *devi)
 {
 	int r;
-#define CMD_SIZE 256	/* FIXME Use system restriction */
 	char cmd_str[CMD_SIZE];
 	char *vg = NULL, *lv = NULL, *layer = NULL;
 
@@ -154,10 +221,15 @@ static int _remove_failed_devices(const 
 		return -ENOMEM;	/* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
 
+	_create_filter(devi);
+
 	/* FIXME Is any sanity-checking required on %s? */
-	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
+	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --repair --use-policies "
+				 "--config devices{ignore_suspended_devices=1\\ %s} %s/%s",
+				 DEVICE_FILTER_STR(devi), vg, lv)) {
 		/* this error should be caught above, but doesn't hurt to check again */
 		syslog(LOG_ERR, "Unable to form LVM command: Device name too long");
+		_destroy_filter(devi);
 		dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
 		return -ENAMETOOLONG; /* FIXME Replace with generic error return - reason for failure has already got logged */
 	}
@@ -165,24 +237,28 @@ static int _remove_failed_devices(const 
 	r = lvm2_run(_lvm_handle, cmd_str);
 
 	if (r == ECMD_PROCESSED) {
-		snprintf(cmd_str, CMD_SIZE, "vgreduce --removemissing %s", vg);
+		snprintf(cmd_str, CMD_SIZE, "vgreduce --removemissing %s%s%s %s",
+			 DEVICE_CONFIG_PREP_STR(devi), DEVICE_FILTER_STR(devi),
+			 DEVICE_CONFIG_POST_STR(devi), vg);
 		if (lvm2_run(_lvm_handle, cmd_str) != 1)
 			syslog(LOG_ERR, "Unable to remove failed PVs from VG %s", vg);
 	}
 
+	_destroy_filter(devi);
 	dm_pool_empty(_mem_pool);  /* FIXME: not safe with multiple threads */
 	return (r == ECMD_PROCESSED) ? 0 : -1;
 }
 
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute((unused)),
-		   void **unused __attribute((unused)))
+		   void **private)
 {
 	void *next = NULL;
 	uint64_t start, length;
 	char *target_type = NULL;
 	char *params;
 	const char *device = dm_task_get_name(dmt);
+	struct device_info *devi = *private;
 
 	if (pthread_mutex_trylock(&_event_mutex)) {
 		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
@@ -212,7 +288,7 @@ void process_event(struct dm_task *dmt,
 			break;
 		case ME_FAILURE:
 			syslog(LOG_ERR, "Device failure in %s\n", device);
-			if (_remove_failed_devices(device))
+			if (_remove_failed_devices(device, devi))
 				/* FIXME Why are all the error return codes unused? Get rid of them? */
 				syslog(LOG_ERR, "Failed to remove faulty devices in %s\n",
 				       device);
@@ -233,18 +309,122 @@ void process_event(struct dm_task *dmt,
 	pthread_mutex_unlock(&_event_mutex);
 }
 
+static int _fetch_string(char **ptr, char **src, const int delimiter)
+{
+	char *p;
+	size_t len;
+
+	if (!(p = strchr(*src, delimiter)))
+		return 0;
+	*p = '\0';
+
+	len = strlen(*src);
+	if (len && !(*ptr = dm_strdup(*src))) {
+		*p = delimiter;
+		return 0;
+	}
+
+	*p = delimiter;
+	*src = p + 1;
+
+	return 1;
+}
+
+static int _fetch_number(unsigned int *ptr, char **src, const int delimiter)
+{
+	char *p;
+
+	if (!(p = strchr(*src, delimiter)))
+		return 0;
+	*p = '\0';
+
+	*ptr = strtoul(*src, NULL, 10);
+
+	*p = delimiter;
+	*src = p + 1;
+
+	return 1;
+}
+
+static struct device_info *alloc_device_info(void)
+{
+	struct device_info *devi;
+
+	devi = dm_malloc(sizeof(*devi));
+	if (!devi)
+		return NULL;
+
+	dm_list_init(&devi->dev_all);
+
+	return devi;
+}
+
+static int set_device_info(struct device_info *devi, char *dev_list)
+{
+	struct device *dev;
+	char *p = dev_list;
+
+	/* format: {/dev/sdx,major:minor;}[1,] */
+	while (strchr(p, ';')) {
+		dev = dm_malloc(sizeof(*dev));
+		if (!dev)
+			return 0;
+		memset(dev, 0, sizeof(*dev));
+
+		if (!_fetch_string(&dev->dname, &p, ',') ||
+		    !_fetch_number(&dev->major, &p, ':') ||
+		    !_fetch_number(&dev->minor, &p, ';')) {
+			if (dev->dname)
+				dm_free(dev->dname);
+			dm_free(dev);
+			return 0;
+		}
+		dm_list_add(&devi->dev_all, &dev->list);
+	}
+
+	return 1;
+}
+
+static void free_device_info(struct device_info *devi)
+{
+	struct device *dev, *devt;
+
+	if (!devi)
+		return;
+
+	dm_list_iterate_items_safe(dev, devt, &devi->dev_all) {
+		dm_list_del(&dev->list);
+		dm_free(dev->dname);
+		dm_free(dev);
+	}
+
+	dm_free(devi);
+}
+
 int register_device(const char *device,
 		    const char *uuid __attribute((unused)),
 		    int major __attribute((unused)),
 		    int minor __attribute((unused)),
-		    void **priv_ptr __attribute((unused)),
-		    void *priv_data __attribute((unused)))
+  		    void **priv_ptr, void *priv_data)
 {
+	struct device_info *devi;
 	int r = 0;
 
 	pthread_mutex_lock(&_register_mutex);
 
-	syslog(LOG_INFO, "Monitoring mirror device %s for events\n", device);
+	/*
+	 * allocate device_info
+	 */
+	if (priv_data) {
+		devi = alloc_device_info();
+		if (!devi)
+			goto out;
+
+		*priv_ptr = devi;
+
+		if (!set_device_info(devi, priv_data))
+			goto out;
+	}
 
 	/*
 	 * Need some space for allocations.  1024 should be more
@@ -265,10 +445,15 @@ int register_device(const char *device,
 		lvm2_run(_lvm_handle, "_memlock_inc");
 	}
 
+	syslog(LOG_INFO, "Monitoring mirror device %s for events\n", device);
+
 	_register_count++;
 	r = 1;
 
 out:
+	if (!r)
+		free_device_info(*priv_ptr);
+
 	pthread_mutex_unlock(&_register_mutex);
 
 	return r;
@@ -293,6 +478,8 @@ int unregister_device(const char *device
 		_lvm_handle = NULL;
 	}
 
+	free_device_info(*priv_ptr);
+
 	pthread_mutex_unlock(&_register_mutex);
 
 	return 1;

-- 
Takahiro Yasui
Hitachi Computer Products (America), Inc.


