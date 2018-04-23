From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:50:35 -0400
Subject: master - [io paths] Unpick agk's aio stuff
Message-ID: <201804231350.w3NDoZda031931@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00f1b208a1bf44665ec97a791355b1fcf525a3a7
Commit:        00f1b208a1bf44665ec97a791355b1fcf525a3a7
Parent:        d51429254f4e9b17083af0c554aa7045e5ec08bb
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Apr 20 10:43:50 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:03:58 2018 -0500

[io paths] Unpick agk's aio stuff

---
 conf/example.conf.in            |   16 -
 configure.in                    |   22 --
 doc/aio_design.txt              |  215 --------------
 include/configure.h.in          |    3 -
 lib/cache/lvmcache.c            |   51 +---
 lib/cache/lvmcache.h            |    2 +-
 lib/cache/lvmetad.c             |    2 +-
 lib/commands/toolcontext.c      |   16 +-
 lib/commands/toolcontext.h      |    1 -
 lib/config/config.c             |  154 ++++-------
 lib/config/config.h             |    8 +-
 lib/config/config_settings.h    |   10 -
 lib/config/defaults.h           |    3 -
 lib/device/dev-cache.c          |   12 -
 lib/device/dev-cache.h          |    8 +-
 lib/device/dev-io.c             |  600 ++++++---------------------------------
 lib/device/dev-luks.c           |    2 +-
 lib/device/dev-md.c             |    2 +-
 lib/device/dev-swap.c           |    3 +-
 lib/device/dev-type.c           |    2 +-
 lib/device/device.h             |  102 ++-----
 lib/filters/filter-composite.c  |    4 +-
 lib/filters/filter-persistent.c |    8 +-
 lib/filters/filter.h            |    2 +-
 lib/format1/disk-rep.c          |   10 +-
 lib/format1/format1.c           |    2 +-
 lib/format1/lvm1-label.c        |   19 +-
 lib/format_pool/disk_rep.c      |    2 +-
 lib/format_pool/format_pool.c   |    2 +-
 lib/format_pool/pool_label.c    |   13 +-
 lib/format_text/archive.c       |    4 +-
 lib/format_text/archiver.c      |    2 +-
 lib/format_text/export.c        |   21 +-
 lib/format_text/format-text.c   |  541 ++++++++++-------------------------
 lib/format_text/import-export.h |    8 +-
 lib/format_text/import.c        |  233 +++++-----------
 lib/format_text/layout.h        |   12 +-
 lib/format_text/text_label.c    |  197 +++----------
 lib/label/label.c               |  173 ++++--------
 lib/label/label.h               |    6 +-
 lib/metadata/metadata-liblvm.c  |    3 +-
 lib/metadata/metadata.c         |    8 +-
 lib/metadata/metadata.h         |    5 +-
 make.tmpl.in                    |    3 +-
 tools/command.c                 |   11 +-
 tools/toollib.c                 |    1 -
 46 files changed, 565 insertions(+), 1959 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 3b0638f..aab274d 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -59,22 +59,6 @@ devices {
 	# This configuration option is advanced.
 	scan = [ "/dev" ]
 
-	# Configuration option devices/use_aio.
-	# Use linux asynchronous I/O for parallel device access where possible.
-	# This configuration option has an automatic default value.
-	# use_aio = 1
-
-	# Configuration option devices/aio_max.
-	# Maximum number of asynchronous I/Os to issue concurrently.
-	# This configuration option has an automatic default value.
-	# aio_max = 128
-
-	# Configuration option devices/aio_memory.
-	# Approximate maximum total amount of memory (in MB) used
-	# for asynchronous I/O buffers.
-	# This configuration option has an automatic default value.
-	# aio_memory = 10
-
 	# Configuration option devices/obtain_device_list_from_udev.
 	# Obtain the list of available devices from udev.
 	# This avoids opening or using any inapplicable non-block devices or
diff --git a/configure.in b/configure.in
index 605b6b2..b8e1623 100644
--- a/configure.in
+++ b/configure.in
@@ -39,7 +39,6 @@ case "$host_os" in
 		LDDEPS="$LDDEPS .export.sym"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
-		AIO=yes
 		BUILD_LVMETAD=no
 		BUILD_LVMPOLLD=no
 		LOCKDSANLOCK=no
@@ -59,7 +58,6 @@ case "$host_os" in
 		CLDNOWHOLEARCHIVE=
 		LIB_SUFFIX=dylib
 		DEVMAPPER=yes
-		AIO=no
 		ODIRECT=no
 		DM_IOCTLS=no
 		SELINUX=no
@@ -1125,24 +1123,6 @@ if test "$DEVMAPPER" = yes; then
 fi
 
 ################################################################################
-dnl -- Disable aio
-AC_MSG_CHECKING(whether to use asynchronous I/O)
-AC_ARG_ENABLE(aio,
-	      AC_HELP_STRING([--disable-aio],
-			     [disable asynchronous I/O]),
-	      AIO=$enableval)
-AC_MSG_RESULT($AIO)
-
-if test "$AIO" = yes; then
-	AC_CHECK_LIB(aio, io_setup,
-		[AC_DEFINE([AIO_SUPPORT], 1, [Define to 1 if aio is available.])
-		AIO_LIBS="-laio"
-		AIO_SUPPORT=yes],
-		[AIO_LIBS=
-		AIO_SUPPORT=no ])
-fi
-
-################################################################################
 dnl -- Build lvmetad
 AC_MSG_CHECKING(whether to build LVMetaD)
 AC_ARG_ENABLE(lvmetad,
@@ -2081,11 +2061,9 @@ AC_SUBST(DEFAULT_USE_LVMETAD)
 AC_SUBST(DEFAULT_USE_LVMPOLLD)
 AC_SUBST(DEFAULT_USE_LVMLOCKD)
 AC_SUBST(DEVMAPPER)
-AC_SUBST(AIO)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)
 AC_SUBST(DL_LIBS)
-AC_SUBST(AIO_LIBS)
 AC_SUBST(DMEVENTD_PATH)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
diff --git a/doc/aio_design.txt b/doc/aio_design.txt
deleted file mode 100644
index c6eb443..0000000
--- a/doc/aio_design.txt
+++ /dev/null
@@ -1,215 +0,0 @@
-Introducing asynchronous I/O to LVM
-===================================
-
-Issuing I/O asynchronously means instructing the kernel to perform specific
-I/O and return immediately without waiting for it to complete.  The data
-is collected from the kernel later.
-
-Advantages
-----------
-
-A1. While waiting for the I/O to happen, the program could perform other
-operations.
-
-A2. When LVM is searching for its Physical Volumes, it issues a small amount of
-I/O to a large number of disks.  If this was issued in parallel the overall
-runtime might be shorter while there should be little effect on the cpu time.
-
-A3. If more than one timeout occurs when accessing any devices, these can be
-taken in parallel, again reducing the runtime.  This applies globally,
-not just while the code is searching for Physical Volumes, so reading,
-writing and committing the metadata may occasionally benefit too to some
-extent and there are probably maintenance advantages in using the same
-method of I/O throughout the main body of the code.
-
-A4. By introducing a simple callback function mechanism, the conversion can be
-performed largely incrementally by first refactoring and continuing to
-use synchronous I/O with the callbacks performed immediately.  This allows the
-callbacks to be introduced without changing the running sequence of the code
-initially.  Future projects could refactor some of the calling sites to
-simplify the code structure and even eliminate some of the nesting.
-This allows each part of what might ultimately amount to a large change to be
-introduced and tested independently.
-
-
-Disadvantages
--------------
-
-D1. The resulting code may be more complex with more failure modes to
-handle.  Mitigate by thorough auditing and testing, rolling out
-gradually, and offering a simple switch to revert to the old behaviour.
-
-D2. The linux asynchronous I/O implementation is less mature than
-its synchronous I/O implementation and might show up problems that
-depend on the version of the kernel or library used.  Fixes or
-workarounds for some of these might require kernel changes.  For
-example, there are suggestions that despite being supposedly async,
-there are still cases where system calls can block.  There might be
-resource dependencies on other processes running on the system that make
-it unsuitable for use while any devices are suspended.  Mitigation
-as for D1.
-
-D3. The error handling within callbacks becomes more complicated.
-However we know that existing call paths can already sometimes discard
-errors, sometimes deliberately, sometimes not, so this aspect is in need
-of a complete review anyway and the new approach will make the error
-handling more transparent.  Aim initially for overall behaviour that is
-no worse than that of the existing code, then work on improving it
-later.
-
-D4. The work will take a few weeks to code and test.  This leads to a
-significant opportunity cost when compared against other enhancements
-that could be achieved in that time.  However, the proof-of-concept work
-performed while writing this design has satisfied me that the work could
-proceed and be committed incrementally as a background task.
-
-
-Observations regarding LVM's I/O Architecture 
----------------------------------------------
-
-H1. All device, metadata and config file I/O is constrained to pass through a
-single route in lib/device.
-
-H2. The first step of the analysis was to instrument this code path with
-log_debug messages.  I/O is split into the following categories:
-
-        "dev signatures",
-        "PV labels",
-        "VG metadata header",
-        "VG metadata content",
-        "extra VG metadata header",
-        "extra VG metadata content",
-        "LVM1 metadata",
-        "pool metadata",
-        "LV content",
-        "logging",
-
-H3. A bounce buffer is used for most I/O.
-
-H4. Most callers finish using the supplied data before any further I/O is
-issued.  The few that don't could be converted trivially to do so.
-
-H5. There is one stream of I/O per metadata area on each device.
-
-H6. Some reads fall at offsets close to immediately preceding reads, so it's
-possible to avoid these by caching one "block" per metadata area I/O stream.
-
-H7. Simple analysis suggests a minimum aligned read size of 8k would deliver
-immediate gains from this caching.  A larger size might perform worse because
-almost all the time the extra data read would not be used, but this can be
-re-examined and tuned after the code is in place.
-
-
-Proposal
---------
-
-P1. Retain the "single I/O path" but offer an asynchronous option.
-
-P2. Eliminate the bounce buffer in most cases by improving alignment.
-
-P3. Reduce the number of reads by always reading a minimum of an aligned
-8k block.  
-
-P4. Eliminate repeated reads by caching the last block read and changing
-the lib/device interface to return a pointer to read-only data within
-this block.
-
-P5. Only perform these interface changes for code on the critical path
-for now by converting other code sites to use wrappers around the new
-interface.
-
-P6. Treat asynchronous I/O as the interface of choice and optimise only
-for this case.
-
-P7. Convert the callers on the critical path to pass callback functions
-to the device layer.  These functions will be called later with the
-read-only data, a context pointer and a success/failure indicator.
-Where an existing function performs a sequence of I/O, this has the
-advantage of breaking up the large function into smaller ones and
-wrapping the parameters used into structures.  While this might look
-rather messy and ad-hoc in the short-term, it's a first step towards
-breaking up confusingly long functions into component parts and wrapping
-the existing long parameter lists into more appropriate structures and
-refactoring these parts of the code.
-
-P8. Limit the resources used by the asynchronous I/O by using two
-tunable parameters, one limiting the number of outstanding I/Os issued
-and another limiting the total amount of memory used.
-
-P9. Provide a fallback option if asynchronous I/O is unavailable by
-sharing the code paths but issuing the I/O synchronously and calling the
-callback immediately.
-
-P10. Only allocate the buffer for the I/O at the point where the I/O is
-about to be issued.
-
-P11. If the thresholds are exceeded, add the request to a simple queue,
-and process it later after some I/O has completed.
-
-
-Future work
------------
-F1. Perform a complete review of the error tracking so that device
-failures are handled and reported more cleanly, extending the existing
-basic error counting mechanism.
-
-F2. Consider whether some of the nested callbacks can be eliminated,
-which would allow for additional simplifications.
-
-F3. Adjust the contents of the adhoc context structs into more logical
-arrangements and use them more widely.
-
-F4. Perform wider refactoring of these areas of code.
-
-
-Testing considerations
-----------------------
-T1. The changes touch code on the device path, so a thorough re-test of
-the device layer is required.  The new code needs a full audit down
-through the library layer into the kernel to check that all the error
-conditions that are currently implemented (such as EAGAIN) are handled
-sensibly. (LVM's I/O layer needs to remain as solid as we can make it.)
-
-T2. The current test suite provides a reasonably broad range of coverage
-of this area but is far from comprehensive.
-
-
-Acceptance criteria
--------------------
-A1. The current test suite should pass to the same extent as before the
-changes.
-
-A2. When all debugging and logging is disabled, strace -c must show
-improvements e.g. the expected fewer number of reads.
-
-A3. Running a range of commands under valgrind must not reveal any
-new leaks due to the changes.
-
-A4. All new coverity reports from the change must be addressed.
-
-A5. CPU time should be similar to that before, as the same work
-is being done overall, just in a different order.
-
-A6. Tests need to show improved behaviour in targetted areas.  For example,
-if several devices are slow and time out, the delays should occur
-in parallel and the elapsed time should be less than before.
-
-
-Release considerations
-----------------------
-R1. Async I/O should be widely available and largely reliable on linux
-nowadays (even though parts of its interface and implementation remain a
-matter of controversy) so we should try to make its use the default
-whereever it is supported.  If certain types of systems have problems we
-should try to detect those cases and disable it automatically there.
-
-R2. Because the implications of an unexpected problem in the new code
-could be severe for the people affected, the roll out needs to be gentle
-without a deadline to allow us plenty of time to gain confidence in the
-new code.  Our own testing will only be able to cover a tiny fraction of
-the different setups our users have, so we need to look out for problems
-caused by this proactively and encourage people to test it on their own
-systems and report back.  It must go into the tree near the start of a
-release cycle rather than at the end to provide time for our confidence
-in it to grow.
-
diff --git a/include/configure.h.in b/include/configure.h.in
index a491807..be2f660 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -1,8 +1,5 @@
 /* include/configure.h.in.  Generated from configure.in by autoheader.  */
 
-/* Define to 1 if aio is available. */
-#undef AIO_SUPPORT
-
 /* Define to 1 to use libblkid detection of signatures when wiping. */
 #undef BLKID_WIPING_SUPPORT
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 5ff2827..fb81002 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -141,8 +141,6 @@ void lvmcache_seed_infos_from_lvmetad(struct cmd_context *cmd)
 /* Volume Group metadata cache functions */
 static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 {
-	struct lvmcache_info *info;
-
 	if (!vginfo || !vginfo->vgmetadata)
 		return;
 
@@ -156,10 +154,6 @@ static void _free_cached_vgmetadata(struct lvmcache_vginfo *vginfo)
 		vginfo->cft = NULL;
 	}
 
-	/* Invalidate any cached device buffers */
-	dm_list_iterate_items(info, &vginfo->infos)
-		devbufs_release(info->dev);
-
 	log_debug_cache("lvmcache: VG %s wiped.", vginfo->vgname);
 
 	release_vg(vginfo->cached_vg);
@@ -548,6 +542,7 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 {
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
+	struct label *label;
 	struct dm_list *devh, *tmp;
 	struct dm_list devs;
 	struct device_list *devl;
@@ -592,7 +587,7 @@ const struct format_type *lvmcache_fmt_from_vgname(struct cmd_context *cmd,
 
 	dm_list_iterate_safe(devh, tmp, &devs) {
 		devl = dm_list_item(devh, struct device_list);
-		(void) label_read(devl->dev, NULL, UINT64_C(0));
+		(void) label_read(devl->dev, &label, UINT64_C(0));
 		dm_list_del(&devl->list);
 		dm_free(devl);
 	}
@@ -773,8 +768,10 @@ char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
 
 static void _rescan_entry(struct lvmcache_info *info)
 {
+	struct label *label;
+
 	if (info->status & CACHE_INVALID)
-		(void) label_read(info->dev, NULL, UINT64_C(0));
+		(void) label_read(info->dev, &label, UINT64_C(0));
 }
 
 static int _scan_invalid(void)
@@ -1096,31 +1093,17 @@ next:
 	goto next;
 }
 
-/* Track the number of outstanding label reads */
-/* FIXME Switch to struct and also track failed */
-static void _process_label_data(int failed, unsigned ioflags, void *context, const void *data)
-{
-	int *nr_labels_outstanding = context;
-
-	if (!*nr_labels_outstanding) {
-		log_error(INTERNAL_ERROR "_process_label_data called too many times");
-		return;
-	}
-
-	(*nr_labels_outstanding)--;
-}
-
 int lvmcache_label_scan(struct cmd_context *cmd)
 {
 	struct dm_list del_cache_devs;
 	struct dm_list add_cache_devs;
 	struct lvmcache_info *info;
 	struct device_list *devl;
+	struct label *label;
 	struct dev_iter *iter;
 	struct device *dev;
 	struct format_type *fmt;
 	int dev_count = 0;
-	int nr_labels_outstanding = 0;
 
 	int r = 0;
 
@@ -1159,22 +1142,13 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	_destroy_duplicate_device_list(&_found_duplicate_devs);
 
 	while ((dev = dev_iter_get(iter))) {
-		log_debug_io("Scanning device %s", dev_name(dev));
-		nr_labels_outstanding++;
-		if (!label_read_callback(dev, UINT64_C(0), AIO_SUPPORTED_CODE_PATH, _process_label_data, &nr_labels_outstanding))
-			nr_labels_outstanding--;
+		(void) label_read(dev, &label, UINT64_C(0));
 		dev_count++;
 	}
 
 	dev_iter_destroy(iter);
 
-	while (nr_labels_outstanding) {
-		log_very_verbose("Scanned %d device labels (%d outstanding)", dev_count, nr_labels_outstanding);
-		if (!dev_async_getevents())
-			return_0;
-	}
-
-	log_very_verbose("Scanned %d device labels (%d outstanding)", dev_count, nr_labels_outstanding);
+	log_very_verbose("Scanned %d device labels", dev_count);
 
 	/*
 	 * _choose_preferred_devs() returns:
@@ -1208,7 +1182,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 		dm_list_iterate_items(devl, &add_cache_devs) {
 			log_debug_cache("Rescan preferred device %s for lvmcache", dev_name(devl->dev));
-			(void) label_read(devl->dev, NULL, UINT64_C(0));
+			(void) label_read(devl->dev, &label, UINT64_C(0));
 		}
 
 		dm_list_splice(&_unused_duplicate_devs, &del_cache_devs);
@@ -1228,7 +1202,7 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	 */
 	if (_force_label_scan && cmd->is_long_lived &&
 	    cmd->dump_filter && cmd->full_filter && cmd->full_filter->dump &&
-	    !cmd->full_filter->dump(cmd->full_filter, cmd->mem, 0))
+	    !cmd->full_filter->dump(cmd->full_filter, 0))
 		stack;
 
 	r = 1;
@@ -1529,6 +1503,7 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 				       const char *devname)
 {
 	struct device *dev;
+	struct label *label;
 
 	if (!(dev = dev_cache_get(devname, cmd->filter))) {
 		log_error("%s: Couldn't find device.  Check your filters?",
@@ -1536,7 +1511,7 @@ const char *lvmcache_pvid_from_devname(struct cmd_context *cmd,
 		return NULL;
 	}
 
-	if (!(label_read(dev, NULL, UINT64_C(0))))
+	if (!(label_read(dev, &label, UINT64_C(0))))
 		return NULL;
 
 	return dev->pvid;
@@ -2001,7 +1976,7 @@ int lvmcache_add_orphan_vginfo(const char *vgname, struct format_type *fmt)
 	return _lvmcache_update_vgname(NULL, vgname, vgname, 0, "", fmt);
 }
 
-int lvmcache_update_vgname_and_id(struct lvmcache_info *info, const struct lvmcache_vgsummary *vgsummary)
+int lvmcache_update_vgname_and_id(struct lvmcache_info *info, struct lvmcache_vgsummary *vgsummary)
 {
 	const char *vgname = vgsummary->vgname;
 	const char *vgid = (char *)&vgsummary->vgid;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 3c76b78..847c208 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -85,7 +85,7 @@ void lvmcache_del(struct lvmcache_info *info);
 
 /* Update things */
 int lvmcache_update_vgname_and_id(struct lvmcache_info *info,
-				  const struct lvmcache_vgsummary *vgsummary);
+				  struct lvmcache_vgsummary *vgsummary);
 int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted);
 
 void lvmcache_lock_vgname(const char *vgname, int read_only);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 589b48e..4b7410c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1771,7 +1771,7 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 	struct volume_group *vg;
 
 	if (mda_is_ignored(mda) ||
-	    !(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1, 0)))
+	    !(vg = mda->ops->vg_read(b->fid, "", mda, NULL, NULL, 1)))
 		return 1;
 
 	/* FIXME Also ensure contents match etc. */
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index b613b8f..c998495 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -636,16 +636,6 @@ static int _process_config(struct cmd_context *cmd)
 	 */
 	cmd->default_settings.udev_fallback = udev_disabled ? 1 : -1;
 
-#ifdef AIO_SUPPORT
-	cmd->use_aio = find_config_tree_bool(cmd, devices_use_aio_CFG, NULL);
-#else
-	cmd->use_aio = 0;
-#endif
-	if (cmd->use_aio && !dev_async_setup(cmd))
-		cmd->use_aio = 0;
-
-	log_debug_io("%ssing asynchronous I/O.", cmd->use_aio ? "U" : "Not u");
-
 	init_retry_deactivation(find_config_tree_bool(cmd, activation_retry_deactivation_CFG, NULL));
 
 	init_activation_checks(find_config_tree_bool(cmd, activation_checks_CFG, NULL));
@@ -1298,7 +1288,7 @@ int init_filters(struct cmd_context *cmd, unsigned load_persistent_cache)
 		lvm_stat_ctim(&ts, &st);
 		cts = config_file_timestamp(cmd->cft);
 		if (timespeccmp(&ts, &cts, >) &&
-		    !persistent_filter_load(cmd->mem, cmd->filter, NULL))
+		    !persistent_filter_load(cmd->filter, NULL))
 			log_verbose("Failed to load existing device cache from %s",
 				    dev_cache);
 	}
