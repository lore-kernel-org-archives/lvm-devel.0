From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 08 Jan 2010 15:52:47 +0100
Subject: [PATCH 0/4] Add support for libdevmapper and dmsetup to disable udev checking on request
Message-ID: <4B4746BF.7090300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Per discussion with Dave, we've gathered a few things that would be quite fine to have
cleaned up while udev_sync is enabled...

Sometimes it is really needed to switch off udev checking and the warnings we show when
we detect that udev has not done its job right - the messages like "Udev should have done
this and that. Falling back to direct node creation/removal. " etc.

This would be especially handy while setting DM_DEV_DIR env var that could be set to a
different location than standard /dev (udev can't create nodes/symlinks out of that one
directory that is configured into udevd). The exact same situation happens while we're
running our tests so the output is full of those warning messages which is a little bit
irritating :)

So now, you can disable these checks globally with dm_udev_set_checking(0).

This patch adds support for libdevmapper and dmsetup which tries to read
DM_UDEV_DISABLE_CHECKING=1 env var and sets this option globally in libdevmapper then.

(just a proposal)

Peter


diff --git a/libdm/.exported_symbols b/libdm/.exported_symbols
index 1555e42..22fe7f8 100644
--- a/libdm/.exported_symbols
+++ b/libdm/.exported_symbols
@@ -163,5 +163,7 @@ dm_list_size
 dm_cookie_supported
 dm_udev_set_sync_support
 dm_udev_get_sync_support
+dm_udev_set_checking
+dm_udev_get_checking
 dm_udev_complete
 dm_udev_wait
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 4c4734f..dee3347 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1086,6 +1086,8 @@ int dm_cookie_supported(void);
  */
 void dm_udev_set_sync_support(int sync_with_udev);
 int dm_udev_get_sync_support(void);
+void dm_udev_set_checking(int checking);
+int dm_udev_get_checking(void);
 int dm_udev_complete(uint32_t cookie);
 int dm_udev_wait(uint32_t cookie);
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 43ef63a..36a60c3 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -52,6 +52,7 @@ static int _verbose = 0;
 #ifdef UDEV_SYNC_SUPPORT
 static int _udev_running = -1;
 static int _sync_with_udev = 1;
+static int _udev_checking = 1;
 #endif
 
 /*
@@ -428,7 +429,8 @@ static int _add_dev_node(const char *dev_name, uint32_t major, uint32_t minor,
 				  dev_name);
 			return 0;
 		}
-	} else if (dm_udev_get_sync_support() && check_udev)
+	} else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
+		   check_udev)
 		log_warn("%s not set up by udev: Falling back to direct "
 			 "node creation.", path);
 
@@ -462,7 +464,8 @@ static int _rm_dev_node(const char *dev_name, int check_udev)
 
 	if (stat(path, &info) < 0)
 		return 1;
-	else if (dm_udev_get_sync_support() && check_udev)
+	else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
+		 check_udev)
 		log_warn("Node %s was not removed by udev. "
 			 "Falling back to direct node removal.", path);
 
@@ -492,7 +495,8 @@ static int _rename_dev_node(const char *old_name, const char *new_name,
 				  "is already present", newpath);
 			return 0;
 		}
-		else if (dm_udev_get_sync_support() && check_udev) {
+		else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
+			 check_udev) {
 			if (stat(oldpath, &info) < 0 &&
 				 errno == ENOENT)
 				/* assume udev already deleted this */
@@ -516,7 +520,8 @@ static int _rename_dev_node(const char *old_name, const char *new_name,
 			return 0;
 		}
 	}
-	else if (dm_udev_get_sync_support() && check_udev)
+	else if (dm_udev_get_sync_support() && dm_udev_get_checking() &&
+		 check_udev)
 		log_warn("The node %s should have been renamed to %s "
 			 "by udev but new node is not present. "
 			 "Falling back to direct node rename.",
@@ -884,6 +889,15 @@ int dm_udev_get_sync_support(void)
 	return 0;
 }
 
+void dm_udev_set_checking(int checking)
+{
+}
+
+int dm_udev_get_checking(void)
+{
+	return 0;
+}
+
 int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 {
 	if (dm_cookie_supported())
@@ -963,6 +977,16 @@ int dm_udev_get_sync_support(void)
 	return dm_cookie_supported() && _udev_running && _sync_with_udev;
 }
 
+void dm_udev_set_checking(int checking)
+{
+	_udev_checking = checking;
+}
+
+int dm_udev_get_checking(void)
+{
+	return _udev_checking;
+}
+
 static int _get_cookie_sem(uint32_t cookie, int *semid)
 {
 	if (cookie >> 16 != DM_COOKIE_MAGIC) {
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index d81032b..1475e1a 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3158,6 +3158,7 @@ int main(int argc, char **argv)
 	struct command *c;
 	int r = 1;
 	const char *dev_dir;
+	const char *disable_udev_checking;
 
 	(void) setlocale(LC_ALL, "");
 
@@ -3170,6 +3171,11 @@ int main(int argc, char **argv)
 	} else
 		dev_dir = DEFAULT_DM_DEV_DIR;
 
+	disable_udev_checking = getenv("DM_UDEV_DISABLE_CHECKING");
+	if ((disable_udev_checking && *disable_udev_checking) &&
+	    !strcmp(disable_udev_checking, "1"))
+		dm_udev_set_checking(0);
+
 	if (!_process_switches(&argc, &argv, dev_dir)) {
 		fprintf(stderr, "Couldn't process command line.\n");
 		goto out;


