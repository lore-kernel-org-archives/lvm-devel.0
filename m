From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:30 +0000 (UTC)
Subject: master - dev-cache: fix mem corruption on refresh context
Message-ID: <20140325102330.A6A5A60D8D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68d13b2517b49f53e395ea7754c6b8cf0b57dc0e
Commit:        68d13b2517b49f53e395ea7754c6b8cf0b57dc0e
Parent:        d29fe919e6a4000d0d78d2f3c88b291a303b82ac
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 10:53:42 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:57 2014 +0100

dev-cache: fix mem corruption on refresh context

When lvm2 command works with clvmd and uses locking in wrong way,
it may 'leak' certain file descriptors in opened (incorrect) state.

dev_cache_exit then destroys memory pool of cached devices, while
_open_devices list in dev-io.c was still referencing them if they
were still opened.

Patch properly calls _close() function to 'self-heal' from this
invalid state, but it will report internal error (so execution
with abort_on_internal_error causes immediate death). On the
normal 'execution', error is only reported, but memory state is
corrected, and linked list is not referencing devices from
released mempool.

For crash see: https://bugzilla.redhat.com/show_bug.cgi?id=1073886
---
 WHATS_NEW                  |    1 +
 lib/commands/toolcontext.c |    3 ++-
 lib/device/dev-cache.c     |   33 ++++++++++++++++++++++++++-------
 lib/device/dev-cache.h     |    3 ++-
 4 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4448717..a1eb7ed 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix memory corruption in cmd context refresh if clvmd leaks opened device.
   Reinitialise lvmcache properly on fork to fix premature polldaemon exit.
   Add 'lvm dumpconfig --type diff' to show differences from defaults.
   Fix swap signature detection for devices smaller then 2MB.
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index f0c0201..0c59ea0 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1604,7 +1604,8 @@ int refresh_toolcontext(struct cmd_context *cmd)
 		cmd->filter->destroy(cmd->filter);
 		cmd->filter = NULL;
 	}
-	dev_cache_exit();
+	if (!dev_cache_exit())
+		stack;
 	_destroy_dev_types(cmd);
 	_destroy_tags(cmd);
 
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 87d2f58..94052dc 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -760,21 +760,38 @@ int dev_cache_init(struct cmd_context *cmd)
 	return 0;
 }
 
-static void _check_closed(struct device *dev)
+static int _check_for_open_devices(int close_immediate)
 {
-	if (dev->fd >= 0)
-		log_error("Device '%s' has been left open.", dev_name(dev));
+	struct device *dev;
+	struct dm_hash_node *n;
+	int r = 0;
+
+	dm_hash_iterate(n, _cache.names) {
+		dev = (struct device *) dm_hash_get_data(_cache.names, n);
+		if (dev->fd >= 0) {
+			log_error("Device '%s' has been left open (%d).",
+				  dev_name(dev), dev->open_count);
+			r++;
+			if (close_immediate)
+				dev_close_immediate(dev);
+		}
+	}
+
+	return r;
 }
 
-static void _check_for_open_devices(void)
+int dev_cache_check_for_open_devices(void)
 {
-	dm_hash_iter(_cache.names, (dm_hash_iterate_fn) _check_closed);
+	return _check_for_open_devices(0);
 }
 
-void dev_cache_exit(void)
+int dev_cache_exit(void)
 {
+	int cnt = 0;
+
 	if (_cache.names)
-		_check_for_open_devices();
+		if ((cnt = _check_for_open_devices(1)) > 0)
+			log_error(INTERNAL_ERROR "%d device(s) have been closed.", cnt);
 
 	if (_cache.preferred_names_matcher)
 		_cache.preferred_names_matcher = NULL;
@@ -793,6 +810,8 @@ void dev_cache_exit(void)
 	_cache.has_scanned = 0;
 	dm_list_init(&_cache.dirs);
 	dm_list_init(&_cache.files);
+
+	return (cnt == 0);
 }
 
 int dev_cache_add_dir(const char *path)
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 0d342c5..c18d5f6 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -36,7 +36,8 @@ struct dev_filter {
  */
 struct cmd_context;
 int dev_cache_init(struct cmd_context *cmd);
-void dev_cache_exit(void);
+int dev_cache_check_for_open_devices(void);
+int dev_cache_exit(void);
 
 /* Trigger(1) or avoid(0) a scan */
 void dev_cache_scan(int do_scan);