@@ -2160,8 +2150,6 @@ int refresh_toolcontext(struct cmd_context *cmd)
 
 	cmd->lib_dir = NULL;
 
-	label_init();
-
 	if (!_init_lvm_conf(cmd))
 		return_0;
 
@@ -2249,7 +2237,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	int flags;
 
 	if (cmd->dump_filter && cmd->filter && cmd->filter->dump &&
-	    !cmd->filter->dump(cmd->filter, cmd->mem, 1))
+	    !cmd->filter->dump(cmd->filter, 1))
 		stack;
 
 	archive_exit(cmd);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 89d1088..f04afec 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -165,7 +165,6 @@ struct cmd_context {
 	unsigned vg_notify:1;
 	unsigned lv_notify:1;
 	unsigned pv_notify:1;
-	unsigned use_aio:1;
 	unsigned activate_component:1;		/* command activates component LV */
 	unsigned process_component_lvs:1;	/* command processes also component LVs */
 
diff --git a/lib/config/config.c b/lib/config/config.c
index 97c5db8..8fca372 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -279,7 +279,7 @@ struct dm_config_tree *config_file_open_and_read(const char *config_file,
 	}
 
 	log_very_verbose("Loading config file: %s", config_file);
-	if (!config_file_read(cmd->mem, cft)) {
+	if (!config_file_read(cft)) {
 		log_error("Failed to load config file %s", config_file);
 		goto bad;
 	}
@@ -489,102 +489,32 @@ int override_config_tree_from_profile(struct cmd_context *cmd,
 	return 0;
 }
 
-struct process_config_file_params {
-	struct dm_config_tree *cft;
-	struct device *dev;
-	off_t offset;
-	size_t size;
-	off_t offset2;
-	size_t size2;
-	checksum_fn_t checksum_fn;
-	uint32_t checksum;
-	int checksum_only;
-	int no_dup_node_check;
-	lvm_callback_fn_t config_file_read_fd_callback;
-	void *config_file_read_fd_context;
-	int ret;
-};
-
-static void _process_config_file_buffer(int failed, unsigned ioflags, void *context, const void *data)
-{
-	struct process_config_file_params *pcfp = context;
-	const char *fb = data, *fe;
-
-	if (failed) {
-		pcfp->ret = 0;
-		goto_out;
-	}
-
-	if (pcfp->checksum_fn && pcfp->checksum !=
-	    (pcfp->checksum_fn(pcfp->checksum_fn(INITIAL_CRC, (const uint8_t *)fb, pcfp->size),
-			 (const uint8_t *)(fb + pcfp->size), pcfp->size2))) {
-		log_error("%s: Checksum error at offset %" PRIu64, dev_name(pcfp->dev), (uint64_t) pcfp->offset);
-		pcfp->ret = 0;
-		goto out;
-	}
-
-	if (!pcfp->checksum_only) {
-		fe = fb + pcfp->size + pcfp->size2;
-		if (pcfp->no_dup_node_check) {
-			if (!dm_config_parse_without_dup_node_check(pcfp->cft, fb, fe))
-				pcfp->ret = 0;
-		} else if (!dm_config_parse(pcfp->cft, fb, fe))
-			pcfp->ret = 0;
-	}
-
-out:
-	if (pcfp->config_file_read_fd_callback)
-		pcfp->config_file_read_fd_callback(!pcfp->ret, ioflags, pcfp->config_file_read_fd_context, NULL);
-}
-
 /*
  * When checksum_only is set, the checksum of buffer is only matched
  * and function avoids parsing of mda into config tree which
  * remains unmodified and should not be used.
  */
-int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
+int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
-			int checksum_only, int no_dup_node_check, unsigned ioflags,
-			lvm_callback_fn_t config_file_read_fd_callback, void *config_file_read_fd_context)
+			int checksum_only, int no_dup_node_check)
 {
-	char *fb;
+	char *fb, *fe;
 	int r = 0;
-	off_t mmap_offset = 0;
 	int use_mmap = 1;
-	const char *buf = NULL;
-	unsigned circular = size2 ? 1 : 0;	/* Wrapped around end of disk metadata buffer? */
+	off_t mmap_offset = 0;
+	char *buf = NULL;
 	struct config_source *cs = dm_config_get_custom(cft);
-	struct process_config_file_params *pcfp;
 
 	if (!_is_file_based_config_source(cs->type)) {
 		log_error(INTERNAL_ERROR "config_file_read_fd: expected file, special file "
 					 "or profile config source, found %s config source.",
 					 _config_source_names[cs->type]);
-		goto bad;
-	}
-
-	if (!(pcfp = dm_pool_zalloc(mem, sizeof(*pcfp)))) {
-		log_debug("config_file_read_fd: process_config_file_params struct allocation failed");
-		goto bad;
+		return 0;
 	}
 
-	pcfp->cft = cft;
-	pcfp->dev = dev;
-	pcfp->offset = offset;
-	pcfp->size = size;
-	pcfp->offset2 = offset2;
-	pcfp->size2 = size2;
-	pcfp->checksum_fn = checksum_fn;
-	pcfp->checksum = checksum;
-	pcfp->checksum_only = checksum_only;
-	pcfp->no_dup_node_check = no_dup_node_check;
-	pcfp->config_file_read_fd_callback = config_file_read_fd_callback;
-	pcfp->config_file_read_fd_context = config_file_read_fd_context;
-	pcfp->ret = 1;
-
 	/* Only use mmap with regular files */
-	if (!(dev->flags & DEV_REGULAR) || circular)
+	if (!(dev->flags & DEV_REGULAR) || size2)
 		use_mmap = 0;
 
 	if (use_mmap) {
@@ -594,40 +524,56 @@ int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct
 			  MAP_PRIVATE, dev_fd(dev), offset - mmap_offset);
 		if (fb == (caddr_t) (-1)) {
 			log_sys_error("mmap", dev_name(dev));
-			goto bad;
-		}
-		_process_config_file_buffer(0, ioflags, pcfp, fb + mmap_offset);
-		r = pcfp->ret;
-		/* unmap the file */
-		if (munmap(fb, size + mmap_offset)) {
-			log_sys_error("munmap", dev_name(dev));
-			r = 0;
+			goto out;
 		}
+		fb = fb + mmap_offset;
 	} else {
-		if (circular) {
-			if (!(buf = dev_read_circular(dev, (uint64_t) offset, size, (uint64_t) offset2, size2, reason)))
+		if (!(buf = dm_malloc(size + size2))) {
+			log_error("Failed to allocate circular buffer.");
+			return 0;
+		}
+		if (!dev_read_circular(dev, (uint64_t) offset, size,
+				       (uint64_t) offset2, size2, reason, buf)) {
+			goto out;
+		}
+		fb = buf;
+	}
+
+	if (checksum_fn && checksum !=
+	    (checksum_fn(checksum_fn(INITIAL_CRC, (const uint8_t *)fb, size),
+			 (const uint8_t *)(fb + size), size2))) {
+		log_error("%s: Checksum error at offset %" PRIu64, dev_name(dev), (uint64_t) offset);
+		goto out;
+	}
+
+	if (!checksum_only) {
+		fe = fb + size + size2;
+		if (no_dup_node_check) {
+			if (!dm_config_parse_without_dup_node_check(cft, fb, fe))
 				goto_out;
-			_process_config_file_buffer(0, ioflags, pcfp, buf);
-			dm_free((void *)buf);
 		} else {
-			dev_read_callback(dev, (uint64_t) offset, size, reason, ioflags, _process_config_file_buffer, pcfp);
-			if (config_file_read_fd_callback)
-				return 1;
+			if (!dm_config_parse(cft, fb, fe))
+				goto_out;
 		}
-		r = pcfp->ret;
 	}
 
-out:
-	return r;
+	r = 1;
 
-bad:
-	if (config_file_read_fd_callback)
-		config_file_read_fd_callback(1, ioflags, config_file_read_fd_context, NULL);
+      out:
+	if (!use_mmap)
+		dm_free(buf);
+	else {
+		/* unmap the file */
+		if (munmap(fb - mmap_offset, size + mmap_offset)) {
+			log_sys_error("munmap", dev_name(dev));
+			r = 0;
+		}
+	}
 
-	return 0;
+	return r;
 }
 
-int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft)
+int config_file_read(struct dm_config_tree *cft)
 {
 	const char *filename = NULL;
 	struct config_source *cs = dm_config_get_custom(cft);
@@ -655,8 +601,8 @@ int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft)
 		}
 	}
 
