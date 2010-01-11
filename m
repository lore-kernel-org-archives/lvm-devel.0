From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 11 Jan 2010 16:12:28 +0100
Subject: [PATCH 0/4] Add support for libdevmapper and dmsetup to disable udev checking on request
In-Reply-To: <20100111141014.GA5294@agk-dp.fab.redhat.com>
References: <4B4746BF.7090300@redhat.com>	<20100108180807.GF6042@agk-dp.fab.redhat.com>	<4B4B1F3B.9090101@redhat.com>
	<20100111141014.GA5294@agk-dp.fab.redhat.com>
Message-ID: <4B4B3FDC.5090705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/11/2010 03:10 PM, Alasdair G Kergon wrote:
> Well only things that are necessary prerequisites of enabling logging get done
> before logging is enabled.  Everything that can be delayed is delayed.

OK, I've added the debug messages, so we can trace it...

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
index 43ef63a..ca35242 100644
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
@@ -963,6 +977,19 @@ int dm_udev_get_sync_support(void)
 	return dm_cookie_supported() && _udev_running && _sync_with_udev;
 }
 
+void dm_udev_set_checking(int checking)
+{
+	if ((_udev_checking = checking))
+		log_debug("DM udev checking enabled");
+	else
+		log_debug("DM udev checking disabled");
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
index d81032b..d62e147 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3158,6 +3158,7 @@ int main(int argc, char **argv)
 	struct command *c;
 	int r = 1;
 	const char *dev_dir;
+	const char *disable_udev_checking;
 
 	(void) setlocale(LC_ALL, "");
 
@@ -3207,6 +3208,11 @@ int main(int argc, char **argv)
 	if (_switches[NOUDEVSYNC_ARG])
 		dm_udev_set_sync_support(0);
 
+	disable_udev_checking = getenv("DM_UDEV_DISABLE_CHECKING");
+	if ((disable_udev_checking && *disable_udev_checking) &&
+	    !strcmp(disable_udev_checking, "1"))
+		dm_udev_set_checking(0);
+
       doit:
 	if (!c->fn(argc, argv, NULL)) {
 		fprintf(stderr, "Command failed\n");


