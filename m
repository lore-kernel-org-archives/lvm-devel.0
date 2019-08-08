From: David Teigland <teigland@sourceware.org>
Date: Thu, 8 Aug 2019 16:45:55 -0400
Subject: master - increase soft open file limit
Message-ID: <201908082045.x78Kjtv1013858@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ecefcc9ca89982dbc5cc6b210da7ca9d0fef655b
Commit:        ecefcc9ca89982dbc5cc6b210da7ca9d0fef655b
Parent:        eb6aa5fefee0793bf4122640a2a53ed70602e4cc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 8 13:11:05 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 8 15:45:03 2019 -0500

increase soft open file limit

When there are more devices than the current soft
open file limit (default 1024), raise the soft limit
to the hard/max limit (default 4096).

Do this prior to scanning in case enough of the
devices are PVs that need to be kept open.
---
 lib/label/label.c |   61 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 61 insertions(+), 0 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 5d8a0f5..9454fc8 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -29,6 +29,7 @@
 #include <fcntl.h>
 #include <unistd.h>
 #include <sys/types.h>
+#include <sys/resource.h>
 
 /* FIXME Allow for larger labels?  Restricted to single sector currently */
 
@@ -860,6 +861,57 @@ static void _free_hints(struct dm_list *hints)
 }
 
 /*
+ * We don't know how many of num_devs will be PVs that we need to
+ * keep open, but if it's greater than the soft limit, then we'll
+ * need the soft limit raised, so do that before starting.
+ *
+ * If opens approach the raised soft/hard limit while scanning, then
+ * we could also attempt to raise the soft/hard limits during the scan.
+ */
+
+#define BASE_FD_COUNT 32 /* Number of open files we want apart from devs */
+
+static void _prepare_open_file_limit(struct cmd_context *cmd, unsigned int num_devs)
+{
+	struct rlimit old, new;
+	unsigned int want = num_devs + BASE_FD_COUNT;
+	int rv;
+
+	rv = prlimit(0, RLIMIT_NOFILE, NULL, &old);
+	if (rv < 0) {
+		log_debug("Checking fd limit for num_devs %u failed %d", num_devs, errno);
+		return;
+	}
+
+	log_debug("Checking fd limit for num_devs %u want %u soft %lld hard %lld",
+		  num_devs, want, (long long)old.rlim_cur, (long long)old.rlim_max);
+
+	/* Current soft limit is enough */
+	if (old.rlim_cur > want)
+		return;
+
+	/* Soft limit already raised to max */
+	if (old.rlim_cur == old.rlim_max)
+		return;
+
+	/* Raise soft limit up to hard/max limit */
+	new.rlim_cur = old.rlim_max;
+	new.rlim_max = old.rlim_max;
+
+	log_debug("Setting fd limit for num_devs %u soft %lld hard %lld",
+		  num_devs, (long long)new.rlim_cur, (long long)new.rlim_max);
+
+	rv = prlimit(0, RLIMIT_NOFILE, &new, &old);
+	if (rv < 0) {
+		if (errno == EPERM)
+			log_warn("WARNING: permission error setting open file limit for scanning %u devices.", num_devs);
+		else
+			log_warn("WARNING: cannot set open file limit for scanning %u devices.", num_devs);
+		return;
+	}
+}
+
+/*
  * Scan devices on the system to discover which are LVM devices.
  * Info about the LVM devices (PVs) is saved in lvmcache in a
  * basic/summary form (info/vginfo structs).  The vg_read phase
@@ -977,6 +1029,15 @@ int label_scan(struct cmd_context *cmd)
 	log_debug("Will scan %d devices skip %d", dm_list_size(&scan_devs), dm_list_size(&all_devs));
 
 	/*
+	 * If the total number of devices exceeds the soft open file
+	 * limit, then increase the soft limit to the hard/max limit
+	 * in case the number of PVs in scan_devs (it's only the PVs
+	 * which we want to keep open) is higher than the current
+	 * soft limit.
+	 */
+	_prepare_open_file_limit(cmd, dm_list_size(&scan_devs));
+
+	/*
 	 * Do the main scan.
 	 */
 	_scan_list(cmd, cmd->filter, &scan_devs, NULL);