-	r = config_file_read_fd(mem, cft, cf->dev, DEV_IO_MDA_CONTENT, 0, (size_t) info.st_size, 0, 0,
-				(checksum_fn_t) NULL, 0, 0, 0, 0, NULL, NULL);
+	r = config_file_read_fd(cft, cf->dev, DEV_IO_MDA_CONTENT, 0, (size_t) info.st_size, 0, 0,
+				(checksum_fn_t) NULL, 0, 0, 0);
 
 	if (!cf->keep_open) {
 		if (!dev_close(cf->dev))
diff --git a/lib/config/config.h b/lib/config/config.h
index 4517cb7..d01306b 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -239,13 +239,11 @@ config_source_t config_get_source_type(struct dm_config_tree *cft);
 typedef uint32_t (*checksum_fn_t) (uint32_t initial, const uint8_t *buf, uint32_t size);
 
 struct dm_config_tree *config_open(config_source_t source, const char *filename, int keep_open);
-int config_file_read_fd(struct dm_pool *mem, struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
+int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_reason_t reason,
 			off_t offset, size_t size, off_t offset2, size_t size2,
 			checksum_fn_t checksum_fn, uint32_t checksum,
-			int skip_parse, int no_dup_node_check, unsigned ioflags,
-			lvm_callback_fn_t config_file_read_fd_callback, void *config_file_read_fd_context);
-
-int config_file_read(struct dm_pool *mem, struct dm_config_tree *cft);
+			int skip_parse, int no_dup_node_check);
+int config_file_read(struct dm_config_tree *cft);
 struct dm_config_tree *config_file_open_and_read(const char *config_file, config_source_t source,
 						 struct cmd_context *cmd);
 int config_write(struct dm_config_tree *cft, struct config_def_tree_spec *tree_spec,
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index f1db797..077fb15 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -226,16 +226,6 @@ cfg(devices_dir_CFG, "dir", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING,
 cfg_array(devices_scan_CFG, "scan", devices_CFG_SECTION, CFG_ADVANCED, CFG_TYPE_STRING, "#S/dev", vsn(1, 0, 0), NULL, 0, NULL,
 	"Directories containing device nodes to use with LVM.\n")
 
-cfg(devices_use_aio_CFG, "use_aio", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_AIO, vsn(2, 2, 178), NULL, 0, NULL,
-	"Use linux asynchronous I/O for parallel device access where possible.\n")
-
-cfg(devices_aio_max_CFG, "aio_max", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_AIO_MAX, vsn(2, 2, 178), NULL, 0, NULL,
-	"Maximum number of asynchronous I/Os to issue concurrently.\n")
-
-cfg(devices_aio_memory_CFG, "aio_memory", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_AIO_MEMORY, vsn(2, 2, 178), NULL, 0, NULL,
-	"Approximate maximum total amount of memory (in MB) used\n"
-	"for asynchronous I/O buffers.\n")
-
 cfg_array(devices_loopfiles_CFG, "loopfiles", devices_CFG_SECTION, CFG_DEFAULT_UNDEFINED | CFG_UNSUPPORTED, CFG_TYPE_STRING, NULL, vsn(1, 2, 0), NULL, 0, NULL, NULL)
 
 cfg(devices_obtain_device_list_from_udev_CFG, "obtain_device_list_from_udev", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV, vsn(2, 2, 85), NULL, 0, NULL,
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 1c730a9..d9e19d9 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -32,9 +32,6 @@
 #define DEFAULT_SYSTEM_ID_SOURCE "none"
 #define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
 #define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
-#define DEFAULT_USE_AIO 1
-#define DEFAULT_AIO_MAX 128
-#define DEFAULT_AIO_MEMORY 10
 #define DEFAULT_SYSFS_SCAN 1
 #define DEFAULT_MD_COMPONENT_DETECTION 1
 #define DEFAULT_FW_RAID_COMPONENT_DETECTION 0
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 711c2d8..e72ffd6 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1245,24 +1245,12 @@ int dev_cache_check_for_open_devices(void)
 
 int dev_cache_exit(void)
 {
-	struct btree_iter *b;
 	int num_open = 0;
 
-	dev_async_exit();
-
 	if (_cache.names)
 		if ((num_open = _check_for_open_devices(1)) > 0)
 			log_error(INTERNAL_ERROR "%d device(s) were left open and have been closed.", num_open);
 
-	if (_cache.devices) {
-		/* FIXME Replace with structured devbuf cache */
-		b = btree_first(_cache.devices);
-		while (b) {
-			devbufs_release(btree_get_data(b));
-			b = btree_next(b);
-		}
-	}
-
 	if (_cache.mem)
 		dm_pool_destroy(_cache.mem);
 
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 5603553..546b1fe 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -23,10 +23,10 @@
  * predicate for devices.
  */
 struct dev_filter {
-	int (*passes_filter) (struct dev_filter *f, struct device *dev);
-	void (*destroy) (struct dev_filter *f);
-	void (*wipe) (struct dev_filter *f);
-	int (*dump) (struct dev_filter *f, struct dm_pool *mem, int merge_existing);
+	int (*passes_filter) (struct dev_filter * f, struct device * dev);
+	void (*destroy) (struct dev_filter * f);
+	void (*wipe) (struct dev_filter * f);
+	int (*dump) (struct dev_filter * f, int merge_existing);
 	void *private;
 	unsigned use_count;
 };
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index d631b86..c321e61 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -53,12 +53,6 @@
 #  endif
 #endif
 
-/*
- * Always read at least 8k from disk.
- * This seems to be a good compromise for the existing LVM2 metadata layout.
- */
-#define MIN_READ_SIZE (8 * 1024)
-
 static DM_LIST_INIT(_open_devices);
 static unsigned _dev_size_seqno = 1;
 
@@ -80,319 +74,38 @@ static const char *_reason_text(dev_io_reason_t reason)
 	return _reasons[(unsigned) reason];
 }
 
-/*
- * Release the memory holding the last data we read
- */
-static void _release_devbuf(struct device_buffer *devbuf)
-{
-	dm_free(devbuf->malloc_address);
-	devbuf->malloc_address = NULL;
-}
-
-void devbufs_release(struct device *dev)
-{
-	if ((dev->flags & DEV_REGULAR))
-		return;
-
-	_release_devbuf(&dev->last_devbuf);
-	_release_devbuf(&dev->last_extra_devbuf);
-}
-
-#ifdef AIO_SUPPORT
-
-#  include <libaio.h>
-
-static io_context_t _aio_ctx = 0;
-static struct io_event *_aio_events = NULL;
-static int _aio_max = 0;
-static int64_t _aio_memory_max = 0;
-static int _aio_must_queue = 0;		/* Have we reached AIO capacity? */
-
-static DM_LIST_INIT(_aio_queue);
-
-#define DEFAULT_AIO_COLLECTION_EVENTS 32
-
-int dev_async_setup(struct cmd_context *cmd)
+/*-----------------------------------------------------------------
+ * The standard io loop that keeps submitting an io until it's
+ * all gone.
+ *---------------------------------------------------------------*/
+static int _io(struct device_area *where, char *buffer, int should_write, dev_io_reason_t reason)
 {
-	int r;
-
-	_aio_max = find_config_tree_int(cmd, devices_aio_max_CFG, NULL);
-	_aio_memory_max = find_config_tree_int(cmd, devices_aio_memory_CFG, NULL) * INT64_C(1024 * 1024);
-
-	/* Threshold is zero? */
-	if (!_aio_max || !_aio_memory_max) {
-		if (_aio_ctx)
-			dev_async_exit();
-		return 1;
-	}
-
-	/* Already set up? */
-	if (_aio_ctx)
-		return 1;
-
-	log_debug_io("Setting up aio context for up to %" PRId64 " MB across %d events.", _aio_memory_max, _aio_max);
-
-	if (!_aio_events && !(_aio_events = dm_zalloc(sizeof(*_aio_events) * DEFAULT_AIO_COLLECTION_EVENTS))) {
-		log_error("Failed to allocate io_event array for asynchronous I/O.");
-		return 0;
-	}
+	int fd = dev_fd(where->dev);
+	ssize_t n = 0;
+	size_t total = 0;
 
-	if ((r = io_setup(_aio_max, &_aio_ctx)) < 0) {
-		/*
-		 * Possible errors:
-		 *   ENOSYS - aio not available in current kernel
-		 *   EAGAIN - _aio_max is too big
-		 *   EFAULT - invalid pointer
-		 *   EINVAL - _aio_ctx != 0 or kernel aio limits exceeded
-		 *   ENOMEM
-		 */
-		log_warn("WARNING: Asynchronous I/O setup for %d events failed: %s", _aio_max, strerror(-r));
-		log_warn("WARNING: Using only synchronous I/O.");
-		dm_free(_aio_events);
-		_aio_events = NULL;
-		_aio_ctx = 0;
+	if (fd < 0) {
+		log_error("Attempt to read an unopened device (%s).",
+			  dev_name(where->dev));
 		return 0;
 	}
 
-	return 1;
-}
-
-/* Reset aio context after fork */
-int dev_async_reset(struct cmd_context *cmd)
-{
-	log_debug_io("Resetting asynchronous I/O context.");
-	_aio_ctx = 0;
-	dm_free(_aio_events);
-	_aio_events = NULL;
-
-	return dev_async_setup(cmd);
-}
-
-/*
- * Track the amount of in-flight async I/O.
- * If it exceeds the defined threshold set _aio_must_queue.
- */
-static void _update_aio_counters(int nr, ssize_t bytes)
-{
-	static int64_t aio_bytes = 0;
-	static int aio_count = 0;
-
-	aio_bytes += bytes;
-	aio_count += nr;
-
-	if (aio_count >= _aio_max || aio_bytes > _aio_memory_max)
-		_aio_must_queue = 1;
-	else
-		_aio_must_queue = 0;
-}
-
-static int _io(struct device_buffer *devbuf, unsigned ioflags);
+	log_debug_io("%s %s:%8" PRIu64 " bytes (sync) at %" PRIu64 "%s (for %s)",
+		     should_write ? "Write" : "Read ", dev_name(where->dev),
+		     where->size, (uint64_t) where->start,
+		     (should_write && test_mode()) ? " (test mode - suppressed)" : "", _reason_text(reason));
 
-int dev_async_getevents(void)
-{
-	struct device_buffer *devbuf, *tmp;
-	lvm_callback_fn_t dev_read_callback_fn;
-	void *dev_read_callback_context;
-	int r, event_nr;
-
-	if (!_aio_ctx)
+	/*
+	 * Skip all writes in test mode.
+	 */
+	if (should_write && test_mode())
 		return 1;
 
-	do {
-		/* FIXME Add timeout - currently NULL - waits for ever for at least 1 item */
-		r = io_getevents(_aio_ctx, 1, DEFAULT_AIO_COLLECTION_EVENTS, _aio_events, NULL);
-		if (r > 0)
-			break;
-		if (!r)
-			return 1; /* Timeout elapsed */
-		if (r == -EINTR)
-			continue;
-		if (r == -EAGAIN) {
-			usleep(100);
-			return 1; /* Give the caller the opportunity to do other work before repeating */
-		}
-		/*
-		 * ENOSYS - not supported by kernel
-		 * EFAULT - memory invalid
-		 * EINVAL - _aio_ctx invalid or min_nr/nr/timeout out of range
-		 */
-		log_error("Asynchronous event collection failed: %s", strerror(-r));
-		return 0;
-	} while (1);
-
-	for (event_nr = 0; event_nr < r; event_nr++) {
-		devbuf = _aio_events[event_nr].obj->data;
-		dm_free(_aio_events[event_nr].obj);
-
-		_update_aio_counters(-1, -devbuf->where.size);
-
-		dev_read_callback_fn = devbuf->dev_read_callback_fn;
-		dev_read_callback_context = devbuf->dev_read_callback_context;
-
-		/* Clear the callbacks as a precaution */
-		devbuf->dev_read_callback_context = NULL;
-		devbuf->dev_read_callback_fn = NULL;
-
-		if (_aio_events[event_nr].res == devbuf->where.size) {
-			if (dev_read_callback_fn)
-				dev_read_callback_fn(0, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, (char *)devbuf->buf + devbuf->data_offset);
-		} else {
-			/* FIXME If partial read is possible, resubmit remainder */
-			log_error("%s: asynchronous read only I/O failed (" FMTd64 ") of " FMTu64 " bytes at " FMTu64 " (for %s): %s",
-				  dev_name(devbuf->where.dev), _aio_events[event_nr].res,
-				  (uint64_t) devbuf->where.size, (uint64_t) devbuf->where.start,
-				  _reason_text(devbuf->reason),
-				  (((int64_t)_aio_events[event_nr].res) < 0) ? strerror(-(int64_t)_aio_events[event_nr].res) : 0);
-			_release_devbuf(devbuf);
-			if (dev_read_callback_fn)
-				dev_read_callback_fn(1, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, NULL);
-			else
-				r = 0;
-		}
-	}
-
-	/* Submit further queued events if we can */
-        dm_list_iterate_items_gen_safe(devbuf, tmp, &_aio_queue, aio_queued) {
-		if (_aio_must_queue)
-			break;
-                dm_list_del(&devbuf->aio_queued);
-		_io(devbuf, 1);
-        }
-
-	return 1;
-}
-
-static int _io_async(struct device_buffer *devbuf)
-{
-	struct device_area *where = &devbuf->where;
-	struct iocb *iocb;
-	int r;
-
-	_update_aio_counters(1, devbuf->where.size);
-
-	if (!(iocb = dm_malloc(sizeof(*iocb)))) {
-		log_error("Failed to allocate I/O control block array for asynchronous I/O.");
+	if (where->size > SSIZE_MAX) {
+		log_error("Read size too large: %" PRIu64, where->size);
 		return 0;
 	}
 
-	io_prep_pread(iocb, dev_fd(where->dev), devbuf->buf, where->size, where->start);
-	iocb->data = devbuf;
-
-	do {
-		r = io_submit(_aio_ctx, 1L, &iocb);
-		if (r ==1)
-			break;	/* Success */
-		if (r == -EAGAIN) {
-			/* Try to release some resources then retry */
-			usleep(100);
-			if (dev_async_getevents())
-				return_0;
-			/* FIXME Add counter/timeout so we can't get stuck here for ever */
-			continue;
-		}
-		/*
-		 * Possible errors:
-		 *   EFAULT - invalid data
-		 *   ENOSYS - no aio support in kernel
-		 *   EBADF  - bad file descriptor in iocb
-		 *   EINVAL - invalid _aio_ctx / iocb not initialised / invalid operation for this fd
-		 */
-		log_error("Asynchronous event submission failed: %s", strerror(-r));
-		return 0;
-	} while (1);
-
-	return 1;
-}
-
-void dev_async_exit(void)
-{
-	struct device_buffer *devbuf, *tmp;
-	lvm_callback_fn_t dev_read_callback_fn;
-	void *dev_read_callback_context;
-	int r;
-
-	if (!_aio_ctx)
-		return;
-
-	/* Discard any queued requests */
-        dm_list_iterate_items_gen_safe(devbuf, tmp, &_aio_queue, aio_queued) {
-                dm_list_del(&devbuf->aio_queued);
-
-		_update_aio_counters(-1, -devbuf->where.size);
-
-		dev_read_callback_fn = devbuf->dev_read_callback_fn;
-		dev_read_callback_context = devbuf->dev_read_callback_context;
-
-		_release_devbuf(devbuf);
-
-		if (dev_read_callback_fn)
-			dev_read_callback_fn(1, AIO_SUPPORTED_CODE_PATH, dev_read_callback_context, NULL);
-        }
-
-	log_debug_io("Destroying aio context.");
-	if ((r = io_destroy(_aio_ctx)) < 0)
-		/* Returns -ENOSYS if aio not in kernel or -EINVAL if _aio_ctx invalid */
-		log_error("Failed to destroy asynchronous I/O context: %s", strerror(-r));
-
-	dm_free(_aio_events);
-	_aio_events = NULL;
-
-	_aio_ctx = 0;
-}
-
-static void _queue_aio(struct device_buffer *devbuf)
-{
-	dm_list_add(&_aio_queue, &devbuf->aio_queued);
-	log_debug_io("Queueing aio.");
-}
-
-#else
-
-static int _aio_ctx = 0;
-static int _aio_must_queue = 0;
-
-int dev_async_setup(struct cmd_context *cmd)
-{
-	return 1;
-}
-
-int dev_async_reset(struct cmd_context *cmd)
-{
-	return 1;
-}
-
-int dev_async_getevents(void)
-{
-	return 1;
-}
-
-void dev_async_exit(void)
-{
-}
-
-static int _io_async(struct device_buffer *devbuf)
-{
-	return 0;
-}
-
-static void _queue_aio(struct device_buffer *devbuf)
-{
-}
-
-#endif /* AIO_SUPPORT */
-
-/*-----------------------------------------------------------------
- * The standard io loop that keeps submitting an io until it's
- * all gone.
- *---------------------------------------------------------------*/
-static int _io_sync(struct device_buffer *devbuf)
-{
-	struct device_area *where = &devbuf->where;
-	int fd = dev_fd(where->dev);
-	char *buffer = devbuf->buf;
-	ssize_t n = 0;
-	size_t total = 0;
-
 	if (lseek(fd, (off_t) where->start, SEEK_SET) == (off_t) -1) {
 		log_error("%s: lseek %" PRIu64 " failed: %s",
 			  dev_name(where->dev), (uint64_t) where->start,
@@ -402,19 +115,18 @@ static int _io_sync(struct device_buffer *devbuf)
 
 	while (total < (size_t) where->size) {
 		do
-			n = devbuf->write ?
+			n = should_write ?
 			    write(fd, buffer, (size_t) where->size - total) :
 			    read(fd, buffer, (size_t) where->size - total);
 		while ((n < 0) && ((errno == EINTR) || (errno == EAGAIN)));
 
 		if (n < 0)
-			log_error("%s: synchronous %s failed after %" PRIu64 " of %" PRIu64
-				  "@%" PRIu64 " (for %s): %s", dev_name(where->dev),
-				  devbuf->write ? "write" : "read",
-				  (uint64_t) total,
-				  (uint64_t) where->size, (uint64_t) where->start,
-				  _reason_text(devbuf->reason),
-				  strerror(errno));
+			log_error_once("%s: %s failed after %" PRIu64 " of %" PRIu64
+				       " at %" PRIu64 ": %s", dev_name(where->dev),
+				       should_write ? "write" : "read",
+				       (uint64_t) total,
+				       (uint64_t) where->size,
+				       (uint64_t) where->start, strerror(errno));
 
 		if (n <= 0)
 			break;
@@ -426,42 +138,6 @@ static int _io_sync(struct device_buffer *devbuf)
 	return (total == (size_t) where->size);
 }
 
-static int _io(struct device_buffer *devbuf, unsigned ioflags)
-{
-	struct device_area *where = &devbuf->where;
-	int fd = dev_fd(where->dev);
-	int async = (!devbuf->write && _aio_ctx && aio_supported_code_path(ioflags) && devbuf->dev_read_callback_fn) ? 1 : 0;
-
-	if (fd < 0) {
-		log_error("Attempt to read an unopened device (%s).",
-			  dev_name(where->dev));
-		return 0;
-	}
-
-	if (!devbuf->buf && !(devbuf->malloc_address = devbuf->buf = dm_malloc_aligned((size_t) devbuf->where.size, 0))) {
-		log_error("I/O buffer malloc failed");
-		return 0;
-	}
-
-	log_debug_io("%s %s(fd %d):%8" PRIu64 " bytes (%ssync) at %" PRIu64 "%s (for %s)",
-		     devbuf->write ? "Write" : "Read ", dev_name(where->dev), fd,
-		     where->size, async ? "a" : "", (uint64_t) where->start,
-		     (devbuf->write && test_mode()) ? " (test mode - suppressed)" : "", _reason_text(devbuf->reason));
-
-	/*
-	 * Skip all writes in test mode.
-	 */
-	if (devbuf->write && test_mode())
-		return 1;
-
-	if (where->size > SSIZE_MAX) {
-		log_error("Read size too large: %" PRIu64, where->size);
-		return 0;
-	}
-
-	return async ? _io_async(devbuf) : _io_sync(devbuf);
-}
-
 /*-----------------------------------------------------------------
  * LVM2 uses O_DIRECT when performing metadata io, which requires
  * block size aligned accesses.  If any io is not aligned we have
@@ -551,16 +227,15 @@ static void _widen_region(unsigned int block_size, struct device_area *region,
 		result->size += block_size - delta;
 }
 
-static int _aligned_io(struct device_area *where, char *write_buffer,
-		       int should_write, dev_io_reason_t reason,
-		       unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *dev_read_callback_context)
+static int _aligned_io(struct device_area *where, char *buffer,
+		       int should_write, dev_io_reason_t reason)
 {
+	char *bounce, *bounce_buf;
 	unsigned int physical_block_size = 0;
 	unsigned int block_size = 0;
 	unsigned buffer_was_widened = 0;
 	uintptr_t mask;
 	struct device_area widened;
-	struct device_buffer *devbuf;
 	int r = 0;
 
 	if (!(where->dev->flags & DEV_REGULAR) &&
@@ -569,11 +244,6 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 
 	if (!block_size)
 		block_size = lvm_getpagesize();
-
-	/* Apply minimum read size */
-	if (!should_write && block_size < MIN_READ_SIZE)
-		block_size = MIN_READ_SIZE;
-
 	mask = block_size - 1;
 
 	_widen_region(block_size, where, &widened);
@@ -583,75 +253,50 @@ static int _aligned_io(struct device_area *where, char *write_buffer,
 		buffer_was_widened = 1;
 		log_debug_io("Widening request for %" PRIu64 " bytes at %" PRIu64 " to %" PRIu64 " bytes@%" PRIu64 " on %s (for %s)",
 			     where->size, (uint64_t) where->start, widened.size, (uint64_t) widened.start, dev_name(where->dev), _reason_text(reason));
-	} 
-
-	devbuf = DEV_DEVBUF(where->dev, reason);
-	_release_devbuf(devbuf);
-	devbuf->where.dev = where->dev;
-	devbuf->where.start = widened.start;
-	devbuf->where.size = widened.size;
-	devbuf->write = should_write;
-	devbuf->reason = reason;
-	devbuf->dev_read_callback_fn = dev_read_callback_fn;
-	devbuf->dev_read_callback_context = dev_read_callback_context;
-
-	/* Store location of requested data relative to start of buf */
-	devbuf->data_offset = where->start - devbuf->where.start;
-
-	if (should_write && !buffer_was_widened && !((uintptr_t) write_buffer & mask))
+	} else if (!((uintptr_t) buffer & mask))
 		/* Perform the I/O directly. */
-		devbuf->buf = write_buffer;
-	else if (!should_write)
-		/* Postpone buffer allocation until we're about to issue the I/O */
-		devbuf->buf = NULL;
-	else {
-		/* Allocate a bounce buffer with an extra block */
-		if (!(devbuf->malloc_address = devbuf->buf = dm_malloc((size_t) devbuf->where.size + block_size))) {
-			log_error("Bounce buffer malloc failed");
-			return 0;
-		}
-
-		/*
-		 * Realign start of bounce buffer (using the extra sector)
-		 */
-		if (((uintptr_t) devbuf->buf) & mask)
-			devbuf->buf = (char *) ((((uintptr_t) devbuf->buf) + mask) & ~mask);
-	}
+		return _io(where, buffer, should_write, reason);
 
-	/* If we've reached our concurrent AIO limit, add this request to the queue */
-	if (!devbuf->write && _aio_ctx && aio_supported_code_path(ioflags) && dev_read_callback_fn && _aio_must_queue) {
-		_queue_aio(devbuf);
-		return 1;
+	/* Allocate a bounce buffer with an extra block */
+	if (!(bounce_buf = bounce = dm_malloc((size_t) widened.size + block_size))) {
+		log_error("Bounce buffer malloc failed");
+		return 0;
 	}
 
-	devbuf->write = 0;
+	/*
+	 * Realign start of bounce buffer (using the extra sector)
+	 */
+	if (((uintptr_t) bounce) & mask)
+		bounce = (char *) ((((uintptr_t) bounce) + mask) & ~mask);
 
 	/* Do we need to read into the bounce buffer? */
-	if ((!should_write || buffer_was_widened) && !_io(devbuf, ioflags)) {
+	if ((!should_write || buffer_was_widened) &&
+	    !_io(&widened, bounce, 0, reason)) {
 		if (!should_write)
-			goto_bad;
+			goto_out;
 		/* FIXME Handle errors properly! */
 		/* FIXME pre-extend the file */
-		memset(devbuf->buf, '\n', devbuf->where.size);
+		memset(bounce, '\n', widened.size);
 	}
 
-	if (!should_write)
-		return 1;
-
-	/* writes */
+	if (should_write) {
+		memcpy(bounce + (where->start - widened.start), buffer,
+		       (size_t) where->size);
 
-	if (devbuf->malloc_address) {
-		memcpy((char *) devbuf->buf + devbuf->data_offset, write_buffer, (size_t) where->size);
-		log_debug_io("Overwriting %" PRIu64 " bytes at %" PRIu64 " (for %s)", where->size,
-			     (uint64_t) where->start, _reason_text(devbuf->reason));
+		/* ... then we write */
+		if (!(r = _io(&widened, bounce, 1, reason)))
+			stack;
+			
+		goto out;
 	}
 
-	/* ... then we write */
-	devbuf->write = 1;
-	if (!(r = _io(devbuf, 0)))
-		stack;
-bad:
-	_release_devbuf(devbuf);
+	memcpy(buffer, bounce + (where->start - widened.start),
+	       (size_t) where->size);
+
+	r = 1;
+
+out:
+	dm_free(bounce_buf);
 	return r;
 }
 
@@ -1005,7 +650,6 @@ static void _close(struct device *dev)
 	dev->phys_block_size = -1;
 	dev->block_size = -1;
 	dm_list_del(&dev->open_list);
-	devbufs_release(dev);
 
 	log_debug_devs("Closed %s", dev_name(dev));
 
@@ -1078,121 +722,55 @@ static void _dev_inc_error_count(struct device *dev)
 			 dev->max_error_count, dev_name(dev));
 }
 
-/*
- * Data is returned (read-only) at DEV_DEVBUF_DATA(dev, reason).
- * If dev_read_callback_fn is supplied, we always return 1 and take
- * responsibility for calling it exactly once.  This might happen before the
- * function returns (if there's an error or the I/O is synchronous) or after.
- * Any error is passed to that function, which must track it if required.
- */
-static int _dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
-			      unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
+int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer)
 {
 	struct device_area where;
-	struct device_buffer *devbuf;
-	uint64_t buf_end;
-	int cached = 0;
-	int ret = 0;
+	int ret;
 
-	if (!dev->open_count) {
-		log_error(INTERNAL_ERROR "Attempt to access device %s while closed.", dev_name(dev));
-		goto out;
-	}
+	if (!dev->open_count)
+		return_0;
 
 	if (!_dev_is_valid(dev))
-		goto_out;
-
-	/*
-	 * Can we satisfy this from data we stored last time we read?
-	 */
-	if ((devbuf = DEV_DEVBUF(dev, reason)) && devbuf->malloc_address) {
-		buf_end = devbuf->where.start + devbuf->where.size - 1;
-		if (offset >= devbuf->where.start && offset <= buf_end && offset + len - 1 <= buf_end) {
-			/* Reuse this buffer */
-			cached = 1;
-			devbuf->data_offset = offset - devbuf->where.start;
-			log_debug_io("Cached read for %" PRIu64 " bytes at %" PRIu64 " on %s (for %s)",
-				     (uint64_t) len, (uint64_t) offset, dev_name(dev), _reason_text(reason));
-			ret = 1;
-			goto out;
-		}
-	}
+		return 0;
 
 	where.dev = dev;
 	where.start = offset;
 	where.size = len;
 
-	ret = _aligned_io(&where, NULL, 0, reason, ioflags, dev_read_callback_fn, callback_context);
-	if (!ret) {
-		log_debug("Read from %s failed (for %s).", dev_name(dev), _reason_text(reason));
+	ret = _aligned_io(&where, buffer, 0, reason);
+	if (!ret)
 		_dev_inc_error_count(dev);
-	}
-
-out:
-	/* If we had an error or this was sync I/O, pass the result to any callback fn */
-	if ((!ret || !_aio_ctx || !aio_supported_code_path(ioflags) || cached) && dev_read_callback_fn) {
-		dev_read_callback_fn(!ret, ioflags, callback_context, DEV_DEVBUF_DATA(dev, reason));
-		return 1;
-	}
 
 	return ret;
 }
 
-void dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
-		      unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context)
-{
-	/* Always returns 1 if callback fn is supplied */
-	if (!_dev_read_callback(dev, offset, len, reason, ioflags, dev_read_callback_fn, callback_context))
-		log_error(INTERNAL_ERROR "_dev_read_callback failed");
-}
-
-/* Returns pointer to read-only buffer. Caller does not free it.  */
-const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason)
-{
-	if (!_dev_read_callback(dev, offset, len, reason, 0, NULL, NULL))
-		return_NULL;
-
-	return DEV_DEVBUF_DATA(dev, reason);
-}
-
-/* Read into supplied retbuf owned by the caller. */
-int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf)
-{
-	if (!_dev_read_callback(dev, offset, len, reason, 0, NULL, NULL))
-		return_0;
-
-	memcpy(retbuf, DEV_DEVBUF_DATA(dev, reason), len);
-
-	return 1;
-}
-
 /*
- * Read from 'dev' in 2 distinct regions, denoted by (offset,len) and (offset2,len2).
- * Caller is responsible for dm_free().
+ * Read from 'dev' into 'buf', possibly in 2 distinct regions, denoted
+ * by (offset,len) and (offset2,len2).  Thus, the total size of
+ * 'buf' should be len+len2.
  */
-const char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-			uint64_t offset2, size_t len2, dev_io_reason_t reason)
+int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
+		      uint64_t offset2, size_t len2, dev_io_reason_t reason, char *buf)
 {
-	char *buf = NULL;
-
-	if (!(buf = dm_malloc(len + len2))) {
-		log_error("Buffer allocation failed for split metadata.");
-		return NULL;
+	if (!dev_read(dev, offset, len, reason, buf)) {
+		log_error("Read from %s failed", dev_name(dev));
+		return 0;
 	}
 
-	if (!dev_read_buf(dev, offset, len, reason, buf)) {
-		log_error("Read from %s failed.", dev_name(dev));
-		dm_free(buf);
-		return NULL;
-	}
+	/*
+	 * The second region is optional, and allows for
+	 * a circular buffer on the device.
+	 */
+	if (!len2)
+		return 1;
 
-	if (!dev_read_buf(dev, offset2, len2, reason, buf + len)) {
-		log_error("Circular read from %s failed.", dev_name(dev));
-		dm_free(buf);
-		return NULL;
+	if (!dev_read(dev, offset2, len2, reason, buf + len)) {
+		log_error("Circular read from %s failed",
+			  dev_name(dev));
+		return 0;
 	}
 
-	return buf;
+	return 1;
 }
 
 /* FIXME If O_DIRECT can't extend file, dev_extend first; dev_truncate after.
@@ -1238,7 +816,7 @@ int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t r
 
 	dev->flags |= DEV_ACCESSED_W;
 
-	ret = _aligned_io(&where, buffer, 1, reason, 0, NULL, NULL);
+	ret = _aligned_io(&where, buffer, 1, reason);
 	if (!ret)
 		_dev_inc_error_count(dev);
 
@@ -1248,7 +826,7 @@ int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t r
 int dev_set(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, int value)
 {
 	size_t s;
-	char buffer[4096] __attribute__((aligned(4096)));
+	char buffer[4096] __attribute__((aligned(8)));
 
 	if (!dev_open(dev))
 		return_0;
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index f291615..8513e14 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -31,7 +31,7 @@ int dev_is_luks(struct device *dev, uint64_t *offset_found)
 	if (offset_found)
 		*offset_found = 0;
 
-	if (!dev_read_buf(dev, 0, LUKS_SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf))
+	if (!dev_read(dev, 0, LUKS_SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf))
 		goto_out;
 
 	ret = memcmp(buf, LUKS_SIGNATURE, LUKS_SIGNATURE_SIZE) ? 0 : 1;
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 1a5d470..92ee214 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -37,7 +37,7 @@ static int _dev_has_md_magic(struct device *dev, uint64_t sb_offset)
 	uint32_t md_magic;
 
 	/* Version 1 is little endian; version 0.90.0 is machine endian */
-	if (dev_read_buf(dev, sb_offset, sizeof(uint32_t), DEV_IO_SIGNATURES, &md_magic) &&
+	if (dev_read(dev, sb_offset, sizeof(uint32_t), DEV_IO_SIGNATURES, &md_magic) &&
 	    ((md_magic == MD_SB_MAGIC) ||
 	     ((MD_SB_MAGIC != xlate32(MD_SB_MAGIC)) && (md_magic == xlate32(MD_SB_MAGIC)))))
 		return 1;
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index 094eb05..a7ff10b 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -60,7 +60,8 @@ int dev_is_swap(struct device *dev, uint64_t *offset_found)
 			continue;
 		if (size < (page >> SECTOR_SHIFT))
 			break;
-		if (!dev_read_buf(dev, page - SIGNATURE_SIZE, SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf)) {
+		if (!dev_read(dev, page - SIGNATURE_SIZE,
+			      SIGNATURE_SIZE, DEV_IO_SIGNATURES, buf)) {
 			ret = -1;
 			break;
 		}
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index b9e77f8..9608146 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -363,7 +363,7 @@ static int _has_partition_table(struct device *dev)
 		uint16_t magic;
 	} __attribute__((packed)) buf; /* sizeof() == SECTOR_SIZE */
 
-	if (!dev_read_buf(dev, UINT64_C(0), sizeof(buf), DEV_IO_SIGNATURES, &buf))
+	if (!dev_read(dev, UINT64_C(0), sizeof(buf), DEV_IO_SIGNATURES, &buf))
 		return_0;
 
 	/* FIXME Check for other types of partition table too */
diff --git a/lib/device/device.h b/lib/device/device.h
index ea71d00..503373f 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -32,18 +32,6 @@
 #define DEV_ASSUMED_FOR_LV	0x00000200	/* Is device assumed for an LV */
 #define DEV_NOT_O_NOATIME	0x00000400	/* Don't use O_NOATIME */
 
-/* ioflags */
-#define AIO_SUPPORTED_CODE_PATH	0x00000001	/* Set if the code path supports AIO */
-
-#define aio_supported_code_path(ioflags)       (((ioflags) & AIO_SUPPORTED_CODE_PATH) ? 1 : 0)
-
-/*
- * Standard format for callback functions.
- * When provided, callback functions are called exactly once.
- * If failed is set, data cannot be accessed.
- */
-typedef void (*lvm_callback_fn_t)(int failed, unsigned ioflags, void *context, const void *data);
-
 /*
  * Support for external device info.
  * Any new external device info source needs to be
@@ -62,48 +50,6 @@ struct dev_ext {
 };
 
 /*
- * All I/O is annotated with the reason it is performed.
- */
-typedef enum dev_io_reason {
-	DEV_IO_SIGNATURES = 0,	/* Scanning device signatures */
-	DEV_IO_LABEL,		/* LVM PV disk label */
-	DEV_IO_MDA_HEADER,	/* Text format metadata area header */
-	DEV_IO_MDA_CONTENT,	/* Text format metadata area content */
-	DEV_IO_MDA_EXTRA_HEADER,	/* Header of any extra metadata areas on device */
-	DEV_IO_MDA_EXTRA_CONTENT,	/* Content of any extra metadata areas on device */
-	DEV_IO_FMT1,		/* Original LVM1 metadata format */
-	DEV_IO_POOL,		/* Pool metadata format */
-	DEV_IO_LV,		/* Content written to an LV */
-	DEV_IO_LOG		/* Logging messages */
-} dev_io_reason_t;
-
-/*
- * Is this I/O for a device's extra metadata area?
- */
-#define EXTRA_IO(reason) ((reason) == DEV_IO_MDA_EXTRA_HEADER || (reason) == DEV_IO_MDA_EXTRA_CONTENT)
-#define DEV_DEVBUF(dev, reason) (EXTRA_IO((reason)) ? &(dev)->last_extra_devbuf : &(dev)->last_devbuf)
-#define DEV_DEVBUF_DATA(dev, reason) ((char *) DEV_DEVBUF((dev), (reason))->buf + DEV_DEVBUF((dev), (reason))->data_offset)
-
-struct device_area {
-	struct device *dev;
-	uint64_t start;		/* Bytes */
-	uint64_t size;		/* Bytes */
-};
-
-struct device_buffer {
-	uint64_t data_offset;	/* Offset to start of requested data within buf */
-	void *malloc_address;	/* Start of allocated memory */
-	void *buf;		/* Aligned buffer that contains data within it */
-	struct device_area where;	/* Location of buf */
-	dev_io_reason_t reason;
-	unsigned write:1;	/* 1 if write; 0 if read */
-
-	lvm_callback_fn_t dev_read_callback_fn;
-	void *dev_read_callback_context;
-	struct dm_list aio_queued;	/* Queue of async I/O waiting to be issued */
-};
-
-/*
  * All devices in LVM will be represented by one of these.
  * pointer comparisons are valid.
  */
@@ -125,8 +71,6 @@ struct device {
 	uint64_t end;
 	struct dm_list open_list;
 	struct dev_ext ext;
-	struct device_buffer last_devbuf;       /* Last data buffer read from the device */
-	struct device_buffer last_extra_devbuf; /* Last data buffer read from the device for extra metadata area */
 
 	const char *vgid; /* if device is an LV */
 	const char *lvid; /* if device is an LV */
@@ -135,11 +79,33 @@ struct device {
 	char _padding[7];
 };
 
+/*
+ * All I/O is annotated with the reason it is performed.
+ */
+typedef enum dev_io_reason {
+	DEV_IO_SIGNATURES = 0,	/* Scanning device signatures */
+	DEV_IO_LABEL,		/* LVM PV disk label */
+	DEV_IO_MDA_HEADER,	/* Text format metadata area header */
+	DEV_IO_MDA_CONTENT,	/* Text format metadata area content */
+	DEV_IO_MDA_EXTRA_HEADER,	/* Header of any extra metadata areas on device */
+	DEV_IO_MDA_EXTRA_CONTENT,	/* Content of any extra metadata areas on device */
+	DEV_IO_FMT1,		/* Original LVM1 metadata format */
+	DEV_IO_POOL,		/* Pool metadata format */
+	DEV_IO_LV,		/* Content written to an LV */
+	DEV_IO_LOG		/* Logging messages */
+} dev_io_reason_t;
+
 struct device_list {
 	struct dm_list list;
 	struct device *dev;
 };
 
+struct device_area {
+	struct device *dev;
+	uint64_t start;		/* Bytes */
+	uint64_t size;		/* Bytes */
+};
+
 /*
  * Support for external device info.
  */
@@ -179,19 +145,9 @@ int dev_test_excl(struct device *dev);
 int dev_fd(struct device *dev);
 const char *dev_name(const struct device *dev);
 
-/* Returns a read-only buffer */
-const char *dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason);
-const char *dev_read_circular(struct device *dev, uint64_t offset, size_t len,
-			      uint64_t offset2, size_t len2, dev_io_reason_t reason);
-
-/* Passes the data (or error) to dev_read_callback_fn */
-void dev_read_callback(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason,
-		       unsigned ioflags, lvm_callback_fn_t dev_read_callback_fn, void *callback_context);
-
-/* Read data and copy it into a supplied private buffer. */
-/* Only use for tiny reads or on unimportant code paths. */
-int dev_read_buf(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *retbuf);
-
+int dev_read(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
+int dev_read_circular(struct device *dev, uint64_t offset, size_t len,
+		      uint64_t offset2, size_t len2, dev_io_reason_t reason, char *buf);
 int dev_write(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, void *buffer);
 int dev_append(struct device *dev, size_t len, dev_io_reason_t reason, char *buffer);
 int dev_set(struct device *dev, uint64_t offset, size_t len, dev_io_reason_t reason, int value);
@@ -201,15 +157,7 @@ struct device *dev_create_file(const char *filename, struct device *dev,
 			       struct dm_str_list *alias, int use_malloc);
 void dev_destroy_file(struct device *dev);
 
-void devbufs_release(struct device *dev);
-
 /* Return a valid device name from the alias list; NULL otherwise */
 const char *dev_name_confirmed(struct device *dev, int quiet);
 
-struct cmd_context;
-int dev_async_getevents(void);
-int dev_async_setup(struct cmd_context *cmd);
-void dev_async_exit(void);
-int dev_async_reset(struct cmd_context *cmd);
-
 #endif
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 83a0f02..c635896 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -52,13 +52,13 @@ static void _composite_destroy(struct dev_filter *f)
 	dm_free(f);
 }
 
-static int _dump(struct dev_filter *f, struct dm_pool *mem, int merge_existing)
+static int _dump(struct dev_filter *f, int merge_existing)
 {
 	struct dev_filter **filters;
 
 	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
 		if ((*filters)->dump &&
-		    !(*filters)->dump(*filters, mem, merge_existing))
+		    !(*filters)->dump(*filters, merge_existing))
 			return_0;
 
 	return 1;
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 7542e02..5bc0861 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -87,7 +87,7 @@ static int _read_array(struct pfilter *pf, struct dm_config_tree *cft,
 	return 1;
 }
 
-int persistent_filter_load(struct dm_pool *mem, struct dev_filter *f, struct dm_config_tree **cft_out)
+int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out)
 {
 	struct pfilter *pf = (struct pfilter *) f->private;
 	struct dm_config_tree *cft;
@@ -116,7 +116,7 @@ int persistent_filter_load(struct dm_pool *mem, struct dev_filter *f, struct dm_
 	if (!(cft = config_open(CONFIG_FILE_SPECIAL, pf->file, 1)))
 		return_0;
 
-	if (!config_file_read(mem, cft))
+	if (!config_file_read(cft))
 		goto_out;
 
 	log_debug_devs("Loading persistent filter cache from %s", pf->file);
@@ -175,7 +175,7 @@ static void _write_array(struct pfilter *pf, FILE *fp, const char *path,
 		fprintf(fp, "\n\t]\n");
 }
 
-static int _persistent_filter_dump(struct dev_filter *f, struct dm_pool *mem, int merge_existing)
+static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
 {
 	struct pfilter *pf;
 	char *tmp_file;
@@ -234,7 +234,7 @@ static int _persistent_filter_dump(struct dev_filter *f, struct dm_pool *mem, in
 	lvm_stat_ctim(&ts, &info);
 	if (merge_existing && timespeccmp(&ts, &pf->ctime, !=))
 		/* Keep cft open to avoid losing lock */
-		persistent_filter_load(mem, f, &cft);
+		persistent_filter_load(f, &cft);
 
 	tmp_file = alloca(strlen(pf->file) + 5);
 	sprintf(tmp_file, "%s.tmp", pf->file);
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 5dbf0b4..d75f6e1 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -53,6 +53,6 @@ typedef enum {
 } filter_mode_t;
 struct dev_filter *usable_filter_create(struct dev_types *dt, filter_mode_t mode);
 
-int persistent_filter_load(struct dm_pool *mem, struct dev_filter *f, struct dm_config_tree **cft_out);
+int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out);
 
 #endif 	/* _LVM_FILTER_H */
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index cf34e91..41955af 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -205,7 +205,7 @@ int munge_pvd(struct device *dev, struct pv_disk *pvd)
 
 static int _read_pvd(struct device *dev, struct pv_disk *pvd)
 {
-	if (!dev_read_buf(dev, UINT64_C(0), sizeof(*pvd), DEV_IO_FMT1, pvd)) {
+	if (!dev_read(dev, UINT64_C(0), sizeof(*pvd), DEV_IO_FMT1, pvd)) {
 		log_very_verbose("Failed to read PV data from %s",
 				 dev_name(dev));
 		return 0;
@@ -216,7 +216,7 @@ static int _read_pvd(struct device *dev, struct pv_disk *pvd)
 
 static int _read_lvd(struct device *dev, uint64_t pos, struct lv_disk *disk)
 {
-	if (!dev_read_buf(dev, pos, sizeof(*disk), DEV_IO_FMT1, disk))
+	if (!dev_read(dev, pos, sizeof(*disk), DEV_IO_FMT1, disk))
 		return_0;
 
 	_xlate_lvd(disk);
@@ -228,7 +228,7 @@ int read_vgd(struct device *dev, struct vg_disk *vgd, struct pv_disk *pvd)
 {
 	uint64_t pos = pvd->vg_on_disk.base;
 
-	if (!dev_read_buf(dev, pos, sizeof(*vgd), DEV_IO_FMT1, vgd))
+	if (!dev_read(dev, pos, sizeof(*vgd), DEV_IO_FMT1, vgd))
 		return_0;
 
 	_xlate_vgd(vgd);
@@ -252,7 +252,7 @@ static int _read_uuids(struct disk_list *data)
 	uint64_t end = pos + data->pvd.pv_uuidlist_on_disk.size;
 
 	while (pos < end && num_read < data->vgd.pv_cur) {
-		if (!dev_read_buf(data->dev, pos, sizeof(buffer), DEV_IO_FMT1, buffer))
+		if (!dev_read(data->dev, pos, sizeof(buffer), DEV_IO_FMT1, buffer))
 			return_0;
 
 		if (!(ul = dm_pool_alloc(data->mem, sizeof(*ul))))
@@ -311,7 +311,7 @@ static int _read_extents(struct disk_list *data)
 	if (!extents)
 		return_0;
 
-	if (!dev_read_buf(data->dev, pos, len, DEV_IO_FMT1, extents))
+	if (!dev_read(data->dev, pos, len, DEV_IO_FMT1, extents))
 		return_0;
 
 	_xlate_extents(extents, data->pvd.pe_total);
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 7d84e69..b3569e0 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -182,7 +182,7 @@ static struct volume_group *_format1_vg_read(struct format_instance *fid,
 				     struct metadata_area *mda __attribute__((unused)),
 				     struct cached_vg_fmtdata **vg_fmtdata __attribute__((unused)),
 				     unsigned *use_previous_vg __attribute__((unused)),
-				     int single_device __attribute__((unused)), unsigned ioflags)
+				     int single_device __attribute__((unused)))
 {
 	struct volume_group *vg;
 	struct disk_list *dl;
diff --git a/lib/format1/lvm1-label.c b/lib/format1/lvm1-label.c
index d334fdc..3b8a655 100644
--- a/lib/format1/lvm1-label.c
+++ b/lib/format1/lvm1-label.c
@@ -54,17 +54,15 @@ static int _lvm1_write(struct label *label __attribute__((unused)), void *buf __
 	return 0;
 }
 
-static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, unsigned ioflags,
-		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
+static int _lvm1_read(struct labeller *l, struct device *dev, void *buf,
+		 struct label **label)
 {
 	struct pv_disk *pvd = (struct pv_disk *) buf;
 	struct vg_disk vgd;
 	struct lvmcache_info *info;
-	struct label *label = NULL;
 	const char *vgid = FMT_LVM1_ORPHAN_VG_NAME;
 	const char *vgname = FMT_LVM1_ORPHAN_VG_NAME;
 	unsigned exported = 0;
-	int r = 0;
 
 	munge_pvd(dev, pvd);
 
@@ -78,9 +76,8 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, unsigne
 
 	if (!(info = lvmcache_add(l, (char *)pvd->pv_uuid, dev, vgname, vgid,
 				  exported)))
-		goto_out;
-
-	label = lvmcache_get_label(info);
+		return_0;
+	*label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, ((uint64_t)xlate32(pvd->pv_size)) << SECTOR_SHIFT);
 	lvmcache_set_ext_version(info, 0);
@@ -89,13 +86,7 @@ static int _lvm1_read(struct labeller *l, struct device *dev, void *buf, unsigne
 	lvmcache_del_bas(info);
 	lvmcache_make_valid(info);
 
-	r = 1;
-
-out:
-	if (read_label_callback_fn)
-		read_label_callback_fn(!r, 0, read_label_callback_context, label);
-
-	return r;
+	return 1;
 }
 
 static int _lvm1_initialise_label(struct labeller *l __attribute__((unused)), struct label *label)
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index 4b2e7fb..374ff44 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -40,7 +40,7 @@ static int __read_pool_disk(const struct format_type *fmt, struct device *dev,
 	char buf[512] __attribute__((aligned(8)));
 
 	/* FIXME: Need to check the cache here first */
-	if (!dev_read_buf(dev, UINT64_C(0), 512, DEV_IO_POOL, buf)) {
+	if (!dev_read(dev, UINT64_C(0), 512, DEV_IO_POOL, buf)) {
 		log_very_verbose("Failed to read PV data from %s",
 				 dev_name(dev));
 		return 0;
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index c699058..f6e5e01 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -103,7 +103,7 @@ static struct volume_group *_pool_vg_read(struct format_instance *fid,
 					  struct metadata_area *mda __attribute__((unused)),
 					  struct cached_vg_fmtdata **vg_fmtdata __attribute__((unused)),
 					  unsigned *use_previous_vg __attribute__((unused)),
-					  int single_device __attribute__((unused)), unsigned ioflags)
+					  int single_device __attribute__((unused)))
 {
 	struct volume_group *vg;
 	struct user_subpool *usp;
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 888a2eb..2e30a7b 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -55,19 +55,12 @@ static int _pool_write(struct label *label __attribute__((unused)), void *buf __
 	return 0;
 }
 
-static int _pool_read(struct labeller *l, struct device *dev, void *buf, unsigned ioflags,
-		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
+static int _pool_read(struct labeller *l, struct device *dev, void *buf,
+		 struct label **label)
 {
 	struct pool_list pl;
-	struct label *label;
-	int r;
 
-	r = read_pool_label(&pl, l, dev, buf, &label);
-
-	if (read_label_callback_fn)
-		read_label_callback_fn(!r, 0, read_label_callback_context, label);
-
-	return r;
+	return read_pool_label(&pl, l, dev, buf, label);
 }
 
 static int _pool_initialise_label(struct labeller *l __attribute__((unused)), struct label *label)
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 2186de8..72ec40b 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -135,8 +135,8 @@ static struct dm_list *_scan_archive(struct dm_pool *mem,
 
 	dm_list_init(results);
 
-	/* Use versionsort to handle numbers beyond 5 digits */
-	if ((count = scandir(dir, &dirent, NULL, versionsort)) < 0) {
+	/* Sort fails beyond 5-digit indexes */
+	if ((count = scandir(dir, &dirent, NULL, alphasort)) < 0) {
 		log_error("Couldn't scan the archive directory (%s).", dir);
 		return 0;
 	}
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 2c8e751..1eb6654 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -320,7 +320,7 @@ struct volume_group *backup_read_vg(struct cmd_context *cmd,
 	}
 
 	dm_list_iterate_items(mda, &tf->metadata_areas_in_use) {
-		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, NULL, NULL, 0, 0)))
+		if (!(vg = mda->ops->vg_read(tf, vg_name, mda, NULL, NULL, 0)))
 			stack;
 		break;
 	}
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 08e1cda..e535237 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -23,7 +23,6 @@
 #include "lvm-version.h"
 #include "toolcontext.h"
 #include "config-util.h"
-#include "layout.h"
 
 #include <stdarg.h>
 #include <time.h>
@@ -124,12 +123,11 @@ static int _extend_buffer(struct formatter *f)
 
 	log_debug_metadata("Doubling metadata output buffer to " FMTu32,
 			   f->data.buf.size * 2);
-	if (!(newbuf = dm_malloc_aligned(f->data.buf.size * 2, 0)))
-		return_0;
-
-	memcpy(newbuf, f->data.buf.start, f->data.buf.size);
-	free(f->data.buf.start);
-
+	if (!(newbuf = dm_realloc(f->data.buf.start,
+				   f->data.buf.size * 2))) {
+		log_error("Buffer reallocation failed.");
+		return 0;
+	}
 	f->data.buf.start = newbuf;
 	f->data.buf.size *= 2;
 
@@ -1066,7 +1064,7 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 		return_0;
 
 	f->data.buf.size = 65536;	/* Initial metadata limit */
-	if (!(f->data.buf.start = dm_malloc_aligned(f->data.buf.size, 0))) {
+	if (!(f->data.buf.start = dm_malloc(f->data.buf.size))) {
 		log_error("text_export buffer allocation failed");
 		goto out;
 	}
@@ -1081,12 +1079,7 @@ size_t text_vg_export_raw(struct volume_group *vg, const char *desc, char **buf)
 		goto_out;
 	}
 
-	f->data.buf.used += 1;	/* Terminating NUL */
-
-	/* Zero fill up to next alignment boundary */
-	memset(f->data.buf.start + f->data.buf.used, 0, MDA_ALIGNMENT - f->data.buf.used % MDA_ALIGNMENT);
-
-	r = f->data.buf.used;
+	r = f->data.buf.used + 1;
 	*buf = f->data.buf.start;
 
       out:
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 2e7e2b8..be9a8b9 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -37,12 +37,6 @@
 #include <dirent.h>
 #include <ctype.h>
 
-/*
- * Round up offset within buffer to next location that is an exact multiple of alignment.
- * (We shouldn't assume the start of the metadata area was aligned the same way when it was created.)
- */
-#define ALIGN_ABSOLUTE(offset, buffer_start, alignment) ((offset) + (alignment) - UINT64_C(1) - ((buffer_start) + (offset) + (alignment) - UINT64_C(1)) % (alignment))
-
 static struct format_instance *_text_create_text_instance(const struct format_type *fmt,
 							  const struct format_instance_ctx *fic);
 
@@ -182,10 +176,9 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 	uint64_t offset2;
 	size_t size;
 	size_t size2;
-	const char *buf = NULL;
+	char *buf=NULL;
 	struct device_area *area;
 	struct mda_context *mdac;
-	unsigned circular = 0;
 	int r=0;
 
 	mdac = (struct mda_context *) mda->metadata_locn;
@@ -197,7 +190,7 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 	if (!dev_open_readonly(area->dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fmt->cmd->mem, area, mda_is_primary(mda))))
+	if (!(mdah = raw_read_mda_header(fmt, area, mda_is_primary(mda))))
 		goto_out;
 
 	rlocn = mdah->raw_locns;
@@ -226,7 +219,6 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 							prev_sector);
 		if (prev_sector > prev_sector2)
 			goto_out;
-
 		/*
 		 * FIXME: for some reason, the whole metadata region from
 		 * area->start to area->start+area->size is not used.
@@ -235,13 +227,10 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 		 * "dm_config_maybe_section" returning true when there's no valid
 		 * metadata in a sector (sectors with all nulls).
 		 */
+		if (!(buf = dm_malloc(size + size2)))
+			goto_out;
 
-		circular = size2 ? 1 : 0;
-
-		if (circular) {
-			if (!(buf = dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)))))
-				goto_out;
-		} else if (!(buf = dev_read(area->dev, offset, size, MDA_CONTENT_REASON(mda_is_primary(mda)))))
+		if (!dev_read_circular(area->dev, offset, size, offset2, size2, MDA_CONTENT_REASON(mda_is_primary(mda)), buf))
 			goto_out;
 
 		/*
@@ -272,20 +261,20 @@ static int _pv_analyze_mda_raw (const struct format_type * fmt,
 				size += SECTOR_SIZE;
 			}
 		}
-		if (circular)
-			dm_free((void *)buf);
+		dm_free(buf);
 		buf = NULL;
 	}
 
 	r = 1;
  out:
-	if (circular)
-		dm_free((void *)buf);
+	dm_free(buf);
 	if (!dev_close(area->dev))
 		stack;
 	return r;
 }
 
+
+
 static int _text_lv_setup(struct format_instance *fid __attribute__((unused)),
 			  struct logical_volume *lv)
 {
@@ -326,27 +315,19 @@ static void _xlate_mdah(struct mda_header *mdah)
 	}
 }
 
-struct process_raw_mda_header_params {
-	struct mda_header *mdah;
-	struct device_area dev_area;
-	lvm_callback_fn_t mdah_callback_fn;
-	void *mdah_callback_context;
-	int ret;
-};
-
-static void _process_raw_mda_header(int failed, unsigned ioflags, void *context, const void *data)
+static int _raw_read_mda_header(struct mda_header *mdah, struct device_area *dev_area, int primary_mda)
 {
-	struct process_raw_mda_header_params *prmp = context;
-	struct mda_header *mdah = prmp->mdah;
-	struct device_area *dev_area = &prmp->dev_area;
-
-	if (!dev_close(dev_area->dev))
-		goto_bad;
+	if (!dev_open_readonly(dev_area->dev))
+		return_0;
 
-	if (failed)
-		goto_bad;
+	if (!dev_read(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda), mdah)) {
+		if (!dev_close(dev_area->dev))
+			stack;
+		return_0;
+	}
 
-	memcpy(mdah, data, MDA_HEADER_SIZE);
+	if (!dev_close(dev_area->dev))
+		return_0;
 
 	if (mdah->checksum_xl != xlate32(calc_crc(INITIAL_CRC, (uint8_t *)mdah->magic,
 						  MDA_HEADER_SIZE -
@@ -354,7 +335,7 @@ static void _process_raw_mda_header(int failed, unsigned ioflags, void *context,
 		log_error("Incorrect metadata area header checksum on %s"
 			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
-		goto bad;
+		return 0;
 	}
 
 	_xlate_mdah(mdah);
@@ -363,83 +344,42 @@ static void _process_raw_mda_header(int failed, unsigned ioflags, void *context,
 		log_error("Wrong magic number in metadata area header on %s"
 			  " at offset " FMTu64, dev_name(dev_area->dev),
 			  dev_area->start);
-		goto bad;
+		return 0;
 	}
 
 	if (mdah->version != FMTT_VERSION) {
 		log_error("Incompatible metadata area header version: %d on %s"
 			  " at offset " FMTu64, mdah->version,
 			  dev_name(dev_area->dev), dev_area->start);
-		goto bad;
+		return 0;
 	}
 
 	if (mdah->start != dev_area->start) {
 		log_error("Incorrect start sector in metadata area header: "
 			  FMTu64 " on %s at offset " FMTu64, mdah->start,
 			  dev_name(dev_area->dev), dev_area->start);
-		goto bad;
+		return 0;
 	}
 
-	goto out;
-
-bad:
-	prmp->ret = 0;
-out:
-	if (prmp->mdah_callback_fn)
-		prmp->mdah_callback_fn(!prmp->ret, ioflags, prmp->mdah_callback_context, mdah);
+	return 1;
 }
 
-static struct mda_header *_raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
-					       unsigned ioflags, lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context)
+struct mda_header *raw_read_mda_header(const struct format_type *fmt,
+				       struct device_area *dev_area, int primary_mda)
 {
 	struct mda_header *mdah;
-	struct process_raw_mda_header_params *prmp;
 
-	if (!(mdah = dm_pool_alloc(mem, MDA_HEADER_SIZE))) {
+	if (!(mdah = dm_pool_alloc(fmt->cmd->mem, MDA_HEADER_SIZE))) {
 		log_error("struct mda_header allocation failed");
 		return NULL;
 	}
 
-	if (!(prmp = dm_pool_zalloc(mem, sizeof (*prmp)))) {
-		log_error("struct process_raw_mda_header_params allocation failed");
-		dm_pool_free(mem, mdah);
+	if (!_raw_read_mda_header(mdah, dev_area, primary_mda)) {
+		dm_pool_free(fmt->cmd->mem, mdah);
 		return NULL;
 	}
 
-	if (!dev_open_readonly(dev_area->dev)) {
-		dm_pool_free(mem, mdah);
-		return_NULL;
-	}
-
-	prmp->mdah = mdah;
-	prmp->dev_area = *dev_area;
-	prmp->mdah_callback_fn = mdah_callback_fn;
-	prmp->mdah_callback_context = mdah_callback_context;
-	prmp->ret = 1;
-
-	dev_read_callback(dev_area->dev, dev_area->start, MDA_HEADER_SIZE, MDA_HEADER_REASON(primary_mda),
-			  ioflags, _process_raw_mda_header, prmp);
-	if (mdah_callback_fn)
-		return mdah;
-
-	if (!prmp->ret)
-		return_NULL;
-	else
-		return mdah;
-}
-
-struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda)
-{
-	return _raw_read_mda_header(mem, dev_area, primary_mda, 0, NULL, NULL);
-}
-
-int raw_read_mda_header_callback(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
-				 unsigned ioflags, lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context)
-{
-	if (!_raw_read_mda_header(mem, dev_area, primary_mda, ioflags, mdah_callback_fn, mdah_callback_context))
-		return_0;
-
-	return 1;
+	return mdah;
 }
 
 static int _raw_write_mda_header(const struct format_type *fmt,
@@ -467,13 +407,13 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 				       int *precommitted)
 {
 	size_t len;
+	char vgnamebuf[NAME_LEN + 2] __attribute__((aligned(8)));
 	struct raw_locn *rlocn, *rlocn_precommitted;
 	struct lvmcache_info *info;
 	struct lvmcache_vgsummary vgsummary_orphan = {
 		.vgname = FMT_TEXT_ORPHAN_VG_NAME,
 	};
 	int rlocn_was_ignored;
-	const char *buf;
 
 	memcpy(&vgsummary_orphan.vgid, FMT_TEXT_ORPHAN_VG_NAME, sizeof(FMT_TEXT_ORPHAN_VG_NAME));
 
@@ -508,12 +448,12 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 
 	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */
 	/* FIXME Ignore if checksum incorrect!!! */
-	if (!(buf = dev_read(dev_area->dev, dev_area->start + rlocn->offset,
-			     NAME_LEN + 2, MDA_CONTENT_REASON(primary_mda))))
+	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
+		      sizeof(vgnamebuf), MDA_CONTENT_REASON(primary_mda), vgnamebuf))
 		goto_bad;
 
-	if (!strncmp(buf, vgname, len = strlen(vgname)) &&
-	    (isspace(*(buf + len)) || *(buf + len) == '{'))
+	if (!strncmp(vgnamebuf, vgname, len = strlen(vgname)) &&
+	    (isspace(vgnamebuf[len]) || vgnamebuf[len] == '{'))
 		return rlocn;
 
 	log_debug_metadata("Volume group name found in %smetadata on %s at " FMTu64 " does "
@@ -530,46 +470,25 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 }
 
 /*
- * Find first aligned offset after end of existing metadata.
- * Based on the alignment provided, this is the exact offset to use for the new metadata.
- * The caller is responsible for validating the result.
+ * Determine offset for uncommitted metadata
  */
 static uint64_t _next_rlocn_offset(struct raw_locn *rlocn, struct mda_header *mdah, uint64_t mdac_area_start, uint64_t alignment)
 {
-	uint64_t old_end, new_start_offset;
-	int old_wrapped = 0;	/* Does the old metadata wrap around? */
+	uint64_t new_start_offset;
 
 	if (!rlocn)
 		/* Find an empty slot */
-		/* FIXME Assumes only one VG per mdah for now */
-		return ALIGN_ABSOLUTE(MDA_HEADER_SIZE, mdac_area_start, alignment);
+		/* FIXME Assume only one VG per mdah for now */
+		return alignment;
 
-	/* First find the end of the old metadata */
-	old_end = rlocn->offset + rlocn->size;
-
-	if (old_end > mdah->size) {
-		old_wrapped = 1;
-		old_end -= (mdah->size - MDA_HEADER_SIZE);
-	}
+	/* Calculate new start position within buffer rounded up to absolute alignment */
+	new_start_offset = rlocn->offset + rlocn->size +
+			   (alignment - (mdac_area_start + rlocn->offset + rlocn->size) % alignment);
 
-	/* Calculate new start position relative to start of buffer rounded up to absolute alignment */
-	new_start_offset = ALIGN_ABSOLUTE(old_end, mdac_area_start, alignment);
-
-	/* If new location is beyond the end of the buffer, return to start of circular buffer and realign */
-	if (new_start_offset >= mdah->size) {
-		/* If the start of the buffer is occupied, move past it */
-		if (old_wrapped || rlocn->offset == MDA_HEADER_SIZE)
-			new_start_offset = old_end;
-		else
-			new_start_offset = MDA_HEADER_SIZE;
- 
-		new_start_offset = ALIGN_ABSOLUTE(new_start_offset, mdac_area_start, alignment);
-	}
+	/* If new location is beyond the end of the buffer, wrap around back to start of circular buffer */
+	if (new_start_offset > mdah->size - MDA_HEADER_SIZE)
+		new_start_offset -= (mdah->size - MDA_HEADER_SIZE);
 
-	/*
-	 * Note that we don't check here that this location isn't inside the existing metadata.
-	 * If it is, then it means this value of alignment cannot be used.
-	 */
 	return new_start_offset;
 }
 
@@ -583,7 +502,7 @@ static int _raw_holds_vgname(struct format_instance *fid,
 	if (!dev_open_readonly(dev_area->dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, dev_area, 0)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, dev_area, 0)))
 		return_0;
 
 	if (_find_vg_rlocn(dev_area, mdah, 0, vgname, &noprecommit))
@@ -600,7 +519,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 					      struct device_area *area,
 					      struct cached_vg_fmtdata **vg_fmtdata,
 					      unsigned *use_previous_vg,
-					      int precommitted, unsigned ioflags,
+					      int precommitted,
 					      int single_device, int primary_mda)
 {
 	struct volume_group *vg = NULL;
@@ -610,7 +529,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 	char *desc;
 	uint32_t wrap = 0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, area, primary_mda)))
+	if (!(mdah = raw_read_mda_header(fid->fmt, area, primary_mda)))
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(area, mdah, primary_mda, vgname, &precommitted))) {
@@ -633,7 +552,7 @@ static struct volume_group *_vg_read_raw_area(struct format_instance *fid,
 				     (off_t) (area->start + rlocn->offset),
 				     (uint32_t) (rlocn->size - wrap),
 				     (off_t) (area->start + MDA_HEADER_SIZE),
-				     wrap, calc_crc, rlocn->checksum, ioflags, &when,
+				     wrap, calc_crc, rlocn->checksum, &when,
 				     &desc)) && (!use_previous_vg || !*use_previous_vg))
 		goto_out;
 
@@ -660,7 +579,7 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 					 struct metadata_area *mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
 					 unsigned *use_previous_vg,
-					 int single_device, unsigned ioflags)
+					 int single_device)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -668,7 +587,7 @@ static struct volume_group *_vg_read_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, ioflags, single_device, mda_is_primary(mda));
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 0, single_device, mda_is_primary(mda));
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -680,7 +599,7 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 						   const char *vgname,
 						   struct metadata_area *mda,
 						   struct cached_vg_fmtdata **vg_fmtdata,
