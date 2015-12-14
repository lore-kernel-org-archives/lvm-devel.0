From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 14 Dec 2015 16:02:49 +0000 (UTC)
Subject: master - process_each_pv: do full scan earlier to find new devices
Message-ID: <20151214160249.099D560ECF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92e14227074f70eb824a93023a7dbc7cafb0e4f3
Commit:        92e14227074f70eb824a93023a7dbc7cafb0e4f3
Parent:        1be56e46c442d1fa25d6ae5b6c889372685073d5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 11 14:02:36 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 14 10:02:29 2015 -0600

process_each_pv: do full scan earlier to find new devices

Before commit c1f246fedfc349c25749da501e68a7f70bd122b0,
_get_all_devices() did a full device scan before
get_vgnameids() was called.  The full scan in
_get_all_devices() is from calling dev_iter_create(f, 1).
The '1' arg forces a full scan.

By doing a full scan in _get_all_devices(), new devices
were added to dev-cache before get_vgnameids() began
scanning labels.  So, labels would be read from new devices.
(e.g. by the first 'pvs' command after the new device appeared.)

After that commit, _get_all_devices() was called
after get_vgnameids() was finished scanning labels.
So, new devices would be missed while scanning labels.
When _get_all_devices() saw the new devices (after
labels were scanned), those devices were added to
the .cache file.  This meant that the second 'pvs'
command would see the devices because they would be
in .cache.

Now, the full device scan is factored out of
_get_all_devices() and called by itself at the
start of the command so that new devices will
be known before get_vgnameids() scans labels.
---
 lib/cache/lvmcache.c   |    9 ++++++++-
 lib/device/dev-cache.c |   20 ++++++++++++--------
 lib/device/dev-cache.h |    1 +
 tools/toollib.c        |    7 +++++++
 4 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 799de6f..2a01ec2 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -749,6 +749,7 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 	struct dev_iter *iter;
 	struct device *dev;
 	struct format_type *fmt;
+	int dev_count = 0;
 
 	int r = 0;
 
@@ -779,11 +780,17 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 		goto out;
 	}
 
-	while ((dev = dev_iter_get(iter)))
+	log_very_verbose("Scanning device labels");
+
+	while ((dev = dev_iter_get(iter))) {
 		(void) label_read(dev, &label, UINT64_C(0));
+		dev_count++;
+	}
 
 	dev_iter_destroy(iter);
 
+	log_very_verbose("Scanned %d device labels", dev_count);
+
 	_has_scanned = 1;
 
 	/* Perform any format-specific scanning e.g. text files */
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 7626ceb..97165db 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1026,6 +1026,16 @@ struct device *dev_cache_get_by_devt(dev_t dev, struct dev_filter *f)
 		      f->passes_filter(f, d))) ? d : NULL;
 }
 
+void dev_cache_full_scan(struct dev_filter *f)
+{
+	if (f && f->wipe) {
+		f->wipe(f); /* might call _full_scan(1) */
+		if (!full_scan_done())
+			_full_scan(1);
+	} else
+		_full_scan(1);
+}
+
 struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 {
 	struct dev_iter *di = dm_malloc(sizeof(*di));
@@ -1037,14 +1047,8 @@ struct dev_iter *dev_iter_create(struct dev_filter *f, int dev_scan)
 
 	if (dev_scan && !trust_cache()) {
 		/* Flag gets reset between each command */
-		if (!full_scan_done()) {
-			if (f && f->wipe) {
-				f->wipe(f); /* might call _full_scan(1) */
-				if (!full_scan_done())
-					_full_scan(1);
-			} else
-				_full_scan(1);
-		}
+		if (!full_scan_done())
+			dev_cache_full_scan(f);
 	} else
 		_full_scan(0);
 
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 4fca358..4efe41f 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -45,6 +45,7 @@ int dev_cache_check_for_open_devices(void);
 /* Trigger(1) or avoid(0) a scan */
 void dev_cache_scan(int do_scan);
 int dev_cache_has_scanned(void);
+void dev_cache_full_scan(struct dev_filter *f);
 
 int dev_cache_add_dir(const char *path);
 int dev_cache_add_loopfile(const char *path);
diff --git a/tools/toollib.c b/tools/toollib.c
index e03aaf7..fb6edad 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3340,6 +3340,13 @@ int process_each_pv(struct cmd_context *cmd,
 		return_ECMD_FAILED;
 
 	/*
+	 * This full scan would be done by _get_all_devices() if
+	 * it were not done here first.  It's called here first
+	 * so that get_vgnameids() will look at any new devices.
+	 */
+	dev_cache_full_scan(cmd->full_filter);
+
+	/*
 	 * Need pvid's set on all PVs before processing so that pvid's
 	 * can be compared to find duplicates while processing.
 	 */


