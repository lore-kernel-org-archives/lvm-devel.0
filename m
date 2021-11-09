From: David Teigland <teigland@sourceware.org>
Date: Tue,  9 Nov 2021 17:55:56 +0000 (GMT)
Subject: main - filter-sysfs: support old kernels without sys/dev/block
Message-ID: <20211109175556.273B23858404@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d608837b2a88d0ed0c7ef7d8e6135e2d37687ff1
Commit:        d608837b2a88d0ed0c7ef7d8e6135e2d37687ff1
Parent:        73b4602f219767850a2834c6b15bdb5e6d636870
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 9 11:54:48 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 9 11:54:48 2021 -0600

filter-sysfs: support old kernels without sys/dev/block

rhel5 for example doesn't have /sys/dev/block
---
 lib/filters/filter-sysfs.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 672211057..d8de7940b 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -15,6 +15,8 @@
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
 
+static int _sys_dev_block_found;
+
 #ifdef __linux__
 
 static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
@@ -23,6 +25,9 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 	const char *sysfs_dir;
 	struct stat info;
 
+	if (!_sys_dev_block_found)
+		return 1;
+
 	dev->filtered_flags &= ~DEV_FILTERED_SYSFS;
 
 	/*
@@ -57,6 +62,26 @@ static void _destroy(struct dev_filter *f)
 	free(f);
 }
 
+static void _check_sys_dev_block(void)
+{
+	char path[PATH_MAX];
+	const char *sysfs_dir;
+	struct stat info;
+
+	sysfs_dir = dm_sysfs_dir();
+	if (sysfs_dir && *sysfs_dir) {
+		if (dm_snprintf(path, sizeof(path), "%sdev/block", sysfs_dir) < 0)
+			return;
+
+		if (lstat(path, &info)) {
+			log_debug("filter-sysfs disabled: /sys/dev/block not found");
+			_sys_dev_block_found = 0;
+		} else {
+			_sys_dev_block_found = 1;
+		}
+	}
+}
+
 struct dev_filter *sysfs_filter_create(void)
 {
 	const char *sysfs_dir = dm_sysfs_dir();
@@ -67,6 +92,9 @@ struct dev_filter *sysfs_filter_create(void)
 		return NULL;
 	}
 
+	/* support old kernels that don't have this */
+	_check_sys_dev_block();
+
 	if (!(f = zalloc(sizeof(*f))))
 		goto_bad;
 