-						   unsigned *use_previous_vg, unsigned ioflags)
+						   unsigned *use_previous_vg)
 {
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -688,7 +607,7 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	if (!dev_open_readonly(mdac->area.dev))
 		return_NULL;
 
-	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, ioflags, 0, mda_is_primary(mda));
+	vg = _vg_read_raw_area(fid, vgname, &mdac->area, vg_fmtdata, use_previous_vg, 1, 0, mda_is_primary(mda));
 
 	if (!dev_close(mdac->area.dev))
 		stack;
@@ -696,59 +615,6 @@ static struct volume_group *_vg_read_precommit_raw(struct format_instance *fid,
 	return vg;
 }
 
-static int _metadata_fits_into_buffer(struct mda_context *mdac, struct mda_header *mdah,
-				      struct raw_locn *rlocn, uint64_t new_wrap)
-{
-	uint64_t old_wrap = 0;	/* Amount of wrap around in existing metadata */
-	uint64_t old_end = 0;	/* The (byte after the) end of the existing metadata */
-	uint64_t new_end;	/* The (byte after the) end of the new metadata */
-	uint64_t old_start = 0;	/* The start of the existing metadata */
-	uint64_t new_start = mdac->rlocn.offset;	/* The proposed start of the new metadata */
-
-	/*
-	 * If the (aligned) start of the new metadata is already beyond the end
-	 * of the buffer this means it didn't fit with the given alignment.
-	 * (The caller has already tried to wrap it back to the start
-	 * of the buffer but the alignment pushed it back outside.)
-	 */
-	if (new_start >= mdah->size)
-		return_0;
-
-	/* Does the total amount of metadata, old and new, fit inside the buffer? */
-	if (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)
-		return_0;
-
-	/* If there's existing metadata, set old_start, old_end and old_wrap. */
-	if (rlocn) {
-		old_start = rlocn->offset;
-		old_end = old_start + rlocn->size;
-
-		/* Does the existing metadata wrap around the end of the buffer? */
-		if (old_end > mdah->size)
-			old_wrap = old_end - mdah->size;
-	}
-
-	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE : new_start + mdac->rlocn.size;
-
-	/* If both wrap around, there's necessarily overlap */
-	if (new_wrap && old_wrap)
-		return_0;
-
-	/* If there's no existing metadata, we're OK */
-	if (!rlocn)
-		return 1;
-
-	/* If either wraps around, there's overlap if the new end falls beyond the old start */
-	if ((new_wrap || old_wrap) && (new_end > old_start))
-		return_0;
-
-	/* If there's no wrap, check there's no overlap */
-	if (!new_wrap && !old_wrap && (old_end > new_start) && (old_start < new_end))
-		return_0;
-
-	return 1;
-}
-
 static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 			 struct metadata_area *mda)
 {
@@ -758,12 +624,10 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	struct mda_header *mdah;
 	struct pv_list *pvl;
 	int r = 0;
-	uint64_t new_wrap = 0;	/* Number of bytes of new metadata that wrap around to start of buffer */
-	uint64_t alignment = MDA_ALIGNMENT;
+	uint64_t new_wrap = 0, old_wrap = 0, new_end;
 	int found = 0;
 	int noprecommit = 0;
 	const char *old_vg_name = NULL;
-	uint64_t new_size_rounded = 0;
 
 	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
 	dm_list_iterate_items(pvl, &vg->pvs) {
@@ -778,19 +642,12 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!found)
 		return 1;
 
-	/*
-	 * This is paired with the following closes:
-	 *  - at the end of this fn if returning 0
-	 *  - in _vg_commit_raw_rlocn regardless of return code
-	 *    which handles commit (but not pre-commit) and revert.
-	 */
 	if (!dev_open(mdac->area.dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, &mdac->area, mda_is_primary(mda))))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
