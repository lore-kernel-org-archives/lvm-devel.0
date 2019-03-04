From: David Teigland <teigland@sourceware.org>
Date: Mon, 4 Mar 2019 12:27:26 -0500
Subject: stable-2.02 - io: warn when metadata size approaches io memory size
Message-ID: <201903041727.x24HRQ7k005062@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=863a2e693ee95b95463d60fa8b21f4c7c084292c
Commit:        863a2e693ee95b95463d60fa8b21f4c7c084292c
Parent:        8dbfdb5b737cf916a8b95b8d19eec67a960a6392
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 4 10:57:52 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 4 10:57:52 2019 -0600

io: warn when metadata size approaches io memory size

When a single copy of metadata gets within 1MB of the
current io_memory_size value, begin printing a warning
that the io_memory_size should be increased.
---
 lib/cache/lvmcache.c          |   15 +++++++++++++++
 lib/cache/lvmcache.h          |    3 +++
 lib/format_text/format-text.c |    4 ++++
 lib/label/label.c             |   41 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 63 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a2ee0cd..ad40d4c 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -3044,3 +3044,18 @@ int lvmcache_scan_mismatch(struct cmd_context *cmd, const char *vgname, const ch
 	return 1;
 }
 
+static uint64_t _max_metadata_size;
+
+void lvmcache_save_metadata_size(uint64_t val)
+{
+	if (!_max_metadata_size)
+		_max_metadata_size = val;
+	else if (_max_metadata_size < val)
+		_max_metadata_size = val;
+}
+
+uint64_t lvmcache_max_metadata_size(void)
+{
+	return _max_metadata_size;
+}
+
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index bf976e9..f436785 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -225,4 +225,7 @@ struct volume_group *lvmcache_get_saved_vg(const char *vgid, int precommitted);
 struct volume_group *lvmcache_get_saved_vg_latest(const char *vgid);
 void lvmcache_drop_saved_vgid(const char *vgid);
 
+uint64_t lvmcache_max_metadata_size(void);
+void lvmcache_save_metadata_size(uint64_t val);
+
 #endif
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4160ba8..b9d85a4 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1294,6 +1294,10 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	 */
 	vgsummary->mda_checksum = rlocn->checksum;
 	vgsummary->mda_size = rlocn->size;
+
+	/* Keep track of largest metadata size we find. */
+	lvmcache_save_metadata_size(rlocn->size);
+
 	lvmcache_lookup_mda(vgsummary);
 
 	if (!text_read_metadata_summary(fmt, dev_area->dev, MDA_CONTENT_REASON(primary_mda),
diff --git a/lib/label/label.c b/lib/label/label.c
index b94fd8d..e96a7fe 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -21,6 +21,7 @@
 #include "bcache.h"
 #include "toolcontext.h"
 #include "activate.h"
+#include "metadata.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -29,6 +30,8 @@
 
 int use_full_md_check;
 
+static uint64_t _current_bcache_size_bytes;
+
 /* FIXME Allow for larger labels?  Restricted to single sector currently */
 
 /*
@@ -806,6 +809,8 @@ static int _setup_bcache(int num_devs)
 	if (cache_blocks > MAX_BCACHE_BLOCKS)
 		cache_blocks = MAX_BCACHE_BLOCKS;
 
+	_current_bcache_size_bytes = cache_blocks * BCACHE_BLOCK_SIZE_IN_SECTORS * 512;
+
 	if (use_aio()) {
 		if (!(ioe = create_async_io_engine())) {
 			log_warn("Failed to set up async io, using sync io.");
@@ -839,6 +844,7 @@ int label_scan(struct cmd_context *cmd)
 	struct dev_iter *iter;
 	struct device_list *devl, *devl2;
 	struct device *dev;
+	uint64_t max_metadata_size_bytes;
 
 	log_debug_devs("Finding devices to scan");
 
@@ -909,6 +915,41 @@ int label_scan(struct cmd_context *cmd)
 
 	_scan_list(cmd, cmd->full_filter, &all_devs, NULL);
 
+	/*
+	 * Metadata could be larger than total size of bcache, and bcache
+	 * cannot currently be resized during the command.  If this is the
+	 * case (or within reach), warn that io_memory_size needs to be
+	 * set larger.
+	 *
+	 * Even if bcache out of space did not cause a failure during scan, it
+	 * may cause a failure during the next vg_read phase or during vg_write.
+	 *
+	 * If there was an error during scan, we could recreate bcache here
+	 * with a larger size and then restart label_scan.  But, this does not
+	 * address the problem of writing new metadata that excedes the bcache
+	 * size and failing, which would often be hit first, i.e. we'll fail
+	 * to write new metadata exceding the max size before we have a chance
+	 * to read any metadata with that size, unless we find an existing vg
+	 * that has been previously created with the larger size.
+	 *
+	 * If the largest metadata is within 1MB of the bcache size, then start
+	 * warning.
+	 */
+	max_metadata_size_bytes = lvmcache_max_metadata_size();
+
+	if (max_metadata_size_bytes + (1024 * 1024) > _current_bcache_size_bytes) {
+		/* we want bcache to be 1MB larger than the max metadata seen */
+		uint64_t want_size_kb = (max_metadata_size_bytes / 1024) + 1024;
+		uint64_t remainder;
+		if ((remainder = (want_size_kb % 1024)))
+			want_size_kb = want_size_kb + 1024 - remainder;
+
+		log_warn("WARNING: metadata may not be usable with current io_memory_size %d KiB",
+			 io_memory_size());
+		log_warn("WARNING: increase lvm.conf io_memory_size to at least %llu KiB",
+			 (unsigned long long)want_size_kb);
+	}
+
 	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
 		dm_list_del(&devl->list);
 		dm_free(devl);


