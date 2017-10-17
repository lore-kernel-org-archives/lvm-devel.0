From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 16 Oct 2017 21:19:48 -0400
Subject: master - device: Separate errors for dev not found and filtered.
Message-ID: <201710170119.v9H1Jmrr010627@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=146745ad88abc0512650b5b40d00ca587784ca36
Commit:        146745ad88abc0512650b5b40d00ca587784ca36
Parent:        1f359f7558b5ae7750fa629575426ae110781566
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Oct 17 02:12:41 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 17 02:12:41 2017 +0100

device: Separate errors for dev not found and filtered.

Replaced the confusing device error message "not found (or ignored by
filtering)" by either "not found" or "excluded by a filter".
(Later we should be able to say which filter.)

Left the the liblvm code paths alone.
---
 WHATS_NEW               |    1 +
 lib/device/dev-cache.c  |   13 +++++++++++++
 lib/device/dev-cache.h  |    1 +
 lib/metadata/metadata.c |    3 +--
 tools/toollib.c         |    4 ++--
 5 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4ad6b1f..665517b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Distinguish between device not found and excluded by filter.
   Monitor external origin LVs.
   Remove the replicator code, including configure --with-replicators.
   Allow lvcreate --type mirror to work with 100%FREE.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 7802e45..83c2b12 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1370,6 +1370,19 @@ const char *dev_name_confirmed(struct device *dev, int quiet)
 	return dev_name(dev);
 }
 
+/* Provide a custom reason when a device is ignored */
+const char *dev_cache_filtered_reason(const char *name)
+{
+	const char *reason = "not found";
+	struct device *d = (struct device *) dm_hash_lookup(_cache.names, name);
+
+	if (d)
+		/* FIXME Record which filter caused the exclusion */
+		reason = "excluded by a filter";
+
+	return reason;
+}
+
 struct device *dev_cache_get(const char *name, struct dev_filter *f)
 {
 	struct stat buf;
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 0406970..546b1fe 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -55,6 +55,7 @@ int dev_cache_add_dir(const char *path);
 int dev_cache_add_loopfile(const char *path);
 __attribute__((nonnull(1)))
 struct device *dev_cache_get(const char *name, struct dev_filter *f);
+const char *dev_cache_filtered_reason(const char *name);
 
 // TODO
 struct device *dev_cache_get_by_devt(dev_t device, struct dev_filter *f);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1606b39..496dbee 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5488,8 +5488,7 @@ int pv_analyze(struct cmd_context *cmd, const char *pv_name,
 
 	dev = dev_cache_get(pv_name, cmd->filter);
 	if (!dev) {
-		log_error("Device %s not found (or ignored by filtering).",
-			  pv_name);
+		log_error("Device %s %s.", pv_name, dev_cache_filtered_reason(pv_name));
 		return 0;
 	}
 
diff --git a/tools/toollib.c b/tools/toollib.c
index b28167b..fc615f3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5532,7 +5532,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * Check if all arg_devices were found by process_each_pv.
 	 */
 	dm_list_iterate_items(pd, &pp->arg_devices)
-		log_error("Device %s not found (or ignored by filtering).", pd->name);
+		log_error("Device %s %s.", pd->name, dev_cache_filtered_reason(pd->name));
 
 	/*
 	 * Can the command continue if some specified devices were not found?
@@ -5652,7 +5652,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle, _pv_confirm_single);
 
 	dm_list_iterate_items(pd, &pp->arg_confirm)
-		log_error("Device %s not found (or ignored by filtering).", pd->name);
+		log_error("Device %s %s.", pd->name, dev_cache_filtered_reason(pd->name));
 
 	/* Some devices were not found during the second check. */
 	if (!dm_list_empty(&pp->arg_confirm) && must_use_all)