-	/* Following space is zero-filled up to the next MDA_ALIGNMENT boundary */
 	if (!fidtc->raw_metadata_buf &&
 	    !(fidtc->raw_metadata_buf_size =
 			text_vg_export_raw(vg, "", &fidtc->raw_metadata_buf))) {
@@ -800,64 +657,37 @@ static int _vg_write_raw(struct format_instance *fid, struct volume_group *vg,
 
 	rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit);
 
+	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, MDA_ORIGINAL_ALIGNMENT);
 	mdac->rlocn.size = fidtc->raw_metadata_buf_size;
 
-	/* Find where the new metadata would be written with our preferred alignment */
-	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, alignment);
-
-	/* If metadata extends beyond the buffer, return to the start instead of wrapping it */
 	if (mdac->rlocn.offset + mdac->rlocn.size > mdah->size)
-		mdac->rlocn.offset = ALIGN_ABSOLUTE(MDA_HEADER_SIZE, mdac->area.start, alignment);
+		new_wrap = (mdac->rlocn.offset + mdac->rlocn.size) - mdah->size;
 
-	/*
-	 * If the metadata doesn't fit into the buffer correctly with these
-	 * settings, fall back to the 512-byte alignment used by the original
-	 * LVM2 code and allow the metadata to be split into two parts,
-	 * wrapping around from the end of the circular buffer back to the
-	 * beginning.
-	 */
-	if (!_metadata_fits_into_buffer(mdac, mdah, rlocn, 0)) {
-		alignment = MDA_ORIGINAL_ALIGNMENT;
-		mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah, mdac->area.start, alignment);
+	if (rlocn && (rlocn->offset + rlocn->size > mdah->size))
+		old_wrap = (rlocn->offset + rlocn->size) - mdah->size;
 
-		/* Does the new metadata wrap around? */
-		if (mdac->rlocn.offset + mdac->rlocn.size > mdah->size)
-			new_wrap = (mdac->rlocn.offset + mdac->rlocn.size) - mdah->size;
-		else
-			new_wrap = 0;
-
-		if (!_metadata_fits_into_buffer(mdac, mdah, rlocn, new_wrap)) {
-			log_error("VG %s metadata on %s (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes with " FMTu64 " used)",
-				  vg->name, dev_name(mdac->area.dev), mdac->rlocn.size, mdah->size - MDA_HEADER_SIZE, rlocn ? rlocn->size : 0);
-			goto out;
-		}
+	new_end = new_wrap ? new_wrap + MDA_HEADER_SIZE :
+			    mdac->rlocn.offset + mdac->rlocn.size;
 
-		new_size_rounded = mdac->rlocn.size;
-	} else {
-		/* Round up to a multiple of the new alignment */
-		if (mdac->rlocn.offset + new_size_rounded < mdah->size)
-			new_size_rounded = (mdac->rlocn.size | (alignment - 1)) + 1;
-		else
-			new_size_rounded = mdac->rlocn.size;
+	if ((new_wrap && old_wrap) ||
+	    (rlocn && (new_wrap || old_wrap) && (new_end > rlocn->offset)) ||
+	    (MDA_HEADER_SIZE + (rlocn ? rlocn->size : 0) + mdac->rlocn.size >= mdah->size)) {
+		log_error("VG %s metadata on %s (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes with " FMTu64 " used)",
+			  vg->name, dev_name(mdac->area.dev), mdac->rlocn.size, mdah->size - MDA_HEADER_SIZE, rlocn ? rlocn->size : 0);
+		goto out;
 	}
 
-	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64 " (rounded to " FMTu64 ") of " FMTu64 " aligned to " FMTu64,
+	log_debug_metadata("Writing %s metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64,
 			    vg->name, dev_name(mdac->area.dev), mdac->area.start +
-			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap, new_size_rounded, mdac->rlocn.size, alignment);
+			    mdac->rlocn.offset, mdac->rlocn.size - new_wrap, mdac->rlocn.size);
 
-	if (!new_wrap) {
-		/* Write text out, in alignment-sized blocks */
-		if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
-			       (size_t) new_size_rounded, MDA_CONTENT_REASON(mda_is_primary(mda)),
-			       fidtc->raw_metadata_buf))
-			goto_out;
-	} else {
-		/* Write text out, circularly */
-		if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
-			       (size_t) (mdac->rlocn.size - new_wrap), MDA_CONTENT_REASON(mda_is_primary(mda)),
-			       fidtc->raw_metadata_buf))
-			goto_out;
+	/* Write text out, circularly */
+	if (!dev_write(mdac->area.dev, mdac->area.start + mdac->rlocn.offset,
+		       (size_t) (mdac->rlocn.size - new_wrap), MDA_CONTENT_REASON(mda_is_primary(mda)),
+		       fidtc->raw_metadata_buf))
+		goto_out;
 
+	if (new_wrap) {
 		log_debug_metadata("Writing wrapped metadata to %s at " FMTu64 " len " FMTu64 " of " FMTu64,
 				  dev_name(mdac->area.dev), mdac->area.start +
 				  MDA_HEADER_SIZE, new_wrap, mdac->rlocn.size);
@@ -919,7 +749,7 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 	if (!found)
 		return 1;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, &mdac->area, mda_is_primary(mda))))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), old_vg_name ? : vg->name, &noprecommit))) {
@@ -957,9 +787,10 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 		rlocn->offset = mdac->rlocn.offset;
 		rlocn->size = mdac->rlocn.size;
 		rlocn->checksum = mdac->rlocn.checksum;
-		log_debug_metadata("%sCommitting %s %smetadata (%u) to %s header at " FMTu64 " (offset " FMTu64 ", size " FMTu64 ")",
-				   precommit ? "Pre-" : "", vg->name, mda_is_ignored(mda) ? "(ignored) " : "", vg->seqno,
-				   dev_name(mdac->area.dev), mdac->area.start, mdac->rlocn.offset, mdac->rlocn.size);
+		log_debug_metadata("%sCommitting %s %smetadata (%u) to %s header at "
+			  FMTu64, precommit ? "Pre-" : "", vg->name, 
+			  mda_is_ignored(mda) ? "(ignored) " : "", vg->seqno,
+			  dev_name(mdac->area.dev), mdac->area.start);
 	} else
 		log_debug_metadata("Wiping pre-committed %s %smetadata from %s "
 				   "header at " FMTu64, vg->name,
@@ -979,7 +810,6 @@ static int _vg_commit_raw_rlocn(struct format_instance *fid,
 
       out:
 	if (!precommit) {
-		/* This is an paired with the open at the start of _vg_write_raw */
 		if (!dev_close(mdac->area.dev))
 			stack;
 
@@ -1039,7 +869,7 @@ static int _vg_remove_raw(struct format_instance *fid, struct volume_group *vg,
 	if (!dev_open(mdac->area.dev))
 		return_0;
 
-	if (!(mdah = raw_read_mda_header(fid->fmt->cmd->mem, &mdac->area, mda_is_primary(mda))))
+	if (!(mdah = raw_read_mda_header(fid->fmt, &mdac->area, mda_is_primary(mda))))
 		goto_out;
 
 	if (!(rlocn = _find_vg_rlocn(&mdac->area, mdah, mda_is_primary(mda), vg->name, &noprecommit))) {
@@ -1102,8 +932,7 @@ static struct volume_group *_vg_read_file(struct format_instance *fid,
 					  struct metadata_area *mda,
 					  struct cached_vg_fmtdata **vg_fmtdata,
 					  unsigned *use_previous_vg __attribute__((unused)),
-					  int single_device __attribute__((unused)),
-					  unsigned ioflags __attribute__((unused)))
+					  int single_device __attribute__((unused)))
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 
@@ -1114,8 +943,7 @@ static struct volume_group *_vg_read_precommit_file(struct format_instance *fid,
 						    const char *vgname,
 						    struct metadata_area *mda,
 						    struct cached_vg_fmtdata **vg_fmtdata,
-						    unsigned *use_previous_vg __attribute__((unused)),
-						    unsigned ioflags __attribute__((unused)))
+						    unsigned *use_previous_vg __attribute__((unused)))
 {
 	struct text_context *tc = (struct text_context *) mda->metadata_locn;
 	struct volume_group *vg;
@@ -1347,83 +1175,41 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 	return 1;
 }
 
-struct vgname_from_mda_params{
-	const struct format_type *fmt;
-	const struct mda_header *mdah;
-	struct device_area *dev_area;
-	int primary_mda;
-	struct lvmcache_vgsummary *vgsummary;
-	uint64_t *mda_free_sectors;
-	lvm_callback_fn_t update_vgsummary_fn;
-	void *update_vgsummary_context;
-	uint32_t wrap;
-	unsigned used_cached_metadata;
-	int ret;
-};
-
-static void _vgname_from_mda_process(int failed, unsigned ioflags, void *context, const void *data)
+int vgname_from_mda(const struct format_type *fmt,
+		    struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
+		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors)
 {
-	struct vgname_from_mda_params *vfmp = context;
-	const struct mda_header *mdah = vfmp->mdah;
-	struct device_area *dev_area = vfmp->dev_area;
-	struct lvmcache_vgsummary *vgsummary = vfmp->vgsummary;
-	uint64_t *mda_free_sectors = vfmp->mda_free_sectors;
-	const struct raw_locn *rlocn = mdah->raw_locns;
+	struct raw_locn *rlocn;
+	uint32_t wrap = 0;
+	unsigned int len = 0;
+	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
 	uint64_t buffer_size, current_usage;
+	unsigned used_cached_metadata = 0;
 
-	if (failed) {
-		vfmp->ret = 0;
-		goto_out;
-	}
-
-	/* Ignore this entry if the characters aren't permissible */
-	if (!validate_name(vgsummary->vgname)) {
-		vfmp->ret = 0;
-		goto_out;
-	}
-
-	log_debug_metadata("%s: %s metadata at " FMTu64 " size " FMTu64 " with wrap " FMTu32
-			   " (in area at " FMTu64 " size " FMTu64
-			   ") for %s (" FMTVGID ")",
-			   dev_name(dev_area->dev),
-			   vfmp->used_cached_metadata ? "Using cached" : "Found",
-			   dev_area->start + rlocn->offset,
-			   rlocn->size, vfmp->wrap, dev_area->start, dev_area->size, vgsummary->vgname,
-			   (char *)&vgsummary->vgid);
-
-	if (mda_free_sectors) {
-		current_usage = ALIGN_ABSOLUTE(rlocn->size, dev_area->start + rlocn->offset, MDA_ALIGNMENT);
-
-		buffer_size = mdah->size - MDA_HEADER_SIZE;
+	if (mda_free_sectors)
+		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
 
-		if (current_usage * 2 >= buffer_size)
-			*mda_free_sectors = UINT64_C(0);
-		else
-			*mda_free_sectors = ((buffer_size - 2 * current_usage) / 2) >> SECTOR_SHIFT;
+	if (!mdah) {
+		log_error(INTERNAL_ERROR "vgname_from_mda called with NULL pointer for mda_header");
+		return 0;
 	}
 
-out:
-	vfmp->update_vgsummary_fn(!vfmp->ret, ioflags, vfmp->update_vgsummary_context, vfmp->vgsummary);
-}
-
-static void _vgname_from_mda_validate(int failed, unsigned ioflags, void *context, const void *data)
-{
-	struct vgname_from_mda_params *vfmp = context;
-	const char *buffer = data;
-	const struct format_type *fmt = vfmp->fmt;
-	const struct mda_header *mdah = vfmp->mdah;
-	struct device_area *dev_area = vfmp->dev_area;
-	struct lvmcache_vgsummary *vgsummary = vfmp->vgsummary;
-	const struct raw_locn *rlocn = mdah->raw_locns;
-	unsigned len = 0;
-	char buf[NAME_LEN + 1] __attribute__((aligned(8)));
+	/* FIXME Cope with returning a list */
+	rlocn = mdah->raw_locns;
 
-	if (failed) {
-		vfmp->ret = 0;
-		goto_out;
+	/*
+	 * If no valid offset, do not try to search for vgname
+	 */
+	if (!rlocn->offset) {
+		log_debug("%s: found metadata with offset 0.",
+			  dev_name(dev_area->dev));
+		return 0;
 	}
 
-	memcpy(buf, buffer, NAME_LEN);
+	/* Do quick check for a vgname */
+	if (!dev_read(dev_area->dev, dev_area->start + rlocn->offset,
+		      NAME_LEN, MDA_CONTENT_REASON(primary_mda), buf))
+		return_0;
 
 	while (buf[len] && !isspace(buf[len]) && buf[len] != '{' &&
 	       len < (NAME_LEN - 1))
@@ -1432,20 +1218,17 @@ static void _vgname_from_mda_validate(int failed, unsigned ioflags, void *contex
 	buf[len] = '\0';
 
 	/* Ignore this entry if the characters aren't permissible */
-	if (!validate_name(buf)) {
-		vfmp->ret = 0;
-		goto_out;
-	}
+	if (!validate_name(buf))
+		return_0;
 
 	/* We found a VG - now check the metadata */
 	if (rlocn->offset + rlocn->size > mdah->size)
-		vfmp->wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
+		wrap = (uint32_t) ((rlocn->offset + rlocn->size) - mdah->size);
 
-	if (vfmp->wrap > rlocn->offset) {
+	if (wrap > rlocn->offset) {
 		log_error("%s: metadata (" FMTu64 " bytes) too large for circular buffer (" FMTu64 " bytes)",
 			  dev_name(dev_area->dev), rlocn->size, mdah->size - MDA_HEADER_SIZE);
-		vfmp->ret = 0;
-		goto out;
+		return 0;
 	}
 
 	/* Did we see this metadata before? */
@@ -1453,75 +1236,42 @@ static void _vgname_from_mda_validate(int failed, unsigned ioflags, void *contex
 	vgsummary->mda_size = rlocn->size;
 
 	if (lvmcache_lookup_mda(vgsummary))
-		vfmp->used_cached_metadata = 1;
+		used_cached_metadata = 1;
 
 	/* FIXME 64-bit */
-	if (!text_vgsummary_import(fmt, dev_area->dev, MDA_CONTENT_REASON(vfmp->primary_mda),
+	if (!text_vgsummary_import(fmt, dev_area->dev, MDA_CONTENT_REASON(primary_mda),
 				(off_t) (dev_area->start + rlocn->offset),
-				(uint32_t) (rlocn->size - vfmp->wrap),
+				(uint32_t) (rlocn->size - wrap),
 				(off_t) (dev_area->start + MDA_HEADER_SIZE),
-				vfmp->wrap, calc_crc, vgsummary->vgname ? 1 : 0, ioflags,
-				vgsummary, _vgname_from_mda_process, vfmp)) {
-		vfmp->ret = 0;
-		goto_out;
-	}
-
-out:
-	if (!vfmp->ret && vfmp->update_vgsummary_fn)
-		vfmp->update_vgsummary_fn(1, ioflags, vfmp->update_vgsummary_context, vfmp->vgsummary);
-}
-
-int vgname_from_mda(const struct format_type *fmt,
-		    const struct mda_header *mdah, int primary_mda, struct device_area *dev_area,
-		    struct lvmcache_vgsummary *vgsummary, uint64_t *mda_free_sectors, unsigned ioflags,
-		    lvm_callback_fn_t update_vgsummary_fn, void *update_vgsummary_context)
-{
-	const struct raw_locn *rlocn;
-	struct vgname_from_mda_params *vfmp;
-
-	if (mda_free_sectors)
-		*mda_free_sectors = ((dev_area->size - MDA_HEADER_SIZE) / 2) >> SECTOR_SHIFT;
+				wrap, calc_crc, vgsummary->vgname ? 1 : 0,
+				vgsummary))
+		return_0;
 
-	if (!mdah) {
-		log_error(INTERNAL_ERROR "vgname_from_mda called with NULL pointer for mda_header");
-		return 0;
-	}
+	/* Ignore this entry if the characters aren't permissible */
+	if (!validate_name(vgsummary->vgname))
+		return_0;
 
-	/* FIXME Cope with returning a list */
-	rlocn = mdah->raw_locns;
+	log_debug_metadata("%s: %s metadata at " FMTu64 " size " FMTu64
+			   " (in area at " FMTu64 " size " FMTu64
+			   ") for %s (" FMTVGID ")",
+			   dev_name(dev_area->dev),
+			   used_cached_metadata ? "Using cached" : "Found",
+			   dev_area->start + rlocn->offset,
+			   rlocn->size, dev_area->start, dev_area->size, vgsummary->vgname,
+			   (char *)&vgsummary->vgid);
 
-	/*
-	 * If no valid offset, do not try to search for vgname
-	 */
-	if (!rlocn->offset) {
-		log_debug("%s: found metadata with offset 0.",
-			  dev_name(dev_area->dev));
-		return 0;
-	}
+	if (mda_free_sectors) {
+		current_usage = (rlocn->size + SECTOR_SIZE - UINT64_C(1)) -
+				 (rlocn->size + SECTOR_SIZE - UINT64_C(1)) % SECTOR_SIZE;
+		buffer_size = mdah->size - MDA_HEADER_SIZE;
 
-	if (!(vfmp = dm_pool_zalloc(fmt->cmd->mem, sizeof(*vfmp)))) {
-		log_error("vgname_from_mda_params allocation failed");
-		return 0;
+		if (current_usage * 2 >= buffer_size)
+			*mda_free_sectors = UINT64_C(0);
+		else
+			*mda_free_sectors = ((buffer_size - 2 * current_usage) / 2) >> SECTOR_SHIFT;
 	}
 
-	vfmp->fmt = fmt;
-	vfmp->mdah = mdah;
-	vfmp->dev_area = dev_area;
-	vfmp->vgsummary = vgsummary;
-	vfmp->primary_mda = primary_mda;
-	vfmp->mda_free_sectors = mda_free_sectors;
-	vfmp->update_vgsummary_fn = update_vgsummary_fn;
-	vfmp->update_vgsummary_context = update_vgsummary_context;
-	vfmp->ret = 1;
-
-	/* Do quick check for a vgname */
-	/* We cannot read the full metadata here because the name has to be validated before we use the size field */
-	dev_read_callback(dev_area->dev, dev_area->start + rlocn->offset, NAME_LEN, MDA_CONTENT_REASON(primary_mda),
-			       ioflags, _vgname_from_mda_validate, vfmp);
-	if (update_vgsummary_fn)
-		return 1;
-	else
-		return vfmp->ret;
+	return 1;
 }
 
 static int _scan_raw(const struct format_type *fmt, const char *vgname __attribute__((unused)))
@@ -1546,14 +1296,14 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 			continue;
 		}
 
-		if (!(mdah = raw_read_mda_header(fmt->cmd->mem, &rl->dev_area, 0))) {
+		if (!(mdah = raw_read_mda_header(fmt, &rl->dev_area, 0))) {
 			stack;
 			goto close_dev;
 		}
 
 		/* TODO: caching as in vgname_from_mda() (trigger this code?) */
-		if (vgname_from_mda(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL, 0, NULL, NULL)) {
-			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0, 0, 0);
+		if (vgname_from_mda(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
+			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0, 0);
 			if (vg)
 				lvmcache_update_vg(vg, 0);
 		}
@@ -2024,8 +1774,9 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 				struct dm_config_node *parent)
 {
 	struct mda_context *mdc = (struct mda_context *) mda->metadata_locn;
+	char mdah[MDA_HEADER_SIZE]; /* temporary */
 
-	if (!mdc || !_raw_read_mda_header(cft->mem, &mdc->area, mda_is_primary(mda), 0, NULL, NULL))
+	if (!mdc || !_raw_read_mda_header((struct mda_header *)mdah, &mdc->area, mda_is_primary(mda)))
 		return 1; /* pretend the MDA does not exist */
 
 	return config_make_nodes(cft, parent, NULL,
diff --git a/lib/format_text/import-export.h b/lib/format_text/import-export.h
index 2c329d0..894d881 100644
--- a/lib/format_text/import-export.h
+++ b/lib/format_text/import-export.h
@@ -80,7 +80,7 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
 				       checksum_fn_t checksum_fn,
-				       uint32_t checksum, unsigned ioflags,
+				       uint32_t checksum,
 				       time_t *when, char **desc);
 
 int text_vgsummary_import(const struct format_type *fmt,
@@ -88,9 +88,7 @@ int text_vgsummary_import(const struct format_type *fmt,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
 		       checksum_fn_t checksum_fn,
-		       int checksum_only, unsigned ioflags,
-		       struct lvmcache_vgsummary *vgsummary,
-		       lvm_callback_fn_t process_vgsummary_fn,
-		       void *process_vgsummary_context);
+		       int checksum_only,
+		       struct lvmcache_vgsummary *vgsummary);
 
 #endif
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 0138ddd..da4cefd 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -16,7 +16,6 @@
 #include "lib.h"
 #include "metadata.h"
 #include "import-export.h"
-#include "toolcontext.h"
 
 /* FIXME Use tidier inclusion method */
 static struct text_vg_version_ops *(_text_vsn_list[2]);
@@ -33,55 +32,6 @@ static void _init_text_import(void)
 	_text_import_initialised = 1;
 }
 
-struct import_vgsummary_params {
-	const struct format_type *fmt;
-	struct dm_config_tree *cft;
-	int checksum_only;
-	struct lvmcache_vgsummary *vgsummary;
-	lvm_callback_fn_t process_vgsummary_fn;
-	void *process_vgsummary_context;
-	int ret;
-};
-
-static void _import_vgsummary(int failed, unsigned ioflags, void *context, const void *data)
-{
-	struct import_vgsummary_params *ivsp = context;
-	struct text_vg_version_ops **vsn;
-
-	if (failed) {
-		ivsp->ret = 0;
-		goto_out;
-	}
-
-	if (ivsp->checksum_only)
-		/* Checksum matches already-cached content - no need to reparse. */
-		goto out;
-
-	/*
-	 * Find a set of version functions that can read this file
-	 */
-	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
-		if (!(*vsn)->check_version(ivsp->cft))
-			continue;
-
-		if (!(*vsn)->read_vgsummary(ivsp->fmt, ivsp->cft, ivsp->vgsummary)) {
-			ivsp->ret = 0;
-			goto_out;
-		}
-
-		goto out;
-	}
-
-	/* Nothing found */
-	ivsp->ret = 0;
-
-out:
-	config_destroy(ivsp->cft);
-
-	if (ivsp->process_vgsummary_fn)
-		ivsp->process_vgsummary_fn(!ivsp->ret, ioflags, ivsp->process_vgsummary_context, NULL);
-}
-
 /*
  * Find out vgname on a given device.
  */
@@ -90,76 +40,30 @@ int text_vgsummary_import(const struct format_type *fmt,
 		       off_t offset, uint32_t size,
 		       off_t offset2, uint32_t size2,
 		       checksum_fn_t checksum_fn,
-		       int checksum_only, unsigned ioflags,
-		       struct lvmcache_vgsummary *vgsummary,
-		       lvm_callback_fn_t process_vgsummary_fn,
-		       void *process_vgsummary_context)
+		       int checksum_only,
+		       struct lvmcache_vgsummary *vgsummary)
 {
-	struct import_vgsummary_params *ivsp;
+	struct dm_config_tree *cft;
+	struct text_vg_version_ops **vsn;
+	int r = 0;
 
 	_init_text_import();
 
-	if (!(ivsp = dm_pool_zalloc(fmt->cmd->mem, sizeof(*ivsp)))) {
-		log_error("Failed to allocate import_vgsummary_params struct.");
-		return 0;
-	}
-
-	if (!(ivsp->cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0)))
+	if (!(cft = config_open(CONFIG_FILE_SPECIAL, NULL, 0)))
 		return_0;
 
-	ivsp->fmt = fmt;
-	ivsp->checksum_only = checksum_only;
-	ivsp->vgsummary = vgsummary;
-	ivsp->process_vgsummary_fn = process_vgsummary_fn;
-	ivsp->process_vgsummary_context = process_vgsummary_context;
-	ivsp->ret = 1;
-
-	if (!dev) {
-		if (!config_file_read(fmt->cmd->mem, ivsp->cft)) {
-			log_error("Couldn't read volume group metadata.");
-			ivsp->ret = 0;
-		}
-		_import_vgsummary(!ivsp->ret, ioflags, ivsp, NULL);
-	} else if (!config_file_read_fd(fmt->cmd->mem, ivsp->cft, dev, reason, offset, size,
-					offset2, size2, checksum_fn,
-					vgsummary->mda_checksum,
-					checksum_only, 1, ioflags, &_import_vgsummary, ivsp)) {
+	if ((!dev && !config_file_read(cft)) ||
+	    (dev && !config_file_read_fd(cft, dev, reason, offset, size,
+					 offset2, size2, checksum_fn,
+					 vgsummary->mda_checksum,
+					 checksum_only, 1))) {
 		log_error("Couldn't read volume group metadata.");
-		return 0;
+		goto out;
 	}
 
-	return ivsp->ret;
-}
-
-struct cached_vg_fmtdata {
-        uint32_t cached_mda_checksum;
-        size_t cached_mda_size;
-};
-
-struct import_vg_params {
-	struct format_instance *fid;
-	struct dm_config_tree *cft;
-	int single_device;
-	int skip_parse;
-	unsigned *use_previous_vg;
-	struct volume_group *vg;
-	uint32_t checksum;
-	uint32_t total_size;
-	time_t *when;
-	struct cached_vg_fmtdata **vg_fmtdata;
-	char **desc;
-};
-
-static void _import_vg(int failed, unsigned ioflags, void *context, const void *data)
-{
-	struct import_vg_params *ivp = context;
-	struct text_vg_version_ops **vsn;
-
-	ivp->vg = NULL;
-
-	if (ivp->skip_parse) {
-		if (ivp->use_previous_vg)
-			*ivp->use_previous_vg = 1;
+	if (checksum_only) {
+		/* Checksum matches already-cached content - no need to reparse. */
+		r = 1;
 		goto out;
 	}
 
@@ -167,28 +71,26 @@ static void _import_vg(int failed, unsigned ioflags, void *context, const void *
 	 * Find a set of version functions that can read this file
 	 */
 	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
-		if (!(*vsn)->check_version(ivp->cft))
+		if (!(*vsn)->check_version(cft))
 			continue;
 
-		if (!(ivp->vg = (*vsn)->read_vg(ivp->fid, ivp->cft, ivp->single_device, 0)))
+		if (!(*vsn)->read_vgsummary(fmt, cft, vgsummary))
 			goto_out;
 
-		(*vsn)->read_desc(ivp->vg->vgmem, ivp->cft, ivp->when, ivp->desc);
+		r = 1;
 		break;
 	}
 
-	if (ivp->vg && ivp->vg_fmtdata && *ivp->vg_fmtdata) {
-		(*ivp->vg_fmtdata)->cached_mda_size = ivp->total_size;
-		(*ivp->vg_fmtdata)->cached_mda_checksum = ivp->checksum;
-	}
-
-	if (ivp->use_previous_vg)
-		*ivp->use_previous_vg = 0;
-
-out:
-	config_destroy(ivp->cft);
+      out:
+	config_destroy(cft);
+	return r;
 }
 
+struct cached_vg_fmtdata {
+        uint32_t cached_mda_checksum;
+        size_t cached_mda_size;
+};
+
 struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       const char *file,
 				       struct cached_vg_fmtdata **vg_fmtdata,
@@ -198,10 +100,13 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 				       off_t offset, uint32_t size,
 				       off_t offset2, uint32_t size2,
 				       checksum_fn_t checksum_fn,
-				       uint32_t checksum, unsigned ioflags,
+				       uint32_t checksum,
 				       time_t *when, char **desc)
 {
-	struct import_vg_params *ivp;
+	struct volume_group *vg = NULL;
+	struct dm_config_tree *cft;
+	struct text_vg_version_ops **vsn;
+	int skip_parse;
 
 	if (vg_fmtdata && !*vg_fmtdata &&
 	    !(*vg_fmtdata = dm_pool_zalloc(fid->mem, sizeof(**vg_fmtdata)))) {
@@ -209,48 +114,56 @@ struct volume_group *text_vg_import_fd(struct format_instance *fid,
 		return NULL;
 	}
 
-	if (!(ivp = dm_pool_zalloc(fid->fmt->cmd->mem, sizeof(*ivp)))) {
-		log_error("Failed to allocate import_vgsummary_params struct.");
-		return NULL;
-	}
-
 	_init_text_import();
 
-	ivp->fid = fid;
-	ivp->when = when;
-	*ivp->when = 0;
-	ivp->desc = desc;
-	*ivp->desc = NULL;
-	ivp->single_device = single_device;
-	ivp->use_previous_vg = use_previous_vg;
-	ivp->checksum = checksum;
-	ivp->total_size = size + size2;
-	ivp->vg_fmtdata = vg_fmtdata;
-
-	if (!(ivp->cft = config_open(CONFIG_FILE_SPECIAL, file, 0)))
+	*desc = NULL;
+	*when = 0;
+
+	if (!(cft = config_open(CONFIG_FILE_SPECIAL, file, 0)))
 		return_NULL;
 
 	/* Does the metadata match the already-cached VG? */
-	ivp->skip_parse = vg_fmtdata && 
-			  ((*vg_fmtdata)->cached_mda_checksum == checksum) &&
-			  ((*vg_fmtdata)->cached_mda_size == ivp->total_size);
+	skip_parse = vg_fmtdata && 
+		     ((*vg_fmtdata)->cached_mda_checksum == checksum) &&
+		     ((*vg_fmtdata)->cached_mda_size == (size + size2));
+
+	if ((!dev && !config_file_read(cft)) ||
+	    (dev && !config_file_read_fd(cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
+					 offset2, size2, checksum_fn, checksum,
+					 skip_parse, 1)))
+		goto_out;
 
-	if (!dev && !config_file_read(fid->mem, ivp->cft)) {
-		config_destroy(ivp->cft);
-		return_NULL;
+	if (skip_parse) {
+		if (use_previous_vg)
+			*use_previous_vg = 1;
+		goto out;
 	}
 
-	if (dev) {
-		if (!config_file_read_fd(fid->mem, ivp->cft, dev, MDA_CONTENT_REASON(primary_mda), offset, size,
-					offset2, size2, checksum_fn, checksum,
-					ivp->skip_parse, 1, ioflags, &_import_vg, ivp)) {
-			config_destroy(ivp->cft);
-			return_NULL;
-		}
-	} else
-		_import_vg(0, 0, ivp, NULL);
+	/*
+	 * Find a set of version functions that can read this file
+	 */
+	for (vsn = &_text_vsn_list[0]; *vsn; vsn++) {
+		if (!(*vsn)->check_version(cft))
+			continue;
+
+		if (!(vg = (*vsn)->read_vg(fid, cft, single_device, 0)))
+			goto_out;
+
+		(*vsn)->read_desc(vg->vgmem, cft, when, desc);
+		break;
+	}
+
+	if (vg && vg_fmtdata && *vg_fmtdata) {
+		(*vg_fmtdata)->cached_mda_size = (size + size2);
+		(*vg_fmtdata)->cached_mda_checksum = checksum;
+	}
 
-	return ivp->vg;
+	if (use_previous_vg)
+		*use_previous_vg = 0;
+
+      out:
+	config_destroy(cft);
+	return vg;
 }
 
 struct volume_group *text_vg_import_file(struct format_instance *fid,
@@ -258,7 +171,7 @@ struct volume_group *text_vg_import_file(struct format_instance *fid,
 					 time_t *when, char **desc)
 {
 	return text_vg_import_fd(fid, file, NULL, NULL, 0, NULL, 0, (off_t)0, 0, (off_t)0, 0, NULL, 0,
-				 0, when, desc);
+				 when, desc);
 }
 
 static struct volume_group *_import_vg_from_config_tree(const struct dm_config_tree *cft,
diff --git a/lib/format_text/layout.h b/lib/format_text/layout.h
index 98a0b36..1746b9c 100644
--- a/lib/format_text/layout.h
+++ b/lib/format_text/layout.h
@@ -17,7 +17,6 @@
 #define _LVM_TEXT_LAYOUT_H
 
 #include "config.h"
-#include "format-text.h"
 #include "metadata.h"
 #include "lvmcache.h"
 #include "uuid.h"
@@ -81,9 +80,8 @@ struct mda_header {
 	struct raw_locn raw_locns[0];	/* NULL-terminated list */
 } __attribute__ ((packed));
 
-struct mda_header *raw_read_mda_header(struct dm_pool *mem, struct device_area *dev_area, int primary_mda);
-int raw_read_mda_header_callback(struct dm_pool *mem, struct device_area *dev_area, int primary_mda,
-				 unsigned ioflags, lvm_callback_fn_t mdah_callback_fn, void *mdah_callback_context);
+struct mda_header *raw_read_mda_header(const struct format_type *fmt,
+				       struct device_area *dev_area, int primary_mda);
 
 struct mda_lists {
 	struct dm_list dirs;
@@ -105,11 +103,9 @@ struct mda_context {
 #define LVM2_LABEL "LVM2 001"
 #define MDA_SIZE_MIN (8 * (unsigned) lvm_getpagesize())
 #define MDA_ORIGINAL_ALIGNMENT 512	/* Original alignment used for start of VG metadata content */
-#define MDA_ALIGNMENT 4096	/* Default alignment in bytes since 2.02.177 for start of VG metadata content. */
 
-int vgname_from_mda(const struct format_type *fmt, const struct mda_header *mdah, int primary_mda, 
+int vgname_from_mda(const struct format_type *fmt, struct mda_header *mdah, int primary_mda, 
 		    struct device_area *dev_area, struct lvmcache_vgsummary *vgsummary,
-		    uint64_t *mda_free_sectors, unsigned ioflags,
-		    lvm_callback_fn_t update_vgsummary_callback_fn, void *update_vgsummary_callback_context);
+		    uint64_t *mda_free_sectors);
 
 #endif
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 45136e9..7058f70 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -19,7 +19,6 @@
 #include "label.h"
 #include "xlate.h"
 #include "lvmcache.h"
-#include "toolcontext.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -36,14 +35,14 @@ static int _text_can_handle(struct labeller *l __attribute__((unused)),
 	return 0;
 }
 
-struct dl_setup_baton {
+struct _dl_setup_baton {
 	struct disk_locn *pvh_dlocn_xl;
 	struct device *dev;
 };
 
 static int _da_setup(struct disk_locn *da, void *baton)
 {
-	struct dl_setup_baton *p = baton;
+	struct _dl_setup_baton *p = baton;
 	p->pvh_dlocn_xl->offset = xlate64(da->offset);
 	p->pvh_dlocn_xl->size = xlate64(da->size);
 	p->pvh_dlocn_xl++;
@@ -57,7 +56,7 @@ static int _ba_setup(struct disk_locn *ba, void *baton)
 
 static int _mda_setup(struct metadata_area *mda, void *baton)
 {
-	struct dl_setup_baton *p = baton;
+	struct _dl_setup_baton *p = baton;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
 
 	if (mdac->area.dev != p->dev)
@@ -72,7 +71,7 @@ static int _mda_setup(struct metadata_area *mda, void *baton)
 
 static int _dl_null_termination(void *baton)
 {
-	struct dl_setup_baton *p = baton;
+	struct _dl_setup_baton *p = baton;
 
 	p->pvh_dlocn_xl->offset = xlate64(UINT64_C(0));
 	p->pvh_dlocn_xl->size = xlate64(UINT64_C(0));
@@ -87,7 +86,7 @@ static int _text_write(struct label *label, void *buf)
 	struct pv_header *pvhdr;
 	struct pv_header_extension *pvhdr_ext;
 	struct lvmcache_info *info;
-	struct dl_setup_baton baton;
+	struct _dl_setup_baton baton;
 	char buffer[64] __attribute__((aligned(8)));
 	int ba1, da1, mda1, mda2;
 
@@ -319,106 +318,18 @@ static int _text_initialise_label(struct labeller *l __attribute__((unused)),
 	return 1;
 }
 
-struct update_mda_baton {
+struct _update_mda_baton {
 	struct lvmcache_info *info;
 	struct label *label;
-	int nr_outstanding_mdas;
-	unsigned ioflags;
-	lvm_callback_fn_t read_label_callback_fn;
-	void *read_label_callback_context;
-	int ret;
 };
 
-struct process_mda_header_params {
-	struct update_mda_baton *umb;
-	struct metadata_area *mda;
-	struct device *dev;
-	struct lvmcache_vgsummary vgsummary;
-	int ret;
-};
-
-static void _process_vgsummary(int failed, unsigned ioflags, void *context, const void *data)
-{
-	struct process_mda_header_params *pmp = context;
-	const struct lvmcache_vgsummary *vgsummary = data;
-
-	--pmp->umb->nr_outstanding_mdas;
-
-	/* FIXME Need to distinguish genuine errors here */
-	if (failed)
-		goto_out;
-
-	if (!lvmcache_update_vgname_and_id(pmp->umb->info, vgsummary)) {
-		pmp->umb->ret = 0;
-		pmp->ret = 0;
-	}
-
-out:
-	if (!pmp->umb->nr_outstanding_mdas && pmp->umb->ret)
-		lvmcache_make_valid(pmp->umb->info);
-
-	if (!dev_close(pmp->dev))
-		stack;
-
-	if (!pmp->umb->nr_outstanding_mdas && pmp->umb->read_label_callback_fn)
-		pmp->umb->read_label_callback_fn(!pmp->umb->ret, ioflags, pmp->umb->read_label_callback_context, pmp->umb->label);
-}
-
-static void _process_mda_header(int failed, unsigned ioflags, void *context, const void *data)
-{
-	struct process_mda_header_params *pmp = context;
-	const struct mda_header *mdah = data;
-	struct update_mda_baton *umb = pmp->umb;
-	const struct format_type *fmt = umb->label->labeller->fmt;
-	struct metadata_area *mda = pmp->mda;
-	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
-
-	if (failed)
-		goto_bad;
-
-	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
-
-	if (mda_is_ignored(mda)) {
-		log_debug_metadata("Ignoring mda on device %s at offset " FMTu64,
-				   dev_name(mdac->area.dev),
-				   mdac->area.start);
-		goto bad;
-	}
-
-	if (!vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &pmp->vgsummary, &mdac->free_sectors, ioflags, _process_vgsummary, pmp)) {
-		/* FIXME Separate fatal and non-fatal error cases? */
-		goto_bad;
-	}
-
-	return;
-
-bad:
-	_process_vgsummary(1, ioflags, pmp, NULL);
-	return;
-}
-
-static int _count_mda(struct metadata_area *mda, void *baton)
-{
-	struct update_mda_baton *umb = baton;
-
-	umb->nr_outstanding_mdas++;
-
-	return 1;
-}
-
 static int _update_mda(struct metadata_area *mda, void *baton)
 {
-	struct process_mda_header_params *pmp;
-	struct update_mda_baton *umb = baton;
-	const struct format_type *fmt = umb->label->labeller->fmt;
-	struct dm_pool *mem = umb->label->labeller->fmt->cmd->mem;
+	struct _update_mda_baton *p = baton;
+	const struct format_type *fmt = p->label->labeller->fmt;
 	struct mda_context *mdac = (struct mda_context *) mda->metadata_locn;
-	unsigned ioflags = umb->ioflags;
-
-	if (!(pmp = dm_pool_zalloc(mem, sizeof(*pmp)))) {
-		log_error("struct process_mda_header_params allocation failed");
-		return 0;
-	}
+	struct mda_header *mdah;
+	struct lvmcache_vgsummary vgsummary = { 0 };
 
 	/*
 	 * Using the labeller struct to preserve info about
@@ -427,34 +338,45 @@ static int _update_mda(struct metadata_area *mda, void *baton)
 	 * TODO: make lvmcache smarter and move this cache logic there
 	 */
 
-	pmp->dev = mdac->area.dev;
-	pmp->umb = umb;
-	pmp->mda = mda;
-
 	if (!dev_open_readonly(mdac->area.dev)) {
 		mda_set_ignored(mda, 1);
 		stack;
-		if (!--umb->nr_outstanding_mdas && umb->read_label_callback_fn)
-			umb->read_label_callback_fn(!umb->ret, ioflags, umb->read_label_callback_context, umb->label);
 		return 1;
 	}
 
-	pmp->ret = 1;
-
-	if (!raw_read_mda_header_callback(fmt->cmd->mem, &mdac->area, mda_is_primary(mda), ioflags, _process_mda_header, pmp)) {
-		_process_vgsummary(1, ioflags, pmp, NULL);
+	if (!(mdah = raw_read_mda_header(fmt, &mdac->area, mda_is_primary(mda)))) {
 		stack;
-		return 1;
+		goto close_dev;
 	}
 
-	if (umb->read_label_callback_fn)
+	mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
+
+	if (mda_is_ignored(mda)) {
+		log_debug_metadata("Ignoring mda on device %s at offset " FMTu64,
+				   dev_name(mdac->area.dev),
+				   mdac->area.start);
+		if (!dev_close(mdac->area.dev))
+			stack;
 		return 1;
-	else
-		return pmp->ret;
+	}
+
+	if (vgname_from_mda(fmt, mdah, mda_is_primary(mda), &mdac->area, &vgsummary,
+			     &mdac->free_sectors) &&
+	    !lvmcache_update_vgname_and_id(p->info, &vgsummary)) {
+		if (!dev_close(mdac->area.dev))
+			stack;
+		return_0;
+	}
+
+close_dev:
+	if (!dev_close(mdac->area.dev))
+		stack;
+
+	return 1;
 }
 
-static int _text_read(struct labeller *l, struct device *dev, void *buf, unsigned ioflags,
-		      lvm_callback_fn_t read_label_callback_fn, void *read_label_callback_context)
+static int _text_read(struct labeller *l, struct device *dev, void *buf,
+		 struct label **label)
 {
 	struct label_header *lh = (struct label_header *) buf;
 	struct pv_header *pvhdr;
@@ -463,9 +385,7 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf, unsigne
 	struct disk_locn *dlocn_xl;
 	uint64_t offset;
 	uint32_t ext_version;
-	struct dm_pool *mem = l->fmt->cmd->mem;
-	struct update_mda_baton *umb;
-	struct label *label;
+	struct _update_mda_baton baton;
 
 	/*
 	 * PV header base
@@ -475,9 +395,9 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf, unsigne
 	if (!(info = lvmcache_add(l, (char *)pvhdr->pv_uuid, dev,
 				  FMT_TEXT_ORPHAN_VG_NAME,
 				  FMT_TEXT_ORPHAN_VG_NAME, 0)))
-		goto_bad;
+		return_0;
 
-	label = lvmcache_get_label(info);
+	*label = lvmcache_get_label(info);
 
 	lvmcache_set_device_size(info, xlate64(pvhdr->device_size_xl));
 
@@ -523,41 +443,16 @@ static int _text_read(struct labeller *l, struct device *dev, void *buf, unsigne
 		lvmcache_add_ba(info, offset, xlate64(dlocn_xl->size));
 		dlocn_xl++;
 	}
-
 out:
-	if (!(umb = dm_pool_zalloc(mem, sizeof(*umb)))) {
-		log_error("baton allocation failed");
-		goto_bad;
-	}
+	baton.info = info;
+	baton.label = *label;
 
-	umb->info = info;
-	umb->label = label;
-	umb->ioflags = ioflags;
-	umb->read_label_callback_fn = read_label_callback_fn;
-	umb->read_label_callback_context = read_label_callback_context;
+	if (!lvmcache_foreach_mda(info, _update_mda, &baton))
+		return_0;
 
-	umb->ret = 1;
-
-	if (!lvmcache_foreach_mda(info, _count_mda, umb))
-		goto_bad;
-
-	if (!umb->nr_outstanding_mdas) {
-		lvmcache_make_valid(info);
-		if (read_label_callback_fn)
-			read_label_callback_fn(0, ioflags, read_label_callback_context, label);
-		return 1;
-	}
-
-	if (!lvmcache_foreach_mda(info, _update_mda, umb))
-		goto_bad;
+	lvmcache_make_valid(info);
 
 	return 1;
-
-bad:
-	if (read_label_callback_fn)
-		read_label_callback_fn(1, ioflags, read_label_callback_context, NULL);
-
-	return 0;
 }
 
 static void _text_destroy_label(struct labeller *l __attribute__((unused)),
diff --git a/lib/label/label.c b/lib/label/label.c
index 32fad82..46dd667 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -25,8 +25,6 @@
 
 /* FIXME Allow for larger labels?  Restricted to single sector currently */
 
-static struct dm_pool *_labeller_mem;
-
 /*
  * Internal labeller struct.
  */
@@ -59,13 +57,7 @@ static struct labeller_i *_alloc_li(const char *name, struct labeller *l)
 
 int label_init(void)
 {
-	if (!(_labeller_mem = dm_pool_create("label scan", 128))) {
-		log_error("Labeller pool creation failed.");
-		return 0;
-	}
-
 	dm_list_init(&_labellers);
-
 	return 1;
 }
 
@@ -80,8 +72,6 @@ void label_exit(void)
 	}
 
 	dm_list_init(&_labellers);
-
-	dm_pool_destroy(_labeller_mem);
 }
 
 int label_register_handler(struct labeller *handler)
@@ -118,74 +108,32 @@ static void _update_lvmcache_orphan(struct lvmcache_info *info)
 		stack;
 }
 
-struct find_labeller_params {
-	struct device *dev;
-	uint64_t scan_sector;	/* Sector to be scanned */
-	uint64_t label_sector;	/* Sector where label found */
-	lvm_callback_fn_t process_label_data_fn;
-	void *process_label_data_context;
-
-	struct label **result;
-
-	int ret;
-};
-
-static void _set_label_read_result(int failed, unsigned ioflags, void *context, const void *data)
+static struct labeller *_find_labeller(struct device *dev, char *buf,
+				       uint64_t *label_sector,
+				       uint64_t scan_sector)
 {
-	struct find_labeller_params *flp = context;
-	struct label **result = flp->result;
-	struct label *label = (struct label *) data;
-
-	if (failed) {
-		flp->ret = 0;
-		goto_out;
-	}
-
-	/* Fix up device and label sector which the low-level code doesn't set */
-	if (label) {
-		label->dev = flp->dev;
-		label->sector = flp->label_sector;
-	}
-
-	if (result)
-		*result = (struct label *) label;
-
-out:
-	if (!dev_close(flp->dev))
-		stack;
-
-	if (flp->process_label_data_fn) {
-		log_debug_io("Completed label reading for %s", dev_name(flp->dev));
-		flp->process_label_data_fn(!flp->ret, ioflags, flp->process_label_data_context, NULL);
-	}
-}
-
-static void _find_labeller(int failed, unsigned ioflags, void *context, const void *data)
-{
-	struct find_labeller_params *flp = context;
-	const char *readbuf = data;
-	struct device *dev = flp->dev;
-	uint64_t scan_sector = flp->scan_sector;
-	char labelbuf[LABEL_SIZE] __attribute__((aligned(8)));
 	struct labeller_i *li;
-	struct labeller *l = NULL;	/* Set when a labeller claims the label */
-	const struct label_header *lh;
+	struct labeller *r = NULL;
+	struct label_header *lh;
 	struct lvmcache_info *info;
 	uint64_t sector;
+	int found = 0;
+	char readbuf[LABEL_SCAN_SIZE] __attribute__((aligned(8)));
 
-	if (failed) {
+	if (!dev_read(dev, scan_sector << SECTOR_SHIFT,
+		      LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
-		_set_label_read_result(1, ioflags, flp, NULL);
-		return;
+		goto out;
 	}
 
 	/* Scan a few sectors for a valid label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
-		lh = (struct label_header *) (readbuf + (sector << SECTOR_SHIFT));
+		lh = (struct label_header *) (readbuf +
+					      (sector << SECTOR_SHIFT));
 
 		if (!strncmp((char *)lh->id, LABEL_ID, sizeof(lh->id))) {
-			if (l) {
+			if (found) {
 				log_error("Ignoring additional label on %s at "
 					  "sector %" PRIu64, dev_name(dev),
 					  sector + scan_sector);
@@ -205,7 +153,7 @@ static void _find_labeller(int failed, unsigned ioflags, void *context, const vo
 						 "ignoring", dev_name(dev));
 				continue;
 			}
-			if (l)
+			if (found)
 				continue;
 		}
 
@@ -216,44 +164,46 @@ static void _find_labeller(int failed, unsigned ioflags, void *context, const vo
 					         "sector %" PRIu64, 
 						 dev_name(dev), li->name,
 						 sector + scan_sector);
-				if (l) {
+				if (found) {
 					log_error("Ignoring additional label "
 						  "on %s at sector %" PRIu64,
 						  dev_name(dev),
 						  sector + scan_sector);
 					continue;
 				}
-				memcpy(labelbuf, lh, LABEL_SIZE);
-				flp->label_sector = sector + scan_sector;
-				l = li->l;
+				r = li->l;
+				memcpy(buf, lh, LABEL_SIZE);
+				if (label_sector)
+					*label_sector = sector + scan_sector;
+				found = 1;
 				break;
 			}
 		}
 	}
 
-	if (!l) {
+      out:
+	if (!found) {
 		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);
 		log_very_verbose("%s: No label detected", dev_name(dev));
-		flp->ret = 0;
-		_set_label_read_result(1, ioflags, flp, NULL);
-	} else
-		(void) (l->ops->read)(l, dev, labelbuf, ioflags, &_set_label_read_result, flp);
+	}
+
+	return r;
 }
 
 /* FIXME Also wipe associated metadata area headers? */
 int label_remove(struct device *dev)
 {
-	char labelbuf[LABEL_SIZE] __attribute__((aligned(8)));
+	char buf[LABEL_SIZE] __attribute__((aligned(8)));
+	char readbuf[LABEL_SCAN_SIZE] __attribute__((aligned(8)));
 	int r = 1;
 	uint64_t sector;
 	int wipe;
 	struct labeller_i *li;
 	struct label_header *lh;
 	struct lvmcache_info *info;
-	const char *readbuf = NULL;
 
-	memset(labelbuf, 0, LABEL_SIZE);
+	memset(buf, 0, LABEL_SIZE);
 
 	log_very_verbose("Scanning for labels to wipe from %s", dev_name(dev));
 
@@ -266,7 +216,7 @@ int label_remove(struct device *dev)
 	 */
 	dev_flush(dev);
 
-	if (!(readbuf = dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL))) {
+	if (!dev_read(dev, UINT64_C(0), LABEL_SCAN_SIZE, DEV_IO_LABEL, readbuf)) {
 		log_debug_devs("%s: Failed to read label area", dev_name(dev));
 		goto out;
 	}
@@ -274,7 +224,8 @@ int label_remove(struct device *dev)
 	/* Scan first few sectors for anything looking like a label */
 	for (sector = 0; sector < LABEL_SCAN_SECTORS;
 	     sector += LABEL_SIZE >> SECTOR_SHIFT) {
-		lh = (struct label_header *) (readbuf + (sector << SECTOR_SHIFT));
+		lh = (struct label_header *) (readbuf +
+					      (sector << SECTOR_SHIFT));
 
 		wipe = 0;
 
@@ -294,7 +245,8 @@ int label_remove(struct device *dev)
 		if (wipe) {
 			log_very_verbose("%s: Wiping label@sector %" PRIu64,
 					 dev_name(dev), sector);
-			if (dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE, DEV_IO_LABEL, labelbuf)) {
+			if (dev_write(dev, sector << SECTOR_SHIFT, LABEL_SIZE, DEV_IO_LABEL,
+				       buf)) {
 				/* Also remove the PV record from cache. */
 				info = lvmcache_info_from_pvid(dev->pvid, dev, 0);
 				if (info)
@@ -315,39 +267,21 @@ int label_remove(struct device *dev)
 	return r;
 }
 
-static int _label_read(struct device *dev, uint64_t scan_sector, struct label **result,
-		       unsigned ioflags, lvm_callback_fn_t process_label_data_fn, void *process_label_data_context)
+int label_read(struct device *dev, struct label **result,
+		uint64_t scan_sector)
 {
+	char buf[LABEL_SIZE] __attribute__((aligned(8)));
+	struct labeller *l;
+	uint64_t sector;
 	struct lvmcache_info *info;
-	struct find_labeller_params *flp;
+	int r = 0;
 
 	if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 1))) {
 		log_debug_devs("Reading label from lvmcache for %s", dev_name(dev));
-		if (result)
-			*result = lvmcache_get_label(info);
-		if (process_label_data_fn) {
-			log_debug_io("Completed label reading for %s", dev_name(dev));
-			process_label_data_fn(0, ioflags, process_label_data_context, NULL);
-		}
+		*result = lvmcache_get_label(info);
 		return 1;
 	}
 
-	if (!(flp = dm_pool_zalloc(_labeller_mem, sizeof *flp))) {
-		log_error("find_labeller_params allocation failed.");
-		return 0;
-	}
-
-	flp->dev = dev;
-	flp->scan_sector = scan_sector;
-	flp->result = result;
-	flp->process_label_data_fn = process_label_data_fn;
-	flp->process_label_data_context = process_label_data_context;
-	flp->ret = 1;
-
-	/* Ensure result is always wiped as a precaution */
-	if (result)
-		*result = NULL;
-
 	log_debug_devs("Reading label from device %s", dev_name(dev));
 
 	if (!dev_open_readonly(dev)) {
@@ -356,26 +290,19 @@ static int _label_read(struct device *dev, uint64_t scan_sector, struct label **
 		if ((info = lvmcache_info_from_pvid(dev->pvid, dev, 0)))
 			_update_lvmcache_orphan(info);
 
-		return 0;
+		return r;
 	}
 
-	dev_read_callback(dev, scan_sector << SECTOR_SHIFT, LABEL_SCAN_SIZE, DEV_IO_LABEL, ioflags, _find_labeller, flp);
-	if (process_label_data_fn)
-		return 1;
-	else
-		return flp->ret;
-}
+	if ((l = _find_labeller(dev, buf, &sector, scan_sector)))
+		if ((r = (l->ops->read)(l, dev, buf, result)) && result && *result) {
+			(*result)->dev = dev;
+			(*result)->sector = sector;
+		}
 
-/* result may be NULL if caller doesn't need it */
-int label_read(struct device *dev, struct label **result, uint64_t scan_sector)
-{
-	return _label_read(dev, scan_sector, result, 0, NULL, NULL);
-}
+	if (!dev_close(dev))
+		stack;
 
-int label_read_callback(struct device *dev, uint64_t scan_sector, unsigned ioflags,
-		       lvm_callback_fn_t process_label_data_fn, void *process_label_data_context)
-{
-	return _label_read(dev, scan_sector, NULL, ioflags, process_label_data_fn, process_label_data_context);
+	return r;
 }
 
 /* Caller may need to use label_get_handler to create label struct! */
diff --git a/lib/label/label.h b/lib/label/label.h
index 6d31eb0..ea11290 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -62,8 +62,8 @@ struct label_ops {
 	/*
 	 * Read a label from a volume.
 	 */
-	int (*read) (struct labeller *l, struct device *dev, void *buf,
-		     unsigned ioflags, lvm_callback_fn_t label_read_callback_fn, void *label_read_callback_context);
+	int (*read) (struct labeller * l, struct device * dev,
+		     void *buf, struct label ** label);
 
 	/*
 	 * Populate label_type etc.
@@ -96,8 +96,6 @@ struct labeller *label_get_handler(const char *name);
 int label_remove(struct device *dev);
 int label_read(struct device *dev, struct label **result,
 		uint64_t scan_sector);
-int label_read_callback(struct device *dev, uint64_t scan_sector,
-			unsigned ioflags, lvm_callback_fn_t process_label_data_fn, void *process_label_data_context);
 int label_write(struct device *dev, struct label *label);
 struct label *label_create(struct labeller *labeller);
 void label_destroy(struct label *label);
diff --git a/lib/metadata/metadata-liblvm.c b/lib/metadata/metadata-liblvm.c
index d192b15..a4284bc 100644
--- a/lib/metadata/metadata-liblvm.c
+++ b/lib/metadata/metadata-liblvm.c
@@ -491,6 +491,7 @@ static int _pvremove_check(struct cmd_context *cmd, const char *name,
 {
 	static const char really_wipe_msg[] = "Really WIPE LABELS from physical volume";
 	struct device *dev;
+	struct label *label;
 	struct pv_list *pvl;
 	struct physical_volume *pv = NULL;
 	int used;
@@ -505,7 +506,7 @@ static int _pvremove_check(struct cmd_context *cmd, const char *name,
 
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
-	if (!label_read(dev, NULL, 0)) {
+	if (!label_read(dev, &label, 0)) {
 		if (force_count)
 			return 1;
 		log_error("No PV label found on %s.", name);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b5b97c2..2249d2f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3912,9 +3912,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		use_previous_vg = 0;
 
 		if ((use_precommitted &&
-		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg) ||
+		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg) ||
 		    (!use_precommitted &&
-		     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0, 0)) && !use_previous_vg)) {
+		     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg)) {
 			inconsistent = 1;
 			vg_fmtdata = NULL;
 			continue;
@@ -4104,9 +4104,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			use_previous_vg = 0;
 
 			if ((use_precommitted &&
-			     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg) ||
+			     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda, &vg_fmtdata, &use_previous_vg)) && !use_previous_vg) ||
 			    (!use_precommitted &&
-			     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0, 0)) && !use_previous_vg)) {
+			     !(vg = mda->ops->vg_read(fid, vgname, mda, &vg_fmtdata, &use_previous_vg, 0)) && !use_previous_vg)) {
 				inconsistent = 1;
 				vg_fmtdata = NULL;
 				continue;
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index f6b19f4..1fa14e8 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -48,6 +48,7 @@
  */
 #define dm_round_up(n, sz) (dm_div_up((n), (sz)) * (sz))
 
+
 /* Various flags */
 /* See metadata-exported.h for the complete list. */
 /* Note that the bits no longer necessarily correspond to LVM1 disk format */
@@ -80,12 +81,12 @@ struct metadata_area_ops {
 					 struct metadata_area * mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
 					 unsigned *use_previous_vg,
-					 int single_device, unsigned ioflags);
+					 int single_device);
 	struct volume_group *(*vg_read_precommit) (struct format_instance * fi,
 					 const char *vg_name,
 					 struct metadata_area * mda,
 					 struct cached_vg_fmtdata **vg_fmtdata,
-					 unsigned *use_previous_vg, unsigned ioflags);
+					 unsigned *use_previous_vg);
 	/*
 	 * Write out complete VG metadata.  You must ensure internal
 	 * consistency before calling. eg. PEs can't refer to PVs not
diff --git a/make.tmpl.in b/make.tmpl.in
index 414b1dd..bdf2349 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -62,8 +62,7 @@ CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS) $(AIO_LIBS)
-AIO_LIBS = @AIO_LIBS@
+LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
diff --git a/tools/command.c b/tools/command.c
index a40b327..8944399 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1357,11 +1357,13 @@ static void _create_opt_names_alpha(void)
 	qsort(opt_names_alpha, ARG_COUNT, sizeof(long), _long_name_compare);
 }
 
-static int _copy_line(char *line, int max_line, int *position, int *len)
+static int _copy_line(char *line, int max_line, int *position)
 {
 	int p = *position;
 	int i = 0;
 
+	memset(line, 0, max_line);
+
 	while (1) {
 		line[i] = _command_input[p];
 		i++;
@@ -1375,9 +1377,7 @@ static int _copy_line(char *line, int max_line, int *position, int *len)
 		if (i == (max_line - 1))
 			break;
 	}
-	line[i] = '\0';
 	*position = p;
-	*len = i + 1;
 	return 1;
 }
 
@@ -1395,7 +1395,6 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 	int prev_was_oo = 0;
 	int prev_was_op = 0;
 	int copy_pos = 0;
-	int copy_len = 0;
 	int skip = 0;
 	int i;
 
@@ -1406,14 +1405,14 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
 
 	/* Process each line of command-lines-input.h (from command-lines.in) */
 
-	while (_copy_line(line, MAX_LINE, &copy_pos, &copy_len)) {
+	while (_copy_line(line, MAX_LINE, &copy_pos)) {
 		if (line[0] == '\n')
 			break;
 
 		if ((n = strchr(line, '\n')))
 			*n = '\0';
 
-		memcpy(line_orig, line, copy_len);
+		memcpy(line_orig, line, sizeof(line));
 		_split_line(line, &line_argc, line_argv, ' ');
 
 		if (!line_argc)
diff --git a/tools/toollib.c b/tools/toollib.c
index 3f27a7a..451f24d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -116,7 +116,6 @@ int become_daemon(struct cmd_context *cmd, int skip_lvm)
 			/* FIXME Clean up properly here */
 			_exit(ECMD_FAILED);
 	}
-	dev_async_reset(cmd);
 	dev_close_all();
 
 	return 1;


