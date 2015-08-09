From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun,  9 Aug 2015 13:43:17 +0000 (UTC)
Subject: master - dmstats: add libdm-stats library and 'dmsetup stats' command
Message-ID: <20150809134317.4C6F160B28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d62a8d2f1535468c75379b877844bdb7666c8c9e
Commit:        d62a8d2f1535468c75379b877844bdb7666c8c9e
Parent:        f06d866110938458ed736f927e859534c99c295e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Aug 5 10:40:00 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Aug 9 14:37:58 2015 +0100

dmstats: add libdm-stats library and 'dmsetup stats' command

Add the libdm-stats module to libdm: this implements a simple interface
for creating, managing and interrogating I/O statistics regions and
areas on device-mapper devices.

The library interface is documented in libdevmapper.h and provides a
'dm_stats' handle that is used to perform statistics operations and
obtain data.

Public methods are provided to create and destroy handles and to list,
create, and destroy statistics regions as well as to obtain and parse
counter data and calculate rate-based metrics.

This commit also adds a 'dmsetup stats' (aka 'dmstats') command with
'clear', 'create', 'delete', 'list', 'print', and 'report' sub-commands.

See the library documentation and the dmstats.8 manual page for detailed
API and command descriptions.
---
 WHATS_NEW_DM                        |   14 +
 libdm/.exported_symbols.DM_1_02_104 |   68 ++
 libdm/Makefile.in                   |    1 +
 libdm/libdevmapper.h                |  643 +++++++++++
 libdm/libdm-stats.c                 | 1360 +++++++++++++++++++++++
 man/Makefile.in                     |    2 +-
 man/dmstats.8.in                    |  693 ++++++++++++
 tools/dmsetup.c                     | 2062 ++++++++++++++++++++++++++++++-----
 8 files changed, 4597 insertions(+), 246 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 598a354..1753322 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,19 @@
 Version 1.02.104 -
 =================================
+  Add dmstats.8 man page
+  Add report stats sub-command to provide repeating stats reports.
+  Add clear, delete, list, and print stats sub-commands.
+  Add --segments switch to create one region per device segment.
+  Add create stats sub-command and --start, --length, --areas and --areasize.
+  Recognize 'dmstats' as an alias for 'dmsetup stats' when run with this name.
+  Add a 'stats' command to dmsetup to configure, manage and report stats data.
+  Add --regionid, --allregions to specify a single stats region or all regions.
+  Add --allprograms for stats commands that filter by program ID.
+  Add --auxdata and --programid arguments to specify aux data and program ID.
+  Add statistics fields to -o <field>
+  Add libdm-stats library to allow management of device-mapper statistics.
+  Add --nosuffix to suppress unit suffixes in report output.
+  Add --units to control report field output units.
   Add support to redisplay column headings for repeating column reports.
   Fix report header and row resource leaks.
   Report timestamps of ioctls with dmsetup -vvv.
diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index ba290e8..712fcf2 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -1,5 +1,73 @@
 dm_report_column_headings
 dm_size_to_string
+dm_stats_bind_devno
+dm_stats_bind_name
+dm_stats_bind_uuid
+dm_stats_buffer_destroy
+dm_stats_clear_region
+dm_stats_create
+dm_stats_create_region
+dm_stats_delete_region
+dm_stats_destroy
+dm_stats_get_area_start
+dm_stats_get_average_queue_size
+dm_stats_get_average_rd_wait_time
+dm_stats_get_average_request_size
+dm_stats_get_average_wait_time
+dm_stats_get_average_wr_wait_time
+dm_stats_get_current_area
+dm_stats_get_current_area_len
+dm_stats_get_current_area_start
+dm_stats_get_current_nr_areas
+dm_stats_get_current_region
+dm_stats_get_current_region_area_len
+dm_stats_get_current_region_aux_data
+dm_stats_get_current_region_len
+dm_stats_get_current_region_program_id
+dm_stats_get_current_region_start
+dm_stats_get_io_in_progress
+dm_stats_get_io_nsecs
+dm_stats_get_nr_areas
+dm_stats_get_nr_regions
+dm_stats_get_rd_merges_per_sec
+dm_stats_get_read_nsecs
+dm_stats_get_reads
+dm_stats_get_read_sectors
+dm_stats_get_read_sectors_per_sec
+dm_stats_get_reads_merged
+dm_stats_get_reads_per_sec
+dm_stats_get_region_area_len
+dm_stats_get_region_aux_data
+dm_stats_get_region_len
+dm_stats_get_region_nr_areas
+dm_stats_get_region_program_id
+dm_stats_get_region_start
+dm_stats_get_sampling_interval_ms
+dm_stats_get_sampling_interval_ns
+dm_stats_get_service_time
+dm_stats_get_throughput
+dm_stats_get_total_read_nsecs
+dm_stats_get_total_write_nsecs
+dm_stats_get_utilization
+dm_stats_get_weighted_io_nsecs
+dm_stats_get_write_nsecs
+dm_stats_get_writes
+dm_stats_get_write_sectors
+dm_stats_get_write_sectors_per_sec
+dm_stats_get_writes_merged
+dm_stats_get_writes_per_sec
+dm_stats_get_wr_merges_per_sec
+dm_stats_list
+dm_stats_populate
+dm_stats_print_region
+dm_stats_region_present
+dm_stats_set_program_id
+dm_stats_set_sampling_interval_ms
+dm_stats_set_sampling_interval_ns
+dm_stats_walk_end
+dm_stats_walk_next
+dm_stats_walk_next_region
+dm_stats_walk_start
 dm_task_get_ioctl_timestamp
 dm_task_set_record_timestamp
 dm_timestamp_alloc
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 73f6f40..880b40c 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -26,6 +26,7 @@ SOURCES =\
 	libdm-string.c \
 	libdm-report.c \
 	libdm-timestamp.c \
+	libdm-stats.c \
 	libdm-config.c \
 	mm/dbg_malloc.c \
 	mm/pool.c \
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 895fbe6..1be8e4f 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -396,6 +396,502 @@ int dm_get_status_thin(struct dm_pool *mem, const char *params,
 		       struct dm_status_thin **status);
 
 /*
+ * device-mapper statistics support
+ */
+
+/*
+ * Statistics handle.
+ *
+ * Operations on dm_stats objects include managing statistics regions
+ * and obtaining and manipulating current counter values from the
+ * kernel. Methods are provided to return baisc count values and to
+ * derive time-based metrics when a suitable interval estimate is
+ * provided.
+ *
+ * Internally the dm_stats handle contains a pointer to a table of one
+ * or more dm_stats_region objects representing the regions registered
+ * with the dm_stats_create_region() method. These in turn point to a
+ * table of one or more dm_stats_counters objects containing the
+ * counter sets for each defined area within the region:
+ *
+ * dm_stats->dm_stats_region[nr_regions]->dm_stats_counters[nr_areas]
+ *
+ * This structure is private to the library and may change in future
+ * versions: all users should make use of the public interface and treat
+ * the dm_stats type as an opaque handle.
+ *
+ * Regions and counter sets are stored in order of increasing region_id.
+ * Depending on region specifications and the sequence of create and
+ * delete operations this may not correspond to increasing sector
+ * number: users of the library should not assume that this is the case
+ * unless region creation is deliberately managed to ensure this (by
+ * always creating regions in strict order of ascending sector address).
+ *
+ * Regions may also overlap so the same sector range may be included in
+ * more than one region or area: applications should be prepared to deal
+ * with this or manage regions such that it does not occur.
+ */
+struct dm_stats;
+
+/*
+ * Allocate a dm_stats handle to use for subsequent device-mapper
+ * statistics operations. A program_id may be specified and will be
+ * used by default for subsequent operations on this handle.
+ *
+ * If program_id is NULL or the empty string a program_id will be
+ * automatically set to the value contained in /proc/self/comm.
+ */
+struct dm_stats *dm_stats_create(const char *program_id);
+
+/*
+ * Bind a dm_stats handle to the specified device major and minor
+ * values. Any previous binding is cleared and any preexisting counter
+ * data contained in the handle is released.
+ */
+int dm_stats_bind_devno(struct dm_stats *dms, int major, int minor);
+
+/*
+ * Bind a dm_stats handle to the specified device name.
+ * Any previous binding is cleared and any preexisting counter
+ * data contained in the handle is released.
+ */
+int dm_stats_bind_name(struct dm_stats *dms, const char *name);
+
+/*
+ * Bind a dm_stats handle to the specified device UUID.
+ * Any previous binding is cleared and any preexisting counter
+ * data contained in the handle is released.
+ */
+int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid);
+
+#define DM_STATS_ALL_PROGRAMS ""
+/*
+ * Parse the response from a @stats_list message. dm_stats_list will
+ * allocate the necessary dm_stats and dm_stats region structures from
+ * the embedded dm_pool. No counter data will be obtained (the counters
+ * members of dm_stats_region objects are set to NULL).
+ *
+ * A program_id may optionally be supplied; if the argument is non-NULL
+ * only regions with a matching program_id value will be considered. If
+ * the argument is NULL then the default program_id associated with the
+ * dm_stats handle will be used. Passing the special value
+ * DM_STATS_ALL_PROGRAMS will cause all regions to be queried
+ * regardless of region program_id.
+ */
+int dm_stats_list(struct dm_stats *dms, const char *program_id);
+
+#define DM_STATS_REGIONS_ALL UINT64_MAX
+/*
+ * Populate a dm_stats object with statistics for one or more regions of
+ * the specified device.
+ *
+ * A program_id may optionally be supplied; if the argument is non-NULL
+ * only regions with a matching program_id value will be considered. If
+ * the argument is NULL then the default program_id associated with the
+ * dm_stats handle will be used. Passing the special value
+ * DM_STATS_ALL_PROGRAMS will cause all regions to be queried
+ * regardless of region program_id.
+ *
+ * Passing the special value DM_STATS_REGIONS_ALL as the region_id
+ * argument will attempt to retrieve all regions selected by the
+ * program_id argument.
+ *
+ * If region_id is used to request a single region_id to be populated
+ * the program_id is ignored.
+ */
+int dm_stats_populate(struct dm_stats *dms, const char *program_id,
+		      uint64_t region_id);
+
+/*
+ * Create a new statistics region on the device bound to dms.
+ *
+ * start and len specify the region start and length in 512b sectors.
+ * Passing zero for both start and len will create a region spanning
+ * the entire device.
+ *
+ * Step determines how to subdivide the region into discrete counter
+ * sets: a positive value specifies the size of areas into which the
+ * region should be split while a negative value will split the region
+ * into a number of areas equal to the absolute value of step:
+ *
+ * - a region with one area spanning the entire device:
+ *
+ *   dm_stats_create_region(dms, 0, 0, -1, p, a);
+ *
+ * - a region with areas of 1MiB:
+ *
+ *   dm_stats_create_region(dms, 0, 0, 1 << 11, p, a);
+ *
+ * - one 1MiB region starting at 1024 sectors with two areas:
+ *
+ *   dm_stats_create_region(dms, 1024, 1 << 11, -2, p, a);
+ *
+ * program_id is an optional string argument that identifies the
+ * program creating the region. If program_id is NULL or the empty
+ * string the default program_id stored in the handle will be used.
+ *
+ * aux_data is an optional string argument passed to the kernel that is
+ * stored with the statistics region. It is not currently accessed by
+ * the library or kernel and may be used to store arbitrary user data.
+ *
+ * The region_id of the newly-created region is returned in *region_id
+ * if it is non-NULL.
+ */
+int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
+			   uint64_t start, uint64_t len, int64_t step,
+			   const char *program_id, const char *aux_data);
+
+/*
+ * Delete the specified statistics region. This will also mark the
+ * region as not-present and discard any existing statistics data.
+ */
+int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id);
+
+/*
+ * Clear the specified statistics region. This requests the kernel to
+ * zero all counter values (except in-flight I/O). Note that this
+ * operation is not atomic with respect to reads of the counters; any IO
+ * events occurring between the last print operation and the clear will
+ * be lost. This can be avoided by using the atomic print-and-clear
+ * function of the dm_stats_print_region() call or by using the higher
+ * level dm_stats_populate() interface.
+ */
+int dm_stats_clear_region(struct dm_stats *dms, uint64_t region_id);
+
+/*
+ * Print the current counter values for the specified statistics region
+ * and return them as a string. The memory for the string buffer will
+ * be allocated from the dm_stats handle's private pool and should be
+ * returned by calling dm_stats_buffer_destroy() when no longer
+ * required. The pointer will become invalid following any call that
+ * clears or reinitializes the handle (destroy, list, populate, bind).
+ *
+ * This allows applications that wish to access the raw message response
+ * to obtain it via a dm_stats handle; no parsing of the textual counter
+ * data is carried out by this function.
+ *
+ * Most users are recommended to use the dm_stats_populate() call
+ * instead since this will automatically parse the statistics data into
+ * numeric form accessible via the dm_stats_get_*() counter access
+ * methods.
+ *
+ * A subset of the data lines may be requested by setting the
+ * start_line and num_lines parameters. If both are zero all data
+ * lines are returned.
+ *
+ * If the clear parameter is non-zero the operation will also
+ * atomically reset all counter values to zero (except in-flight IO).
+ */
+char *dm_stats_print_region(struct dm_stats *dms, uint64_t region_id,
+			    unsigned start_line, unsigned num_lines,
+			    unsigned clear);
+
+/*
+ * Destroy a statistics response buffer obtained from a call to
+ * dm_stats_print_region().
+ */
+void dm_stats_buffer_destroy(struct dm_stats *dms, char *buffer);
+
+/*
+ * Determine the number of regions contained in a dm_stats handle
+ * following a dm_stats_list() or dm_stats_populate() call.
+ *
+ * The value returned is the number of registered regions visible with the
+ * progam_id value used for the list or populate operation and may not be
+ * equal to the highest present region_id (either due to program_id
+ * filtering or gaps in the sequence of region_id values).
+ *
+ * Always returns zero on an empty handle.
+ */
+uint64_t dm_stats_get_nr_regions(const struct dm_stats *dms);
+
+/*
+ * Test whether region_id is present in this dm_stats handle.
+ */
+int dm_stats_region_present(const struct dm_stats *dms, uint64_t region_id);
+
+/*
+ * Returns the number of areas (counter sets) contained in the specified
+ * region_id of the supplied dm_stats handle.
+ */
+uint64_t dm_stats_get_region_nr_areas(const struct dm_stats *dms,
+				      uint64_t region_id);
+
+/*
+ * Returns the total number of areas (counter sets) in all regions of the
+ * given dm_stats object.
+ */
+uint64_t dm_stats_get_nr_areas(const struct dm_stats *dms);
+
+/*
+ * Destroy a dm_stats object and all associated regions and counter
+ * sets.
+ */
+void dm_stats_destroy(struct dm_stats *dms);
+
+/*
+ * Counter sampling interval
+ */
+
+/*
+ * Set the sampling interval for counter data to the specified value in
+ * either nanoseconds or milliseconds.
+ *
+ * The interval is used to calculate time-based metrics from the basic
+ * counter data: an interval must be set before calling any of the
+ * metric methods.
+ *
+ * For best accuracy the duration should be measured and updated at the
+ * end of each interval.
+ *
+ * All values are stored internally with nanosecond precision and are
+ * converted to or from ms when the millisecond interfaces are used.
+ */
+void dm_stats_set_sampling_interval_ns(struct dm_stats *dms,
+				       uint64_t interval_ns);
+
+void dm_stats_set_sampling_interval_ms(struct dm_stats *dms,
+				       uint64_t interval_ms);
+
+/*
+ * Retrieve the configured sampling interval in either nanoseconds or
+ * milliseconds.
+ */
+uint64_t dm_stats_get_sampling_interval_ns(const struct dm_stats *dms);
+uint64_t dm_stats_get_sampling_interval_ms(const struct dm_stats *dms);
+
+/*
+ * Override program_id. This may be used to change the default
+ * program_id value for an existing handle. If the allow_empty argument
+ * is non-zero a NULL or empty program_id is permitted.
+ *
+ * Use with caution! Most users of the library should set a valid,
+ * non-NULL program_id for every statistics region created. Failing to
+ * do so may result in confusing state when multiple programs are
+ * creating and managing statistics regions.
+ *
+ * All users of the library are encouraged to choose an unambiguous,
+ * unique program_id: this could be based on PID (for programs that
+ * create, report, and delete regions in a single process), session id,
+ * executable name, or some other distinguishing string.
+ *
+ * Use of the empty string as a program_id does not simplify use of the
+ * library or the command line tools and use of this value is strongly
+ * discouraged.
+ */
+int dm_stats_set_program_id(struct dm_stats *dms, int allow_empty,
+			    const char *program_id);
+
+/*
+ * Region properties: size, length & area_len.
+ *
+ * Region start and length are returned in units of 512b as specified
+ * at region creation time. The area_len value gives the size of areas
+ * into which the region has been subdivided. For regions with a single
+ * area spanning the range this value is equal to the region length.
+ *
+ * For regions created with a specified number of areas the value
+ * represents the size of the areas into which the kernel divided the
+ * region excluding any rounding of the last area size. The number of
+ * areas may be obtained using the dm_stats_nr_areas_region() call.
+ *
+ * All values are returned in units of 512b sectors.
+ */
+uint64_t dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
+				   uint64_t region_id);
+uint64_t dm_stats_get_region_len(const struct dm_stats *dms, uint64_t *len,
+				 uint64_t region_id);
+uint64_t dm_stats_get_region_area_len(const struct dm_stats *dms,
+				      uint64_t *area_len, uint64_t region_id);
+
+/*
+ * Area properties: start and length.
+ *
+ * The area length is always equal to the area length of the region
+ * that contains it and is obtained from dm_stats_get_region_area_len().
+ *
+ * The start offset of an area is a function of the area_id and the
+ * containing region's start and area length.
+ *
+ * All values are returned in units of 512b sectors.
+ */
+uint64_t dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
+				 uint64_t region_id, uint64_t area_id);
+
+/*
+ * Retrieve program_id and aux_data for a specific region. Only valid
+ * following a call to dm_stats_list(). The returned pointer does not
+ * need to be freed separately from the dm_stats handle but will become
+ * invalid after a dm_stats_destroy(), dm_stats_list(),
+ * dm_stats_populate(), or dm_stats_bind*() of the handle from which it
+ * was obtained.
+ */
+const char *dm_stats_get_region_program_id(const struct dm_stats *dms,
+					   uint64_t region_id);
+
+const char *dm_stats_get_region_aux_data(const struct dm_stats *dms,
+					 uint64_t region_id);
+
+/*
+ * Statistics cursor
+ *
+ * A dm_stats handle maintains an optional cursor into the statistics
+ * regions and areas that it stores. Iterators are provided to visit
+ * each region, or each area in a handle and accessor methods are
+ * provided to obtain properties and values for the region or area
+ * at the current cursor position.
+ *
+ * Using the cursor simplifies walking all regions or areas when the
+ * region table is sparse (i.e. contains some present and some
+ * non-present region_id values either due to program_id filtering
+ * or the ordering of region creation and deletion).
+ */
+
+/*
+ * Initialise the cursor of a dm_stats handle to address the first
+ * present region. It is valid to attempt to walk a NULL stats handle
+ * or a handle containing no present regions; in this case any call to
+ * dm_stats_walk_next() becomes a no-op and all calls to
+ * dm_stats_walk_end() return true.
+ */
+void dm_stats_walk_start(struct dm_stats *dms);
+
+/*
+ * Advance the statistics cursor to the next area, or to the next
+ * present region if at the end of the current region.
+ */
+void dm_stats_walk_next(struct dm_stats *dms);
+
+/*
+ * Advance the statistics cursor to the next region.
+ */
+void dm_stats_walk_next_region(struct dm_stats *dms);
+
+/*
+ * Test whether the end of a statistics walk has been reached.
+ */
+int dm_stats_walk_end(struct dm_stats *dms);
+
+/*
+ * Stats iterators
+ *
+ * C 'for' and 'do'/'while' style iterators for dm_stats data.
+ *
+ * It is not safe to call any function that modifies the region table
+ * within the loop body (i.e. dm_stats_list(), dm_stats_populate(),
+ * dm_stats_init(), or dm_stats_destroy()).
+ *
+ * All counter and property (dm_stats_get_*) access methods, as well as
+ * dm_stats_populate_region() can be safely called from loops.
+ *
+ */
+
+/*
+ * Iterate over the regions table visiting each region.
+ *
+ * If the region table is empty or unpopulated the loop body will not be
+ * executed.
+ */
+#define dm_stats_foreach_region(dms)				\
+for (dm_stats_walk_start((dms));				\
+     !dm_stats_walk_end((dms)); dm_stats_walk_next_region((dms)))
+
+/*
+ * Iterate over the regions table visiting each area.
+ *
+ * If the region table is empty or unpopulated the loop body will not
+ * be executed.
+ */
+#define dm_stats_foreach_area(dms)				\
+for (dm_stats_walk_start((dms));				\
+     !dm_stats_walk_end((dms)); dm_stats_walk_next((dms)))
+
+/*
+ * Start a walk iterating over the regions contained in dm_stats handle
+ * 'dms'.
+ *
+ * The body of the loop should call dm_stats_walk_next() or
+ * dm_stats_walk_next_region() to advance to the next element.
+ *
+ * The loop body is executed at least once even if the stats handle is
+ * empty.
+ */
+#define dm_stats_walk_do(dms)					\
+dm_stats_walk_start((dms));					\
+do
+
+/*
+ * Start a 'while' style loop or end a 'do..while' loop iterating over the
+ * regions contained in dm_stats handle 'dms'.
+ */
+#define dm_stats_walk_while(dms)				\
+while(!dm_stats_walk_end((dms)))
+
+/*
+ * Cursor relative property methods
+ *
+ * Calls with the prefix dm_stats_get_current_* operate relative to the
+ * current cursor location, returning properties for the current region
+ * or area of the supplied dm_stats handle.
+ *
+ */
+
+/*
+ * Returns the number of areas (counter sets) contained in the current
+ * region of the supplied dm_stats handle.
+ */
+uint64_t dm_stats_get_current_nr_areas(const struct dm_stats *dms);
+
+/*
+ * Retrieve the current values of the stats cursor.
+ */
+uint64_t dm_stats_get_current_region(const struct dm_stats *dms);
+uint64_t dm_stats_get_current_area(const struct dm_stats *dms);
+
+/*
+ * Current region properties: size, length & area_len.
+ *
+ * See the comments for the equivalent dm_stats_get_* versions for a
+ * complete description of these methods.
+ *
+ * All values are returned in units of 512b sectors.
+ */
+uint64_t dm_stats_get_current_region_start(const struct dm_stats *dms,
+					   uint64_t *start);
+
+uint64_t dm_stats_get_current_region_len(const struct dm_stats *dms,
+					 uint64_t *len);
+
+uint64_t dm_stats_get_current_region_area_len(const struct dm_stats *dms,
+					      uint64_t *area_len);
+
+/*
+ * Current area properties: start and length.
+ *
+ * See the comments for the equivalent dm_stats_get_* versions for a
+ * complete description of these methods.
+ *
+ * All values are returned in units of 512b sectors.
+ */
+uint64_t dm_stats_get_current_area_start(const struct dm_stats *dms,
+					 uint64_t *start);
+
+uint64_t dm_stats_get_current_area_len(const struct dm_stats *dms,
+				       uint64_t *start);
+
+/*
+ * Return a pointer to the program_id string for region at the current
+ * cursor location.
+ */
+const char *dm_stats_get_current_region_program_id(const struct dm_stats *dms);
+
+/*
+ * Return a pointer to the aux_data string for the region@the current
+ * cursor location.
+ */
+const char *dm_stats_get_current_region_aux_data(const struct dm_stats *dms);
+
+/*
  * Call this to actually run the ioctl.
  */
 int dm_task_run(struct dm_task *dmt);
@@ -1941,6 +2437,153 @@ int dm_report_field_percent(struct dm_report *rh, struct dm_report_field *field,
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
+/*
+ * Stats counter access methods
+ *
+ * Each method returns the corresponding stats counter value from the
+ * supplied dm_stats handle for the specified region_id and area_id.
+ * If either region_id or area_id uses one of the special values
+ * DM_STATS_REGION_CURRENT or DM_STATS_AREA_CURRENT then the region
+ * or area is selected according to the current state of the dm_stats
+ * handle's embedded cursor.
+ *
+ * See the kernel documentation for complete descriptions of each
+ * counter field:
+ *
+ * Documentation/device-mapper/statistics.txt
+ * Documentation/iostats.txt
+ *
+ * reads: the number of reads completed
+ * reads_merged: the number of reads merged
+ * read_sectors: the number of sectors read
+ * read_nsecs: the number of nanoseconds spent reading
+ * writes: the number of writes completed
+ * writes_merged: the number of writes merged
+ * write_sectors: the number of sectors written
+ * write_nsecs: the number of nanoseconds spent writing
+ * io_in_progress: the number of I/Os currently in progress
+ * io_nsecs: the number of nanoseconds spent doing I/Os
+ * weighted_io_nsecs: the weighted number of nanoseconds spent doing I/Os
+ * total_read_nsecs: the total time spent reading in nanoseconds
+ * total_write_nsecs: the total time spent writing in nanoseconds
+ */
+
+#define DM_STATS_REGION_CURRENT UINT64_MAX
+#define DM_STATS_AREA_CURRENT UINT64_MAX
+
+uint64_t dm_stats_get_reads(const struct dm_stats *dms,
+			    uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_reads_merged(const struct dm_stats *dms,
+				   uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_read_sectors(const struct dm_stats *dms,
+				   uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_read_nsecs(const struct dm_stats *dms,
+				 uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_writes(const struct dm_stats *dms,
+			     uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_writes_merged(const struct dm_stats *dms,
+				    uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_write_sectors(const struct dm_stats *dms,
+				    uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_write_nsecs(const struct dm_stats *dms,
+				  uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_io_in_progress(const struct dm_stats *dms,
+				     uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_io_nsecs(const struct dm_stats *dms,
+			       uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_weighted_io_nsecs(const struct dm_stats *dms,
+					uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_total_read_nsecs(const struct dm_stats *dms,
+				       uint64_t region_id, uint64_t area_id);
+
+uint64_t dm_stats_get_total_write_nsecs(const struct dm_stats *dms,
+					uint64_t region_id, uint64_t area_id);
+
+/*
+ * Derived statistics access methods
+ *
+ * Each method returns the corresponding value calculated from the
+ * counters stored in the supplied dm_stats handle for the specified
+ * region_id and area_id. If either region_id or area_id uses one of the
+ * special values DM_STATS_REGION_CURRENT or DM_STATS_AREA_CURRENT then
+ * the region or area is selected according to the current state of the
+ * dm_stats handle's embedded cursor.
+ *
+ * The set of metrics is based on the fields provided by the Linux
+ * iostats program.
+ *
+ * rd_merges_per_sec: the number of reads merged per second
+ * wr_merges_per_sec: the number of writes merged per second
+ * reads_per_sec: the number of reads completed per second
+ * writes_per_sec: the number of writes completed per second
+ * read_sectors_per_sec: the number of sectors read per second
+ * write_sectors_per_sec: the number of sectors written per second
+ * average_request_size: the average size of requests submitted
+ * service_time: the average service time (in ns) for requests issued
+ * average_queue_size: the average queue length
+ * average_wait_time: the average time for requests to be served (in ns)
+ * average_rd_wait_time: the average read wait time
+ * average_wr_wait_time: the average write wait time
+ */
+
+int dm_stats_get_rd_merges_per_sec(const struct dm_stats *dms, double *rrqm,
+				   uint64_t region_id, uint64_t area_id);
+
+int dm_stats_get_wr_merges_per_sec(const struct dm_stats *dms, double *rrqm,
+				   uint64_t region_id, uint64_t area_id);
+
+int dm_stats_get_reads_per_sec(const struct dm_stats *dms, double *rd_s,
+			       uint64_t region_id, uint64_t area_id);
+
+int dm_stats_get_writes_per_sec(const struct dm_stats *dms, double *wr_s,
+				uint64_t region_id, uint64_t area_id);
+
+int dm_stats_get_read_sectors_per_sec(const struct dm_stats *dms,
+				      double *rsec_s, uint64_t region_id,
+				      uint64_t area_id);
+
+int dm_stats_get_write_sectors_per_sec(const struct dm_stats *dms,
+				       double *wr_s, uint64_t region_id,
+				       uint64_t area_id);
+
+int dm_stats_get_average_request_size(const struct dm_stats *dms,
+				      double *arqsz, uint64_t region_id,
+				      uint64_t area_id);
+
+int dm_stats_get_service_time(const struct dm_stats *dms, double *svctm,
+			      uint64_t region_id, uint64_t area_id);
+
+int dm_stats_get_average_queue_size(const struct dm_stats *dms, double *qusz,
+				    uint64_t region_id, uint64_t area_id);
+
+int dm_stats_get_average_wait_time(const struct dm_stats *dms, double *await,
+				   uint64_t region_id, uint64_t area_id);
+
+int dm_stats_get_average_rd_wait_time(const struct dm_stats *dms,
+				      double *await, uint64_t region_id,
+				      uint64_t area_id);
+
+int dm_stats_get_average_wr_wait_time(const struct dm_stats *dms,
+				      double *await, uint64_t region_id,
+				      uint64_t area_id);
+
+int dm_stats_get_throughput(const struct dm_stats *dms, double *tput,
+			    uint64_t region_id, uint64_t area_id);
+
+int dm_stats_get_utilization(const struct dm_stats *dms, dm_percent_t *util,
+			     uint64_t region_id, uint64_t area_id);
+
 /*************************
  * config file parse/print
  *************************/
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
new file mode 100644
index 0000000..bf3cad0
--- /dev/null
+++ b/libdm/libdm-stats.c
@@ -0,0 +1,1360 @@
+/*
+ * Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of the device-mapper userspace tools.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "dmlib.h"
+#include "libdm-targets.h"
+#include "libdm-common.h"
+
+#define DM_STATS_REGION_NOT_PRESENT UINT64_MAX
+
+#define NSEC_PER_MSEC   1000000L
+#define NSEC_PER_SEC    1000000000L
+
+/*
+ * See Documentation/device-mapper/statistics.txt for full descriptions
+ * of the device-mapper statistics counter fields.
+ */
+struct dm_stats_counters {
+	uint64_t reads;		    /* Num reads completed */
+	uint64_t reads_merged;	    /* Num reads merged */
+	uint64_t read_sectors;	    /* Num sectors read */
+	uint64_t read_nsecs;	    /* Num milliseconds spent reading */
+	uint64_t writes;	    /* Num writes completed */
+	uint64_t writes_merged;	    /* Num writes merged */
+	uint64_t write_sectors;	    /* Num sectors written */
+	uint64_t write_nsecs;	    /* Num milliseconds spent writing */
+	uint64_t io_in_progress;    /* Num I/Os currently in progress */
+	uint64_t io_nsecs;	    /* Num milliseconds spent doing I/Os */
+	uint64_t weighted_io_nsecs; /* Weighted num milliseconds doing I/Os */
+	uint64_t total_read_nsecs;  /* Total time spent reading in milliseconds */
+	uint64_t total_write_nsecs; /* Total time spent writing in milliseconds */
+};
+
+struct dm_stats_region {
+	uint64_t region_id; /* as returned by @stats_list */
+	uint64_t start;
+	uint64_t len;
+	uint64_t step;
+	char *program_id;
+	char *aux_data;
+	uint64_t timescale; /* precise_timestamps is per-region */
+	struct dm_stats_counters *counters;
+};
+
+struct dm_stats {
+	/* device binding */
+	int major;  /* device major that this dm_stats object is bound to */
+	int minor;  /* device minor that this dm_stats object is bound to */
+	char *name; /* device-mapper device name */
+	char *uuid; /* device-mapper UUID */
+	char *program_id; /* default program_id for this handle */
+	struct dm_pool *mem; /* memory pool for region and counter tables */
+	uint64_t nr_regions; /* total number of present regions */
+	uint64_t max_region; /* size of the regions table */
+	uint64_t interval_ns;  /* sampling interval in nanoseconds */
+	uint64_t timescale; /* sample value multiplier */
+	struct dm_stats_region *regions;
+	/* statistics cursor */
+	uint64_t cur_region;
+	uint64_t cur_area;
+};
+
+#define PROC_SELF_COMM "/proc/self/comm"
+static char *_program_id_from_proc(void)
+{
+	FILE *comm = NULL;
+	char buf[256];
+
+	if (!(comm = fopen(PROC_SELF_COMM, "r")))
+		return_NULL;
+
+	if (!fgets(buf, sizeof(buf), comm))
+		return_NULL;
+
+	if (fclose(comm))
+		return_NULL;
+
+	return dm_strdup(buf);
+}
+
+struct dm_stats *dm_stats_create(const char *program_id)
+{
+	struct dm_stats *dms = NULL;
+
+	if (!(dms = dm_malloc(sizeof(*dms))))
+		return_NULL;
+	if (!(dms->mem = dm_pool_create("stats_pool", 4096)))
+		return_NULL;
+
+	if (!program_id || !strlen(program_id))
+		dms->program_id = _program_id_from_proc();
+	else
+		dms->program_id = dm_strdup(program_id);
+
+	dms->major = -1;
+	dms->minor = -1;
+	dms->name = NULL;
+	dms->uuid = NULL;
+
+	/* all regions currently use msec precision */
+	dms->timescale = NSEC_PER_MSEC;
+
+	dms->nr_regions = DM_STATS_REGION_NOT_PRESENT;
+	dms->max_region = DM_STATS_REGION_NOT_PRESENT;
+	dms->regions = NULL;
+
+	return dms;
+}
+
+/**
+ * Test whether the stats region pointed to by region is present.
+ */
+static int _stats_region_present(const struct dm_stats_region *region)
+{
+	return !(region->region_id == DM_STATS_REGION_NOT_PRESENT);
+}
+
+static void _stats_region_destroy(struct dm_stats_region *region)
+{
+	if (!_stats_region_present(region))
+		return;
+
+	/**
+	 * Don't free counters here explicitly; it will be dropped
+	 * from the pool along with the corresponding regions table.
+	 */
+
+	if (region->program_id)
+		dm_free(region->program_id);
+	if (region->aux_data)
+		dm_free(region->aux_data);
+}
+
+static void _stats_regions_destroy(struct dm_stats *dms)
+{
+	struct dm_pool *mem = dms->mem;
+	uint64_t i;
+
+	if (!dms->regions)
+		return;
+
+	/* walk backwards to obey pool order */
+	for (i = dms->max_region; (i != DM_STATS_REGION_NOT_PRESENT); i--)
+		_stats_region_destroy(&dms->regions[i]);
+	dm_pool_free(mem, dms->regions);
+}
+
+static int _set_stats_device(struct dm_stats *dms, struct dm_task *dmt)
+{
+	if (dms->name)
+		return dm_task_set_name(dmt, dms->name);
+	if (dms->uuid)
+		return dm_task_set_uuid(dmt, dms->uuid);
+	if (dms->major > 0)
+		return dm_task_set_major(dmt, dms->major)
+			&& dm_task_set_minor(dmt, dms->minor);
+	return_0;
+}
+
+static int _stats_bound(struct dm_stats *dms)
+{
+	if (dms->major > 0 || dms->name || dms->uuid)
+		return 1;
+	/* %p format specifier expects a void pointer. */
+	log_debug("Stats handle at %p is not bound.", (void *) dms);
+	return 0;
+}
+
+static void _stats_clear_binding(struct dm_stats *dms)
+{
+	if (dms->name)
+		dm_pool_free(dms->mem, dms->name);
+	if (dms->uuid)
+		dm_pool_free(dms->mem, dms->uuid);
+
+	dms->name = dms->uuid = NULL;
+	dms->major = dms->minor = -1;
+}
+
+int dm_stats_bind_devno(struct dm_stats *dms, int major, int minor)
+{
+	_stats_clear_binding(dms);
+	_stats_regions_destroy(dms);
+
+	dms->major = major;
+	dms->minor = minor;
+
+	return 1;
+}
+
+int dm_stats_bind_name(struct dm_stats *dms, const char *name)
+{
+	_stats_clear_binding(dms);
+	_stats_regions_destroy(dms);
+
+	if (!(dms->name = dm_pool_strdup(dms->mem, name)))
+		return_0;
+
+	return 1;
+}
+
+int dm_stats_bind_uuid(struct dm_stats *dms, const char *uuid)
+{
+	_stats_clear_binding(dms);
+	_stats_regions_destroy(dms);
+
+	if (!(dms->uuid = dm_pool_strdup(dms->mem, uuid)))
+		return_0;
+
+	return 1;
+}
+
+static struct dm_task *_stats_send_message(struct dm_stats *dms, char *msg)
+{
+	struct dm_task *dmt;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_TARGET_MSG)))
+		return_0;
+
+	if (!_set_stats_device(dms, dmt))
+		goto_out;
+
+	if (!dm_task_set_message(dmt, msg))
+		goto_out;
+
+	if (!dm_task_run(dmt))
+		goto_out;
+
+	return dmt;
+out:
+	dm_task_destroy(dmt);
+	return NULL;
+}
+
+static int _stats_parse_list_region(struct dm_stats_region *region, char *line)
+{
+	/* FIXME: the kernel imposes no length limit here */
+	char program_id[256], aux_data[256];
+	int r;
+
+	/* line format:
+	 * <region_id>: <start_sector>+<length> <step> <program_id> <aux_data>
+	 */
+	r = sscanf(line, FMTu64 ": " FMTu64 "+" FMTu64 " " FMTu64 "%255s %255s",
+		   &region->region_id, &region->start, &region->len, &region->step,
+		   program_id, aux_data);
+
+	if (r != 6)
+		return_0;
+
+	if (!strcmp(program_id, "-"))
+		program_id[0] = '\0';
+	if (!strcmp(aux_data, "-"))
+		aux_data[0] = '\0';
+
+	if (!(region->program_id = dm_strdup(program_id)))
+		return_0;
+	if (!(region->aux_data = dm_strdup(aux_data))) {
+		dm_free(region->program_id);
+		return_0;
+	}
+
+	region->counters = NULL;
+	return 1;
+}
+
+static int _stats_parse_list(struct dm_stats *dms, const char *resp)
+{
+	struct dm_pool *mem = dms->mem;
+	struct dm_stats_region cur;
+	uint64_t max_region = 0, nr_regions = 0;
+	FILE *list_rows;
+	/* FIXME: determine correct maximum line length based on kernel format */
+	char line[256];
+
+	if (!resp) {
+		log_error("Could not parse NULL @stats_list response.");
+		return 0;
+	}
+
+	if (dms->regions)
+		_stats_regions_destroy(dms);
+
+	/* no regions */
+	if (!strlen(resp)) {
+		dms->nr_regions = dms->max_region = 0;
+		dms->regions = NULL;
+		return 1;
+	}
+
+	/*
+	 * dm_task_get_message_response() returns a 'const char *' but
+	 * since fmemopen also permits "w" it expects a 'char *'.
+	 */
+	if (!(list_rows = fmemopen((char *)resp, strlen(resp), "r")))
+		return_0;
+
+	if (!dm_pool_begin_object(mem, 1024))
+		goto_out;
+
+	while(fgets(line, sizeof(line), list_rows)) {
+
+		if (!_stats_parse_list_region(&cur, line))
+			goto_out;
+
+		/* handle holes in the list of region_ids */
+		if (cur.region_id > max_region) {
+			struct dm_stats_region fill;
+			memset(&fill, 0, sizeof(fill));
+			fill.region_id = DM_STATS_REGION_NOT_PRESENT;
+			do {
+				if (!dm_pool_grow_object(mem, &fill, sizeof(fill)))
+					goto_out;
+			} while (max_region++ < (cur.region_id - 1));
+		}
+
+		if (!dm_pool_grow_object(mem, &cur, sizeof(cur)))
+			goto_out;
+
+		max_region++;
+		nr_regions++;
+	}
+
+	dms->nr_regions = nr_regions;
+	dms->max_region = max_region - 1;
+	dms->regions = dm_pool_end_object(mem);
+
+	fclose(list_rows);
+	return 1;
+out:
+	fclose(list_rows);
+	dm_pool_abandon_object(mem);
+	return 0;
+}
+
+int dm_stats_list(struct dm_stats *dms, const char *program_id)
+{
+	struct dm_task *dmt;
+	char msg[256];
+	int r;
+
+	if (!_stats_bound(dms))
+		return_0;
+
+	/* allow zero-length program_id for list */
+	if (!program_id)
+		program_id = dms->program_id;
+
+	r = dm_snprintf(msg, sizeof(msg), "@stats_list %s", program_id);
+
+	if (r < 0) {
+		log_error("Failed to prepare stats message.");
+		return 0;
+	}
+
+	if (!(dmt = _stats_send_message(dms, msg)))
+		return 0;
+
+	if (!_stats_parse_list(dms, dm_task_get_message_response(dmt))) {
+		log_error("Could not parse @stats_list response.");
+		goto out;
+	}
+
+	dm_task_destroy(dmt);
+	return 1;
+
+out:
+	dm_task_destroy(dmt);
+	return 0;
+}
+
+static int _stats_parse_region(struct dm_pool *mem, const char *resp,
+			       struct dm_stats_region *region,
+			       uint64_t timescale)
+{
+	struct dm_stats_counters cur;
+	FILE *stats_rows = NULL;
+	uint64_t start, len;
+	char row[256];
+	int r;
+
+	if (!resp) {
+		log_error("Could not parse empty @stats_print response.");
+		return 0;
+	}
+
+	region->start = UINT64_MAX;
+
+	if (!dm_pool_begin_object(mem, 512))
+		goto_out;
+
+	/*
+	 * dm_task_get_message_response() returns a 'const char *' but
+	 * since fmemopen also permits "w" it expects a 'char *'.
+	 */
+	stats_rows = fmemopen((char *)resp, strlen(resp), "r");
+	if (!stats_rows)
+		goto_out;
+
+	/*
+	 * Output format for each step-sized area of a region:
+	 *
+	 * <start_sector>+<length> counters
+	 *
+	 * The first 11 counters have the same meaning as
+	 * /sys/block/ * /stat or /proc/diskstats.
+	 *
+	 * Please refer to Documentation/iostats.txt for details.
+	 *
+	 * 1. the number of reads completed
+	 * 2. the number of reads merged
+	 * 3. the number of sectors read
+	 * 4. the number of milliseconds spent reading
+	 * 5. the number of writes completed
+	 * 6. the number of writes merged
+	 * 7. the number of sectors written
+	 * 8. the number of milliseconds spent writing
+	 * 9. the number of I/Os currently in progress
+	 * 10. the number of milliseconds spent doing I/Os
+	 * 11. the weighted number of milliseconds spent doing I/Os
+	 *
+	 * Additional counters:
+	 * 12. the total time spent reading in milliseconds
+	 * 13. the total time spent writing in milliseconds
+	 *
+	*/
+	while (fgets(row, sizeof(row), stats_rows)) {
+		r = sscanf(row, FMTu64 "+" FMTu64 /* start+len */
+			   /* reads */
+			   FMTu64 " " FMTu64 " " FMTu64 " " FMTu64 " "
+			   /* writes */
+			   FMTu64 " " FMTu64 " " FMTu64 " " FMTu64 " "
+			   /* in flight & io nsecs */
+			   FMTu64 " " FMTu64 " " FMTu64 " "
+			   /* tot read/write nsecs */
+			   FMTu64 " " FMTu64, &start, &len,
+			   &cur.reads, &cur.reads_merged, &cur.read_sectors,
+			   &cur.read_nsecs,
+			   &cur.writes, &cur.writes_merged, &cur.write_sectors,
+			   &cur.write_nsecs,
+			   &cur.io_in_progress,
+			   &cur.io_nsecs, &cur.weighted_io_nsecs,
+			   &cur.total_read_nsecs, &cur.total_write_nsecs);
+		if (r != 15) {
+			log_error("Could not parse @stats_print row.");
+			goto out;
+		}
+
+		/* scale time values up if needed */
+		if (timescale != 1) {
+			cur.read_nsecs *= timescale;
+			cur.write_nsecs *= timescale;
+			cur.io_nsecs *= timescale;
+			cur.weighted_io_nsecs *= timescale;
+			cur.total_read_nsecs *= timescale;
+			cur.total_write_nsecs *= timescale;
+		}
+
+		if(!dm_pool_grow_object(mem, &cur, sizeof(cur)))
+			goto_out;
+		if (region->start == UINT64_MAX) {
+			region->start = start;
+			region->step = len; /* area size is always uniform. */
+		}
+	}
+
+	region->len = (start + len) - region->start;
+	region->timescale = timescale;
+	region->counters = dm_pool_end_object(mem);
+
+	fclose(stats_rows);
+	return 1;
+
+out:
+
+	if (stats_rows)
+		fclose(stats_rows);
+	dm_pool_abandon_object(mem);
+	return 0;
+}
+
+static uint64_t _nr_areas(uint64_t len, uint64_t step)
+{
+	/*
+	 * drivers/md/dm-stats.c::message_stats_create()
+	 * A region may be sub-divided into areas with their own counters.
+	 * If step is non-zero, divide len into that many areas, otherwise
+	 * treat the entire region as a single area. Any partial area at the
+	 * end of the region is treated as an additional complete area.
+	 */
+	return (len && step)
+		? (len / (step ? step : len)) + !!(len % step) : 0;
+}
+
+static uint64_t _nr_areas_region(struct dm_stats_region *region)
+{
+	return _nr_areas(region->len, region->step);
+}
+
+static void _stats_walk_next(const struct dm_stats *dms, int region,
+			     uint64_t *cur_r, uint64_t *cur_a)
+{
+	struct dm_stats_region *cur = NULL;
+	int present;
+
+	if (!dms || !dms->regions)
+		return;
+
+	cur = &dms->regions[*cur_r];
+	present = _stats_region_present(cur);
+
+	if (region && present)
+		*cur_a = _nr_areas_region(cur);
+
+	if (region || !present || ++(*cur_a) == _nr_areas_region(cur)) {
+		*cur_a = 0;
+		while(!dm_stats_region_present(dms, ++(*cur_r))
+		      && *cur_r < dms->max_region)
+			; /* keep walking until a present region is found
+			   * or the end of the table is reached. */
+	}
+
+}
+
+static void _stats_walk_start(const struct dm_stats *dms,
+			      uint64_t *cur_r, uint64_t *cur_a)
+{
+	if (!dms || !dms->regions)
+		return;
+
+	*cur_r = 0;
+	*cur_a = 0;
+
+	/* advance to the first present region */
+	if (!dm_stats_region_present(dms, dms->cur_region))
+		_stats_walk_next(dms, 0, cur_r, cur_a);
+}
+
+void dm_stats_walk_start(struct dm_stats *dms)
+{
+	_stats_walk_start(dms, &dms->cur_region, &dms->cur_area);
+}
+
+void dm_stats_walk_next(struct dm_stats *dms)
+{
+	_stats_walk_next(dms, 0, &dms->cur_region, &dms->cur_area);
+}
+
+void dm_stats_walk_next_region(struct dm_stats *dms)
+{
+	_stats_walk_next(dms, 1, &dms->cur_region, &dms->cur_area);
+}
+
+static int _stats_walk_end(const struct dm_stats *dms,
+			   uint64_t *cur_r, uint64_t *cur_a)
+{
+	struct dm_stats_region *region = NULL;
+	int end = 0;
+
+	if (!dms || !dms->regions)
+		return 1;
+
+	region = &dms->regions[*cur_r];
+	end = (*cur_r > dms->max_region
+	       || (*cur_r == dms->max_region
+		&& *cur_a >= _nr_areas_region(region)));
+
+	return end;
+}
+
+int dm_stats_walk_end(struct dm_stats *dms)
+{
+	return _stats_walk_end(dms, &dms->cur_region, &dms->cur_area);
+}
+
+uint64_t dm_stats_get_region_nr_areas(const struct dm_stats *dms,
+				      uint64_t region_id)
+{
+	struct dm_stats_region *region = &dms->regions[region_id];
+	return _nr_areas_region(region);
+}
+
+uint64_t dm_stats_get_current_nr_areas(const struct dm_stats *dms)
+{
+	return dm_stats_get_region_nr_areas(dms, dms->cur_region);
+}
+
+uint64_t dm_stats_get_nr_areas(const struct dm_stats *dms)
+{
+	uint64_t nr_areas = 0;
+	/* use a separate cursor */
+	uint64_t cur_region, cur_area;
+
+	_stats_walk_start(dms, &cur_region, &cur_area);
+	do {
+		nr_areas += dm_stats_get_current_nr_areas(dms);
+		_stats_walk_next(dms, 1, &cur_region, &cur_area);
+	} while (!_stats_walk_end(dms, &cur_region, &cur_area));
+	return nr_areas;
+}
+
+int dm_stats_create_region(struct dm_stats *dms, uint64_t *region_id,
+			   uint64_t start, uint64_t len, int64_t step,
+			   const char *program_id, const char *aux_data)
+{
+	struct dm_task *dmt = NULL;
+	char msg[1024], range[64];
+	const char *err_fmt = "Could not prepare @stats_create %s.";
+	const char *resp;
+
+	if (!_stats_bound(dms))
+		return_0;
+
+	if (!program_id || !strlen(program_id))
+		program_id = dms->program_id;
+
+	if (start || len) {
+		if (!dm_snprintf(range, sizeof(range), FMTu64 "+" FMTu64,
+				 start, len)) {
+			log_error(err_fmt, "range");
+			goto out;
+		}
+	}
+
+	if (!dm_snprintf(msg, sizeof(msg), "@stats_create %s %s" FMTu64 " %s %s",
+			 (start || len) ? range : "-",
+			 (step < 0) ? "/" : "",
+			 (uint64_t)llabs(step), program_id, aux_data)) {
+		log_error(err_fmt, "message");
+		goto out;
+	}
+
+	if (!(dmt = _stats_send_message(dms, msg)))
+		goto out;
+
+	resp = dm_task_get_message_response(dmt);
+	if (!resp) {
+		log_error("Could not parse empty @stats_create response.");
+		goto out;
+	}
+
+	if (region_id) {
+		char *endptr = NULL;
+		*region_id = strtoull(resp, &endptr, 10);
+		if (resp == endptr)
+			goto_out;
+	}
+
+	dm_task_destroy(dmt);
+
+	return 1;
+out:
+	if(dmt)
+		dm_task_destroy(dmt);
+	return 0;
+}
+
+int dm_stats_delete_region(struct dm_stats *dms, uint64_t region_id)
+{
+	struct dm_task *dmt;
+	char msg[1024];
+
+	if (!_stats_bound(dms))
+		return_0;
+
+	if (!dm_snprintf(msg, sizeof(msg), "@stats_delete " FMTu64, region_id)) {
+		log_error("Could not prepare @stats_delete message.");
+		goto out;
+	}
+
+	dmt = _stats_send_message(dms, msg);
+	if (!dmt)
+		goto_out;
+	dm_task_destroy(dmt);
+	return 1;
+
+out:
+	return 0;
+}
+
+int dm_stats_clear_region(struct dm_stats *dms, uint64_t region_id)
+{
+	struct dm_task *dmt;
+	char msg[1024];
+
+	if (!_stats_bound(dms))
+		return_0;
+
+	if (!dm_snprintf(msg, sizeof(msg), "@stats_clear " FMTu64, region_id)) {
+		log_error("Could not prepare @stats_clear message.");
+		goto out;
+	}
+
+	dmt = _stats_send_message(dms, msg);
+	if (!dmt)
+		goto_out;
+	dm_task_destroy(dmt);
+	return 1;
+
+out:
+	return 0;
+}
+
+static struct dm_task *_stats_print_region(struct dm_stats *dms,
+				    uint64_t region_id, unsigned start_line,
+				    unsigned num_lines, unsigned clear)
+{
+	struct dm_task *dmt = NULL;
+	/* @stats_print[_clear] <region_id> [<start_line> <num_lines>] */
+	const char *clear_str = "_clear", *lines_fmt = "%u %u";
+	const char *msg_fmt = "@stats_print%s " FMTu64 " %s";
+	const char *err_fmt = "Could not prepare @stats_print %s.";
+	char msg[1024], lines[64];
+
+	if (start_line || num_lines)
+		if (!dm_snprintf(lines, sizeof(lines),
+				 lines_fmt, start_line, num_lines)) {
+			log_error(err_fmt, "row specification");
+			goto out;
+		}
+
+	if (!dm_snprintf(msg, sizeof(msg), msg_fmt, (clear) ? clear_str : "",
+			 region_id, (start_line || num_lines) ? lines : "")) {
+		log_error(err_fmt, "message");
+		goto out;
+	}
+
+	if (!(dmt = _stats_send_message(dms, msg)))
+		goto out;
+
+	return dmt;
+
+out:
+	return NULL;
+}
+
+char *dm_stats_print_region(struct dm_stats *dms, uint64_t region_id,
+			    unsigned start_line, unsigned num_lines,
+			    unsigned clear)
+{
+	char *resp = NULL;
+	struct dm_task *dmt = NULL;
+
+	if (!_stats_bound(dms))
+		return_0;
+
+	dmt = _stats_print_region(dms, region_id,
+				  start_line, num_lines, clear);
+
+	if (!dmt)
+		return 0;
+
+	resp = dm_pool_strdup(dms->mem, dm_task_get_message_response(dmt));
+	dm_task_destroy(dmt);
+
+	if (!resp)
+		log_error("Could not allocate memory for response buffer.");
+
+	return resp;
+}
+
+void dm_stats_buffer_destroy(struct dm_stats *dms, char *buffer)
+{
+	dm_pool_free(dms->mem, buffer);
+}
+
+uint64_t dm_stats_get_nr_regions(const struct dm_stats *dms)
+{
+	if (!dms || !dms->regions)
+		return 0;
+	return dms->nr_regions;
+}
+
+/**
+ * Test whether region_id is present in this set of stats data
+ */
+int dm_stats_region_present(const struct dm_stats *dms, uint64_t region_id)
+{
+	if (!dms->regions)
+		return 0;
+
+	if (region_id > dms->max_region)
+		return 0;
+
+	return _stats_region_present(&dms->regions[region_id]);
+}
+
+static int _dm_stats_populate_region(struct dm_stats *dms, uint64_t region_id,
+				     const char *resp)
+{
+	struct dm_stats_region *region = &dms->regions[region_id];
+
+	if (!_stats_bound(dms))
+		return_0;
+
+	if (!_stats_parse_region(dms->mem, resp, region, dms->timescale)) {
+		log_error("Could not parse @stats_print message response.");
+		return 0;
+	}
+	region->region_id = region_id;
+	return 1;
+}
+
+int dm_stats_populate(struct dm_stats *dms, const char *program_id,
+		      uint64_t region_id)
+{
+	int all_regions = (region_id == DM_STATS_REGIONS_ALL);
+
+	if (!_stats_bound(dms))
+		return_0;
+
+	/* allow zero-length program_id for populate */
+	if (!program_id)
+		program_id = dms->program_id;
+
+	if (all_regions && !dm_stats_list(dms, program_id)) {
+		log_error("Could not parse @stats_list response.");
+		goto out;
+	}
+
+	/* successful list but no regions registered */
+	if (!dms->nr_regions)
+		return 0;
+
+	dm_stats_walk_start(dms);
+	do {
+		struct dm_task *dmt = NULL; /* @stats_print task */
+		const char *resp;
+
+		region_id = (all_regions)
+			     ? dm_stats_get_current_region(dms) : region_id;
+
+		/* obtain all lines and clear counter values */
+		if (!(dmt = _stats_print_region(dms, region_id, 0, 0, 1)))
+			goto_out;
+
+		resp = dm_task_get_message_response(dmt);
+		if (!_dm_stats_populate_region(dms, region_id, resp)) {
+			dm_task_destroy(dmt);
+			goto_out;
+		}
+
+		dm_task_destroy(dmt);
+		dm_stats_walk_next_region(dms);
+
+	} while (all_regions && !dm_stats_walk_end(dms));
+
+	return 1;
+
+out:
+	_stats_regions_destroy(dms);
+	dms->regions = NULL;
+	return 0;
+}
+
+/**
+ * destroy a dm_stats object and all associated regions and counter sets.
+ */
+void dm_stats_destroy(struct dm_stats *dms)
+{
+	_stats_regions_destroy(dms);
+	_stats_clear_binding(dms);
+	dm_pool_destroy(dms->mem);
+	dm_free(dms->program_id);
+	dm_free(dms);
+}
+
+/**
+ * Methods for accessing counter fields. All methods share the
+ * following naming scheme and prototype:
+ *
+ * uint64_t dm_stats_get_COUNTER(struct dm_stats *, uint64_t, uint64_t)
+ *
+ * Where the two integer arguments are the region_id and area_id
+ * respectively.
+ */
+#define MK_STATS_GET_COUNTER_FN(counter)				\
+uint64_t dm_stats_get_ ## counter(const struct dm_stats *dms,		\
+				uint64_t region_id, uint64_t area_id)	\
+{									\
+	region_id = (region_id == DM_STATS_REGION_CURRENT)		\
+		     ? dms->cur_region : region_id ;			\
+	area_id = (area_id == DM_STATS_REGION_CURRENT)			\
+		   ? dms->cur_area : area_id ;				\
+	return dms->regions[region_id].counters[area_id].counter;	\
+}
+
+MK_STATS_GET_COUNTER_FN(reads)
+MK_STATS_GET_COUNTER_FN(reads_merged)
+MK_STATS_GET_COUNTER_FN(read_sectors)
+MK_STATS_GET_COUNTER_FN(read_nsecs)
+MK_STATS_GET_COUNTER_FN(writes)
+MK_STATS_GET_COUNTER_FN(writes_merged)
+MK_STATS_GET_COUNTER_FN(write_sectors)
+MK_STATS_GET_COUNTER_FN(write_nsecs)
+MK_STATS_GET_COUNTER_FN(io_in_progress)
+MK_STATS_GET_COUNTER_FN(io_nsecs)
+MK_STATS_GET_COUNTER_FN(weighted_io_nsecs)
+MK_STATS_GET_COUNTER_FN(total_read_nsecs)
+MK_STATS_GET_COUNTER_FN(total_write_nsecs)
+#undef MK_STATS_GET_COUNTER_FN
+
+int dm_stats_get_rd_merges_per_sec(const struct dm_stats *dms, double *rrqm,
+				   uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	*rrqm = ((double) c->reads_merged) / (double) dms->interval_ns;
+	return 1;
+}
+
+int dm_stats_get_wr_merges_per_sec(const struct dm_stats *dms, double *wrqm,
+				   uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	*wrqm = ((double) c->writes_merged) / (double) dms->interval_ns;
+	return 1;
+}
+
+int dm_stats_get_reads_per_sec(const struct dm_stats *dms, double *rd_s,
+			       uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	*rd_s = ((double) c->reads * NSEC_PER_SEC) / (double) dms->interval_ns;
+	return 1;
+}
+
+int dm_stats_get_writes_per_sec(const struct dm_stats *dms, double *wr_s,
+				uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	*wr_s = ((double) c->writes * (double) NSEC_PER_SEC)
+		 / (double) dms->interval_ns;
+
+	return 1;
+}
+
+int dm_stats_get_read_sectors_per_sec(const struct dm_stats *dms, double *rsec_s,
+				      uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	*rsec_s = ((double) c->read_sectors * (double) NSEC_PER_SEC)
+		   / (double) dms->interval_ns;
+
+	return 1;
+}
+
+int dm_stats_get_write_sectors_per_sec(const struct dm_stats *dms, double *wsec_s,
+				       uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	*wsec_s = ((double) c->write_sectors * (double) NSEC_PER_SEC)
+		   / (double) dms->interval_ns;
+	return 1;
+}
+
+int dm_stats_get_average_request_size(const struct dm_stats *dms, double *arqsz,
+				      uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+	uint64_t nr_ios, nr_sectors;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	*arqsz = 0.0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	nr_ios = c->reads + c->writes;
+	nr_sectors = c->read_sectors + c->write_sectors;
+	if (nr_ios)
+		*arqsz = (double) nr_sectors / (double) nr_ios;
+	return 1;
+}
+
+int dm_stats_get_average_queue_size(const struct dm_stats *dms, double *qusz,
+				    uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+	uint64_t io_ticks;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	*qusz = 0.0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	io_ticks = c->weighted_io_nsecs;
+	if (io_ticks)
+		*qusz = (double) io_ticks / (double) dms->interval_ns;
+	return 1;
+}
+
+int dm_stats_get_average_wait_time(const struct dm_stats *dms, double *await,
+				   uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+	uint64_t io_ticks, nr_ios;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	*await = 0.0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	io_ticks = c->read_nsecs + c->write_nsecs;
+	nr_ios = c->reads + c->writes;
+	if (nr_ios)
+		*await = (double) io_ticks / (double) nr_ios;
+	return 1;
+}
+
+int dm_stats_get_average_rd_wait_time(const struct dm_stats *dms,
+				      double *await, uint64_t region_id,
+				      uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+	uint64_t rd_io_ticks, nr_rd_ios;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	*await = 0.0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	rd_io_ticks = c->read_nsecs;
+	nr_rd_ios = c->reads;
+	if (rd_io_ticks)
+		*await = (double) rd_io_ticks / (double) nr_rd_ios;
+	return 1;
+}
+
+int dm_stats_get_average_wr_wait_time(const struct dm_stats *dms,
+				      double *await, uint64_t region_id,
+				      uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+	uint64_t wr_io_ticks, nr_wr_ios;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	*await = 0.0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+	wr_io_ticks = c->write_nsecs;
+	nr_wr_ios = c->writes;
+	if (wr_io_ticks && nr_wr_ios)
+		*await = (double) wr_io_ticks / (double) nr_wr_ios;
+	return 1;
+}
+
+int dm_stats_get_service_time(const struct dm_stats *dms, double *svctm,
+			      uint64_t region_id, uint64_t area_id)
+{
+	dm_percent_t util;
+	double tput;
+
+	if (!dm_stats_get_throughput(dms, &tput, region_id, area_id))
+		return 0;
+
+	if (!dm_stats_get_utilization(dms, &util, region_id, area_id))
+		return 0;
+
+	/* avoid NAN with zero counter values */
+	if ( (uint64_t) tput == 0 || (uint64_t) util == 0) {
+		*svctm = 0.0;
+		return 1;
+	}
+	*svctm = ((double) NSEC_PER_SEC * dm_percent_to_float(util))
+		  / (100.0 * tput);
+	return 1;
+}
+
+int dm_stats_get_throughput(const struct dm_stats *dms, double *tput,
+			    uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+
+	*tput = (( NSEC_PER_SEC * ((double) c->reads + (double) c->writes))
+		 / (double) (dms->interval_ns));
+	return 1;
+}
+
+int dm_stats_get_utilization(const struct dm_stats *dms, dm_percent_t *util,
+			     uint64_t region_id, uint64_t area_id)
+{
+	struct dm_stats_counters *c;
+	uint64_t io_nsecs;
+
+	if (!dms->interval_ns)
+		return_0;
+
+	region_id = (region_id == DM_STATS_REGION_CURRENT)
+		     ? dms->cur_region : region_id ;
+	area_id = (area_id == DM_STATS_REGION_CURRENT)
+		   ? dms->cur_area : area_id ;
+
+	c = &(dms->regions[region_id].counters[area_id]);
+
+	/**
+	 * If io_nsec > interval_ns there is something wrong with the clock
+	 * for the last interval; do not allow a value > 100% utilization
+	 * to be passed to a dm_make_percent() call. We expect to see these
+	 * at startup if counters have not been cleared before the first read.
+	 */
+	io_nsecs = (c->io_nsecs <= dms->interval_ns) ? c->io_nsecs : dms->interval_ns;
+	*util = dm_make_percent(io_nsecs, dms->interval_ns);
+
+	return 1;
+}
+
+void dm_stats_set_sampling_interval_ms(struct dm_stats *dms, uint64_t interval_ms)
+{
+	/* All times use nsecs internally. */
+	dms->interval_ns = interval_ms * NSEC_PER_MSEC;
+}
+
+void dm_stats_set_sampling_interval_ns(struct dm_stats *dms, uint64_t interval_ns)
+{
+	dms->interval_ns = interval_ns;
+}
+
+uint64_t dm_stats_get_sampling_interval_ms(const struct dm_stats *dms)
+{
+	/* All times use nsecs internally. */
+	return (dms->interval_ns / NSEC_PER_MSEC);
+}
+
+uint64_t dm_stats_get_sampling_interval_ns(const struct dm_stats *dms)
+{
+	/* All times use nsecs internally. */
+	return (dms->interval_ns);
+}
+
+int dm_stats_set_program_id(struct dm_stats *dms, int allow_empty,
+			    const char *program_id)
+{
+	if (!allow_empty && (!program_id || !strlen(program_id))) {
+		log_error("Empty program_id not permitted without "
+			  "allow_empty=1");
+		return 0;
+	}
+
+	if (!program_id)
+		program_id = "";
+
+	if (dms->program_id)
+		dm_free(dms->program_id);
+
+	if (!(dms->program_id = dm_strdup(program_id)))
+		return_0;
+
+	return 1;
+}
+
+uint64_t dm_stats_get_current_region(const struct dm_stats *dms)
+{
+	return dms->cur_region;
+}
+
+uint64_t dm_stats_get_current_area(const struct dm_stats *dms)
+{
+	return dms->cur_area;
+}
+
+uint64_t dm_stats_get_region_start(const struct dm_stats *dms, uint64_t *start,
+			      uint64_t region_id)
+{
+	if (!dms || !dms->regions)
+		return_0;
+	*start = dms->regions[region_id].start;
+	return 1;
+}
+
+uint64_t dm_stats_get_region_len(const struct dm_stats *dms, uint64_t *len,
+			    uint64_t region_id)
+{
+	if (!dms || !dms->regions)
+		return_0;
+	*len = dms->regions[region_id].len;
+	return 1;
+}
+
+uint64_t dm_stats_get_region_area_len(const struct dm_stats *dms, uint64_t *step,
+			    uint64_t region_id)
+{
+	if (!dms || !dms->regions)
+		return_0;
+	*step = dms->regions[region_id].step;
+	return 1;
+}
+
+uint64_t dm_stats_get_current_region_start(const struct dm_stats *dms,
+					   uint64_t *start)
+{
+	return dm_stats_get_region_start(dms, start, dms->cur_region);
+}
+
+uint64_t dm_stats_get_current_region_len(const struct dm_stats *dms,
+					 uint64_t *len)
+{
+	return dm_stats_get_region_len(dms, len, dms->cur_region);
+}
+
+uint64_t dm_stats_get_current_region_area_len(const struct dm_stats *dms,
+					      uint64_t *step)
+{
+	return dm_stats_get_region_area_len(dms, step, dms->cur_region);
+}
+
+uint64_t dm_stats_get_area_start(const struct dm_stats *dms, uint64_t *start,
+				 uint64_t region_id, uint64_t area_id)
+{
+	if (!dms || !dms->regions)
+		return_0;
+	*start = dms->regions[region_id].step * area_id;
+	return 1;
+}
+
+uint64_t dm_stats_get_current_area_start(const struct dm_stats *dms,
+					 uint64_t *start)
+{
+	return dm_stats_get_area_start(dms, start,
+				       dms->cur_region, dms->cur_area);
+}
+
+uint64_t dm_stats_get_current_area_len(const struct dm_stats *dms,
+				       uint64_t *len)
+{
+	return dm_stats_get_region_area_len(dms, len, dms->cur_region);
+}
+
+const char *dm_stats_get_region_program_id(const struct dm_stats *dms,
+					   uint64_t region_id)
+{
+	const char *program_id = dms->regions[region_id].program_id;
+	return (program_id) ? program_id : "";
+}
+
+const char *dm_stats_get_region_aux_data(const struct dm_stats *dms,
+					 uint64_t region_id)
+{
+	const char *aux_data = dms->regions[region_id].aux_data;
+	return (aux_data) ? aux_data : "" ;
+}
+
+const char *dm_stats_get_current_region_program_id(const struct dm_stats *dms)
+{
+	return dm_stats_get_region_program_id(dms, dms->cur_region);
+}
+
+const char *dm_stats_get_current_region_aux_data(const struct dm_stats *dms)
+{
+	return dm_stats_get_region_aux_data(dms, dms->cur_region);
+}
diff --git a/man/Makefile.in b/man/Makefile.in
index 0eca987..dc16a76 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -83,7 +83,7 @@ ifneq ("@THIN@", "none")
   MAN7+=lvmthin.7
 endif
 
-MAN8DM=dmsetup.8 $(DMEVENTDMAN) $(BLKDEACTIVATEMAN)
+MAN8DM=dmsetup.8 dmstats.8 $(DMEVENTDMAN) $(BLKDEACTIVATEMAN)
 MAN5DIR=$(mandir)/man5
 MAN7DIR=$(mandir)/man7
 MAN8DIR=$(mandir)/man8
diff --git a/man/dmstats.8.in b/man/dmstats.8.in
new file mode 100644
index 0000000..c5ef47f
--- /dev/null
+++ b/man/dmstats.8.in
@@ -0,0 +1,693 @@
+.TH DMSTATS 8 "Jul 25 2015" "Linux" "MAINTENANCE COMMANDS"
+.SH NAME
+dmstats \(em device-mapper statistics management
+.SH SYNOPSIS
+.ad l
+.B dmsetup stats
+.I command
+.RB [ options ]
+.br
+
+.B dmstats <command>
+.RB [[
+.IR device_name ]
+.RB |[ \-\-uuid
+.IR uuid ]
+.RB |[ \-\-major
+.IR major
+.RB \-\-minor
+.IR minor ]]
+.br
+
+.B dmstats clear
+.I device_name
+.RB [ \-\-allregions
+.RB | \-\-regionid
+.IR id ]
+.br
+.B dmstats create
+.I device_name
+.RB [[ \-\-areas
+.IR nr_areas ]
+.RB |[ \-\-areasize
+.IR area_size ]]
+.RB [[ \-\-start
+.IR start_sector ]
+.RB [ \-\-length
+.IR length ]
+.RB |[ \-\-segments ]]
+.RB [ \-\-auxdata
+.IR data ]
+.RB [ \-\-programid
+.IR id ]
+.br
+.B dmstats delete
+.I device_name
+.RB [ \-\-force ]
+.RB [ \-\-allregions
+.RB | \-\-regionid
+.IR id ]
+.RB [ \-\-allprograms
+.RB | \-\-programid
+.IR id ]
+.br
+.B dmstats help
+.RB [ \-c | \-C | \-\-columns ]
+.br
+.B dmstats list
+.RI [ device_name ]
+.RB [ \-\-allprograms
+.RB | \-\-programid
+.IR id ]
+.RB [ \-\-units
+.IR units ]
+.RB [ \-\-nosuffix ]
+.br
+.B dmstats print
+.RI [ device_name ]
+.RB [ \-\-clear ]
+.RB [ \-\-allprograms
+.RB | \-\-programid
+.IR id ]
+.RB [ \-\-allregions
+.RB | \-\-regionid
+.IR id ]
+.br
+.B dmstats report
+.RI [ device_name ]
+.RB [ \-\-interval
+.IR seconds ]
+.RB [ \-\-count
+.IR count ]
+.RB [ \-\-units
+.IR units ]
+.RB [ \-\-allprograms ]
+.RB [ \-\-programid
+.IR id ]
+.RB [ \-\-regionid
+.IR id ]
+.RB [ \-O | \-\-sort
+.IR sort_fields ]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB [ \-\-units
+.IR units ]
+.RB [ \-\-nosuffix ]
+.br
+.ad b
+.SH DESCRIPTION
+The dmstats program manages IO statistics regions for devices that use
+the device-mapper driver. Statistics regions may be created, deleted,
+listed and reported on using the tool.
+
+The first argument to dmstats is a command.
+
+The second argument is the device name, uuid, or major and minor
+numbers.
+
+Further options permit the selection of regions, output format
+control, and reporting behaviour.
+
+When the program is run using the 'dmstats' alias, the command
+\fBmust\fP be the first argument and any switches and options should be
+specified following the command itself. This limitation is not present
+when run as 'dmsetup stats'.
+
+When no device argument is given dmstats will by default operate on all
+device-mapper devices present. The \fBcreate\fP and \fBdelete\fP
+commands require the use of \fB--force\fP when used in this way.
+
+.SH OPTIONS
+.TP
+.B \-\-allprograms
+Include regions from all program IDs for list and report operations.
+.TP
+.B \-\-allregions
+Include all present regions for commands that normally accept a single
+region identifier.
+.TP
+.B \-\-areas \fInr_areas
+Specify the number of statistics areas to create within a new region.
+.TP
+.B \-\-areasize \fIarea_size
+Specify the size of areas into which a new region should be divided. An
+optional suffix selects units of bBsSkKmMgGtTpPeE: (b)ytes,
+(s)ectors, (k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes,
+(p)etabytes, (e)xabytes.  Capitalise to use multiples of 1000 (S.I.)
+instead of 1024.
+.TP
+.B \-\-auxdata \fIaux_data
+Specify auxilliary data (a string) to be stored with a new region.
+.TP
+.B \-\-clear
+When printing statistics counters, also atomically reset them to zero.
+.TP
+.B \-\-count \fIcount
+Specify the iteration count for repeating reports. If the count
+argument is zero reports will continue to repeat until interrupted.
+.TP
+.B \-\-interval \fIseconds
+Specify the interval in seconds between successive iterations for
+repeating reports. If \-\-interval is specified but \-\-count is not,
+reports will continue to repeat until interrupted.
+.TP
+.B \-\-length \fIlength
+Specify the length of a new statistics region in sectors. An optional
+suffix selects units of bBsSkKmMgGtTpPeE: (b)ytes, (s)ectors,
+(k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes, (p)etabytes,
+(e)xabytes.  Capitalise to use multiples of 1000 (S.I.) instead of 1024.
+.TP
+.BR \-j | \-\-major\ \fImajor
+Specify the major number.
+.TP
+.BR \-m | \-\-minor\ \fIminor
+Specify the minor number.
+.TP
+.B \-\-nosuffix
+Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
+(except h and H) if processing the output.
+.TP
+.BR \-o | \-\-options
+Specify which report fields to display.
+.TP
+.BR \-O | \-\-sort\ \fIsort_fields
+Sort output according to the list of fields given. Precede any
+sort_field with - for a reverse sort on that column.
+.TP
+.B \-\-programid \fIid
+Specify a program ID string. When creating new statistics regions this
+string is stored with the region. Subsequent operations may supply a
+program ID in order to select only regions with a matching value. The
+default program ID for dmstats-managed regions is "dmstats".
+.TP
+.BR \-S | \-\-select \ \fIselection
+Display only rows that match selection criteria. All rows with the
+additional "selected" column (-o selected) showing 1 if the row matches
+the selection and 0 otherwise. The selection criteria are defined by
+specifying column names and their valid values while making use of
+supported comparison operators.
+.TP
+.B \-\-start \fIstart
+Specify the start offset of a new statistics region in sectors. An
+optional suffix selects units of bBsSkKmMgGtTpPeE: (b)ytes,
+(s)ectors, (k)ilobytes, (m)egabytes, (g)igabytes, (t)erabytes,
+(p)etabytes, (e)xabytes.  Capitalise to use multiples of 1000 (S.I.)
+instead of 1024.
+.TP
+.B \-\-segments
+Create a new statistics region for each target contained in the target
+device. This causes a separate region to be allocated for each segment
+of the device.
+.TP
+.BR \-\-units \ hHbBsSkKmMgGtTpPeE
+Set the display units for report output. All sizes are output in these
+units: (h)uman-readable, (b)ytes, (s)ectors, (k)ilobytes, (m)egabytes,
+(g)igabytes, (t)erabytes, (p)etabytes, (e)xabytes.  Capitalise to use
+multiples of 1000 (S.I.) instead of 1024.  Can also specify custom units
+e.g. \fB\-\-units 3M\fP
+.TP
+.BR \-u | \-\-uuid
+Specify the uuid.
+.TP
+.BR \-v | \-\-verbose \ [ \-v | \-\-verbose ]
+Produce additional output.
+.br
+.SH COMMANDS
+.TP
+.B clear
+.I device_name
+.RB [ \-\-allregions
+.RB | \-\-regionid
+.IR id ]
+.RB [ \-\-allprograms
+.RB | \-\-programid
+.IR id ]
+.br
+Instructs the kernel to clear statistics counters for the speficied
+regions (with the exception of in-flight IO counters).
+.br
+.TP
+.B create
+.I device_name
+.RB [ \-\-areas
+.IR nr_areas ]
+.RB [ \-\-areasize
+.IR area_size ]
+.RB [[ \-\-start
+.IR start_sector ]
+.RB [ \-\-length
+.IR length ]
+.RB |[ \-\-segments ]]
+.RB [ \-\-auxdata
+.IR data ]
+.RB [ \-\-programid
+.IR id ]
+.br
+Creates one or more new statistics regions on the specified device(s).
+
+The region will span the entire device unless \fB\-\-start\fP and
+\fB\-\-length\fP or \fB\-\-target\fP are given. The \fB\-\-start\fP and
+\fB\-\-length\fP options allow a region of arbitrary length to be placed
+at an arbitrary offset into the device. The \fB\-\-segments\fP option
+causes a new region to be created for each target in the corresponding
+device-mapper device's table.
+
+An optional \fBprogram_id\fP or \fBaux_data\fP string may be associated
+with the region. A \fBprogram_id\fP may then be used to select regions
+for subsequent list, print, and report operations. The \fBaux_data\fP
+stores an arbitrary string and is not used by dmstats or the
+device-mapper kernel statistics subsystem.
+
+By default dmstats creates regions with a \fBprogram_id\fP of
+"DMSTATS1".
+
+On success the \fBregion_id\fP of the newly created region is printed to
+stdout.
+.br
+.TP
+.B delete
+.I [ device_name ]
+.RB [ \-\-force ]
+.RB [ \-\-allregions
+.RB | \-\-regionid
+.IR id ]
+.RB [ \-\-allprograms
+.RB | \-\-programid
+.IR id ]
+.br
+Delete the specified statistics region. All counters and resources used
+by the region are released and the region will not appear in the output
+of subsequent list, print, or report operations.
+
+All regions registered on a device may be removed using
+\fB\-\-allregions\fP.
+
+To remove all regions on all devices \fB\-\-force\fP must be used.
+.br
+.TP
+.B help
+.RB [ \-c | \-C | \-\-columns ]
+.br
+Outputs a summary of the commands available, optionally including
+the list of report fields.
+.br
+.TP
+.B list
+.RI [ device_name ]
+.RB [ \-\-allprograms ]
+.RB [ \-\-programid
+.IR id ]
+.br
+List the statistics regions registered on the device. If the
+\fB\-\-allprograms\fP switch is given all regions will be listed
+regardless of region program ID values.
+.br
+.TP
+.B print
+.RB [ \-\-clear ]
+.IR
+.RB [ \-\-allregions
+.RB | \-\-regionid
+.IR id ]
+.RB [ \-\-allprograms
+.RB | \-\-programid
+.IR id ]
+.br
+Print raw statistics counters for the specified region or for all
+present regions.
+.br
+.TP
+.B report
+.RB [ \-\-allprograms ]
+.RB [ \-\-interval
+.IR seconds ]
+.RB [ \-\-count
+.IR count ]
+.RB [ \-\-units
+.IR unit ]
+.RB [ \-\-regionid
+.IR id ]
+.RB [ \-\-programid
+.IR id ]
+.RB [ \-O | \-\-sort
+.IR sort_fields ]
+.RB [ \-S | \-\-select
+.IR Selection ]
+.RB [ \-\-units
+.IR units ]
+.br
+Start a report for the specified region or for all present regions. If
+the count argument is specified, the report will repeat at a fixed
+interval set by the \fB\-\-interval\fP option. The default interval is
+one second.
+
+If the \fB\-\-allprograms\fP switch is given, all regions will be
+listed, regardless of region program ID values.
+.br
+.SH REGIONS AND AREAS
+The device-mapper statistics facility allows separate performance
+counters to be maintained for arbitrary regions of devices. A region may
+span any range: from a single sector to the whole device. A region may
+be further sub-divided into a number of distinct areas (one or more),
+each with its own counter set.
+
+By default new regions span the entire device. The \fB\-\-start\fP and
+\fB\-\-length\fP options allows a region of any size to be placed at any
+location on the device.
+
+A region may be either divided into the specified number of equal-sized
+areas, or into areas of the given size by specifying one of
+\fB\-\-areas\fP or \fB\-\-areasize\fP when creating a region with the
+\fBcreate\fP command. Depending on the size of the areas and the device
+region the final area within the region may be smaller than requested.
+
+.SS Region identifiers
+Each region is assigned an identifier when it is created that is used to
+reference the region in subsequent operations. Region identifiers are
+unique within a given device (including across different \fBprogram_id\fP
+values).
+.br
+Depending on the sequence of create and delete operations, gaps may
+exist in the sequence of \fBregion_id\fP values for a particular device.
+
+.SH REPORT FIELDS
+The dmstats report provides several types of field that may be added to
+the default field set, or used to create custom reports.
+.br
+All performance counters and metrics are calculated per-area.
+.br
+.SS Derived metrics
+A number of metrics fields are included that provide high level
+performance indicators. These are based on the fields provided by the
+conventional Linux iostat program and are derived from the basic counter
+values provided by the kernel for each area.
+.br
+.HP
+.B rrqm
+.br
+Read requests merged per second.
+.HP
+.B wrqm
+.br
+Write requests merged per second.
+.HP
+.B rs
+.br
+Read requests per second.
+.HP
+.B ws
+.br
+Write requests per second.
+.HP
+.B rsec
+.br
+Sectors read per second.
+.HP
+.B wsec
+.br
+Sectors written per second.
+.HP
+.B arqsz
+.br
+The average size of requests submitted to the area.
+.HP
+.B qusz
+.br
+The average queue length.
+.HP
+.B await
+.br
+The average wait time for read and write requests.
+.HP
+.B r_await
+.br
+The average wait time for read requests.
+.HP
+.B w_await
+.br
+The average wait time for write requests.
+.HP
+.B tput
+.br
+The device throughput in requests per second.
+.HP
+.B svctm
+.br
+The  average  service  time  (in milliseconds) for I/O requests that
+were issued to the device.
+.HP
+.B util
+.br
+Percentage of CPU time during which I/O requests were issued to the
+device (bandwidth utilization for the device). Device saturation occurs
+when this value is close to 100%.
+.br
+.SS Region and area meta fields
+Meta fields provide information about the region or area that the
+statistics values relate to. This includes the region and area
+identifier, start, length, and counts, as well as the program ID and
+auxiliary data values.
+.br
+.HP
+.B region_id
+.br
+Region identifier. This is a non-negative integer returned by the kernel
+when a statistics region is created.
+.HP
+.B region_start
+.br
+.br
+The region start sector in units of 512 byte sectors.
+.HP
+.B region_len
+.br
+The length of the region in units of 512 byte sectors.
+.HP
+.B area_id
+.br
+Area identifier. Area identifiers are assigned by the device-mapper
+statistics library and uniquely identify each area within a region. Each
+ID corresponds to a distinct set of performance counters for that area
+of the statistics region. Area identifiers are always monotonically
+increasing within a region so that higher ID values correspond to
+greater sector addresses within the region and no gaps in the sequence
+of identifiers exist. Sorting a report by device, region start, and area
+ID (the default) will then produce rows in order of ascending region and
+area address.
+.HP
+.B area_start
+.br
+The area start sector in units of 512 byte sectors.
+.HP
+.B area_len
+.br
+The length of the area in units of 512 byte sectors.
+.HP
+.B area_count
+.br
+The number of areas in this region.
+.HP
+.B program_id
+.br
+The program ID value associated with this region.
+.HP
+.B aux_data
+.br
+The auxiliary data value associated with this region.
+.br
+.SS Basic counters
+Basic counters provide access to the raw counter data from the kernel,
+allowing further processing to be carried out by another program.
+
+The kernel provides thirteen separate counters for each statistics
+area. The first eleven of these match the counters provided in
+/proc/diskstats or /sys/block/*/*/stat. The final pair provide separate
+counters for read and write time.
+.P
+.HP
+.B reads
+.br
+The number of reads successfully completed this interval.
+.HP
+.B read_merges
+.br
+The number of read requests merged this interval. This field is
+incremented every time a pair of requests are merged to create a single
+request to be issued to the device.
+.HP
+.B read_sectors
+.br
+The number of 512 byte sectors read this interval.
+.HP
+.B read_nsecs
+.br
+The number of nanoseconds spent reading during this interval.
+.HP
+.B writes
+.br
+The number of writes successfully completed this interval.
+.HP
+.B write_merges
+.br
+The number of write requests merged this interval. This field is
+incremented every time a pair of requests are merged to create a single
+request to be issued to the device.
+.HP
+.B write_sectors
+.br
+The number of 512 byte sectors written this interval.
+.HP
+.B write_nsecs
+.br
+The number of nanoseconds spent writing during this interval.
+.HP
+.B in_progress
+.br
+The number of reads and writes currently in progress.
+.HP
+.B io_nsecs
+.br
+The number of nanoseconds spent reading and writing.
+.HP
+.B weighted_io_nsecs
+.br
+This field is incremented at each I/O start, I/O completion, I/O merge,
+or read of these stats by the number of I/Os in progress multiplied by
+the number of milliseconds spent doing I/O since the last update of this
+field.  This can provide an easy measure of both I/O completion time and
+the backlog that may be accumulating.
+.br
+.br
+.P
+.SH EXAMPLES
+Create a whole-device region with one area on vg00/lvol1
+.br
+.br
+# dmstats create vg00/lvol1
+.br
+Created region: 0
+.br
+.br
+
+
+Create a 32M region 1G into device d0
+.br
+.br
+# dmstats create --start 1G --length 32M d0
+.br
+Created region: 2
+.br
+
+
+Create a whole-device region with 8 areas on every device
+.br
+.br
+# dmstats create --areas 8
+.br
+Created region: 0
+.br
+Created region: 0
+.br
+Created region: 0
+.br
+Created region: 2
+.br
+Created region: 0
+.br
+Created region: 0
+.br
+.br
+
+Delete all regions on all devices
+.br
+.br
+# dmstats delete --allregions --force
+.br
+.br
+
+Create a whole-device region with areas 10GiB in size on vg00/lvol1
+using dmsetup
+.br
+.br
+# dmsetup stats create --areasize 10G vg00/lvol1
+.br
+Created region: 1
+.br
+.br
+
+Create a 1GiB region with 16 areas at the start of vg00/lvol1
+.br
+# dmstats create --start 0 --len 1G --areas=16 vg00/lvol1
+.br
+Created region: 2
+.br
+.br
+
+List the statistics regions registered on vg00/lvol1
+.br
+# dmstats list vg00/lvol1
+.br
+RegionID    RegStart    RegLen  AreaSize ProgramID AuxData
+.br
+0                  0 104857600  20971520 dmstats
+.br
+1                  0 104857600  20971520 dmstats
+.br
+2                  0   2097152    131072 dmstats
+.br
+.br
+
+Display five statistics reports for vg00/lvol1 at an interval of one second
+.br
+.br
+# dmstats report --interval 1 --count 5 vg00/lvol1
+.br
+Name             RgID  ArID  RRqM/s   WRqM/s   R/s    W/s   RSz/s   WSz/s AvRqSz QSize SvcTm Util% AWait
+.br
+vg00-lvol1       0     0     0.00     0.00   8.00  0.00  48.00k     0  6.00k  0.00  5.50  4.40  6.62
+.br
+vg00-lvol1       0     1     0.00     0.00  22.00  0.00 624.00k     0 28.00k  0.00  5.23 11.50  5.36
+.br
+vg00-lvol1       0     2     0.00     0.00 353.00  0.00   1.84m     0  5.00k  0.00  1.34 47.40  1.33
+.br
+vg00-lvol1       0     3     0.00     0.00  73.00  0.00 592.00k     0  8.00k  0.00  2.10 15.30  2.10
+.br
+vg00-lvol1       0     4     0.00     0.00   5.00  0.00  52.00k     0 10.00k  0.00  4.00  2.00  4.00
+.br
+[...]
+.br
+.br
+
+Create one region for reach target contained in device vg00/lvol1
+.br
+.br
+# dmstats create --segments vg00/lvol1
+.br
+Created region: 0
+.br
+Created region: 1
+.br
+Created region: 2
+.br
+.br
+
+Print raw counters for region 4 on device d0
+.br
+.br
+# dmstats print --regionid 4 d0
+.br
+2097152+65536 0 0 0 0 29 0 264 701 0 41 701 0 41
+.br
+.br
+.SH AUTHORS
+Bryn M. Reeves <bmr@redhat.com>
+
+.SH SEE ALSO
+LVM2 resource page https://www.sourceware.org/lvm2/
+.br
+Device-mapper resource page: http://sources.redhat.com/dm/
+.br
+
+Device-mapper statistics kernel documentation
+.br
+   Documentation/device-mapper/statistics.txt
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 12e6fa9..de67b03 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -102,6 +102,9 @@ extern char *optarg;
 
 #define err(msg, x...) fprintf(stderr, msg "\n", ##x)
 
+/* program_id used for dmstats-managed statistics regions */
+#define DM_STATS_PROGRAM_ID "dmstats"
+
 /*
  * We have only very simple switches ATM.
  */
@@ -109,7 +112,13 @@ enum {
 	READ_ONLY = 0,
 	ADD_NODE_ON_CREATE_ARG,
 	ADD_NODE_ON_RESUME_ARG,
+	ALL_PROGRAMS_ARG,
+	ALL_REGIONS_ARG,
+	AREAS_ARG,
+	AREA_SIZE_ARG,
+	AUX_DATA_ARG,
 	CHECKS_ARG,
+	CLEAR_ARG,
 	COLS_ARG,
 	COUNT_ARG,
 	DEFERRED_ARG,
@@ -120,6 +129,7 @@ enum {
 	HELP_ARG,
 	INACTIVE_ARG,
 	INTERVAL_ARG,
+	LENGTH_ARG,
 	MANGLENAME_ARG,
 	MAJOR_ARG,
 	MINOR_ARG,
@@ -129,23 +139,29 @@ enum {
 	NOHEADINGS_ARG,
 	NOLOCKFS_ARG,
 	NOOPENCOUNT_ARG,
+	NOSUFFIX_ARG,
 	NOTABLE_ARG,
 	UDEVCOOKIE_ARG,
 	NOUDEVRULES_ARG,
 	NOUDEVSYNC_ARG,
 	OPTIONS_ARG,
+	PROGRAM_ID_ARG,
 	READAHEAD_ARG,
+	REGION_ID_ARG,
 	RETRY_ARG,
 	ROWS_ARG,
 	SEPARATOR_ARG,
 	SETUUID_ARG,
 	SHOWKEYS_ARG,
 	SORT_ARG,
+	START_ARG,
 	TABLE_ARG,
 	TARGET_ARG,
+	SEGMENTS_ARG,
 	TREE_ARG,
 	UID_ARG,
 	UNBUFFERED_ARG,
+	UNITS_ARG,
 	UNQUOTED_ARG,
 	UUID_ARG,
 	VERBOSE_ARG,
@@ -160,7 +176,8 @@ typedef enum {
 	DR_INFO = 2,
 	DR_DEPS = 4,
 	DR_TREE = 8,	/* Complete dependency tree required */
-	DR_NAME = 16
+	DR_NAME = 16,
+	DR_STATS = 32,
 } report_type_t;
 
 typedef enum {
@@ -186,6 +203,11 @@ static report_type_t _report_type;
 static dev_name_t _dev_name_type;
 static uint32_t _count = 1; /* count of repeating reports */
 static struct dm_timestamp *_initial_timestamp = NULL;
+static int _stats_report_init = 0;
+static uint64_t _disp_factor = 512; /* display sizes in sectors */
+static char _disp_units = 's';
+
+/* report timekeeping */
 static struct dm_timestamp *_ts_start = NULL, *_ts_end = NULL;
 static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
 static uint64_t _interval = 0; /* configured interval in nsecs */
@@ -311,6 +333,7 @@ struct dmsetup_report_obj {
 	struct dm_task *deps_task;
 	struct dm_tree_node *tree_node;
 	struct dm_split_name *split_name;
+	struct dm_stats *stats;
 };
 
 static int _task_run(struct dm_task *dmt)
@@ -447,6 +470,7 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 	obj.info = info;
 	obj.deps_task = NULL;
 	obj.split_name = NULL;
+	obj.stats = NULL;
 
 	if (_report_type & DR_TREE)
 		if (!(obj.tree_node = dm_tree_find_node(_dtree, info->major, info->minor))) {
@@ -465,9 +489,35 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 						       dm_task_get_name(dmt), '-')))
 			goto_out;
 
-	if (!dm_report_object(_report, &obj))
-		goto_out;
+	/*
+	 * Obtain statistics for the current reporting object and set
+	 * the interval estimate used for stats rate conversion.
+	 */
+	if (_report_type & DR_STATS) {
+		if (!(obj.stats = dm_stats_create(DM_STATS_PROGRAM_ID)))
+			goto_out;
+
+		/* FIXME: use a single timestamp to measure _last_interval. */
+		dm_stats_set_sampling_interval_ns(obj.stats, _last_interval);
+
+		dm_stats_bind_devno(obj.stats, info->major, info->minor);
+		if (!(dm_stats_populate(obj.stats, DM_STATS_PROGRAM_ID, DM_STATS_REGIONS_ALL))) {
+			goto out;
+		}
+	}
 
+	/*
+	 * Walk any statistics regions contained in the current
+	 * reporting object: for objects with a NULL stats handle,
+	 * or a handle containing no registered regions, this loop
+	 * always executes exactly once.
+	 */
+	dm_stats_walk_do(obj.stats) {
+		if (!dm_report_object(_report, &obj))
+			goto_out;
+		/* report walk is always by area */
+		dm_stats_walk_next(obj.stats);
+	} dm_stats_walk_while(obj.stats);
 	r = 1;
 
       out:
@@ -475,6 +525,8 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 		dm_task_destroy(obj.deps_task);
 	if (obj.split_name)
 		_destroy_split_name(obj.split_name);
+	if (obj.stats)
+		dm_stats_destroy(obj.stats);
 	return r;
 }
 
@@ -1279,6 +1331,12 @@ static int _version(CMD_ARGS)
 
 	printf("Driver version:    %s\n", version);
 
+	/* don't output column headings for 'dmstats version'. */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
 	return 1;
 }
 
@@ -2311,6 +2369,15 @@ static int _uint32_disp(struct dm_report *rh,
 	return dm_report_field_uint32(rh, field, &value);
 }
 
+static int _show_units(void)
+{
+	/* --nosuffix overrides --units */
+	if (_switches[NOSUFFIX_ARG])
+		return 0;
+
+	return (_int_args[UNITS_ARG]) ? 1 : 0;
+}
+
 static int _dm_name_disp(struct dm_report *rh,
 			 struct dm_pool *mem __attribute__((unused)),
 			 struct dm_report_field *field, const void *data,
@@ -2772,336 +2839,1644 @@ static int _dm_lv_layer_name_disp(struct dm_report *rh,
 	return dm_report_field_string(rh, field, (const char *const *) data);
 }
 
-static void *_task_get_obj(void *obj)
-{
-	return ((struct dmsetup_report_obj *)obj)->task;
+/**
+ * All _dm_stats_*_disp functions for basic counters are identical:
+ * obtain the value for the current region and area and pass it to
+ * dm_report_field_uint64().
+ */
+#define MK_STATS_COUNTER_DISP_FN(counter)					  \
+static int _dm_stats_ ## counter ## _disp(struct dm_report *rh,			  \
+				 struct dm_pool *mem __attribute__((unused)),	  \
+				 struct dm_report_field *field, const void *data, \
+				 void *private __attribute__((unused)))		  \
+{										  \
+	const struct dm_stats *dms = (const struct dm_stats *) data;		  \
+	uint64_t value = dm_stats_get_ ## counter(dms, DM_STATS_REGION_CURRENT,   \
+						  DM_STATS_AREA_CURRENT);         \
+	return dm_report_field_uint64(rh, field, &value);			  \
 }
 
-static void *_info_get_obj(void *obj)
+MK_STATS_COUNTER_DISP_FN(reads)
+MK_STATS_COUNTER_DISP_FN(reads_merged)
+MK_STATS_COUNTER_DISP_FN(read_sectors)
+MK_STATS_COUNTER_DISP_FN(read_nsecs)
+MK_STATS_COUNTER_DISP_FN(writes)
+MK_STATS_COUNTER_DISP_FN(writes_merged)
+MK_STATS_COUNTER_DISP_FN(write_sectors)
+MK_STATS_COUNTER_DISP_FN(write_nsecs)
+MK_STATS_COUNTER_DISP_FN(io_in_progress)
+MK_STATS_COUNTER_DISP_FN(io_nsecs)
+MK_STATS_COUNTER_DISP_FN(weighted_io_nsecs)
+MK_STATS_COUNTER_DISP_FN(total_read_nsecs)
+MK_STATS_COUNTER_DISP_FN(total_write_nsecs)
+#undef MK_STATS_COUNTER_DISP_FN
+
+static int _dm_stats_region_id_disp(struct dm_report *rh,
+				    struct dm_pool *mem __attribute__((unused)),
+				    struct dm_report_field *field, const void *data,
+				    void *private __attribute__((unused)))
 {
-	return ((struct dmsetup_report_obj *)obj)->info;
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	uint64_t region_id = dm_stats_get_current_region(dms);
+	return dm_report_field_uint64(rh, field, &region_id);
 }
 
-static void *_deps_get_obj(void *obj)
+static int _dm_stats_region_start_disp(struct dm_report *rh,
+				       struct dm_pool *mem __attribute__((unused)),
+				       struct dm_report_field *field, const void *data,
+				       void *private __attribute__((unused)))
 {
-	return dm_task_get_deps(((struct dmsetup_report_obj *)obj)->deps_task);
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	uint64_t region_start;
+	const char *repstr;
+	double *sortval;
+	char units = _disp_units;
+	uint64_t factor = _disp_factor;
+
+	if (!dm_stats_get_current_region_start(dms, &region_start))
+		return_0;
+
+	if (!(repstr = dm_size_to_string(mem, region_start, units, 1, factor,
+					 _show_units(), DM_SIZE_UNIT)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = (double) region_start;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
 }
 
-static void *_tree_get_obj(void *obj)
+static int _dm_stats_region_len_disp(struct dm_report *rh,
+					struct dm_pool *mem __attribute__((unused)),
+					struct dm_report_field *field, const void *data,
+					void *private __attribute__((unused)))
 {
-	return ((struct dmsetup_report_obj *)obj)->tree_node;
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	uint64_t region_length;
+	const char *repstr;
+	double *sortval;
+	char units = _disp_units;
+	uint64_t factor = _disp_factor;
+
+	if (!dm_stats_get_current_region_len(dms, &region_length))
+		return_0;
+
+	if (!(repstr = dm_size_to_string(mem, region_length, units, 1, factor,
+					 _show_units(), DM_SIZE_UNIT)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = (double) region_length;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
 }
 
-static void *_split_name_get_obj(void *obj)
+static int _dm_stats_area_id_disp(struct dm_report *rh,
+				  struct dm_pool *mem __attribute__((unused)),
+				  struct dm_report_field *field, const void *data,
+				  void *private __attribute__((unused)))
 {
-	return ((struct dmsetup_report_obj *)obj)->split_name;
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	uint64_t area_id = dm_stats_get_current_area(dms);
+	return dm_report_field_uint64(rh, field, &area_id);
 }
 
-static const struct dm_report_object_type _report_types[] = {
-	{ DR_TASK, "Mapped Device Name", "", _task_get_obj },
-	{ DR_INFO, "Mapped Device Information", "", _info_get_obj },
-	{ DR_DEPS, "Mapped Device Relationship Information", "", _deps_get_obj },
-	{ DR_TREE, "Mapped Device Relationship Information", "", _tree_get_obj },
-	{ DR_NAME, "Mapped Device Name Components", "", _split_name_get_obj },
-	{ 0, "", "", NULL },
-};
+static int _dm_stats_area_start_disp(struct dm_report *rh,
+				     struct dm_pool *mem __attribute__((unused)),
+				     struct dm_report_field *field, const void *data,
+				     void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	uint64_t area_start;
+	const char *repstr;
+	double *sortval;
+	char units = _disp_units;
+	uint64_t factor = _disp_factor;
+
+	if (!dm_stats_get_current_area_start(dms, &area_start))
+		return_0;
 
-/* Column definitions */
-#define OFFSET_OF(strct, field) (((char*)&((struct strct*)0)->field) - (char*)0)
-#define STR (DM_REPORT_FIELD_TYPE_STRING)
-#define NUM (DM_REPORT_FIELD_TYPE_NUMBER)
-#define SIZ (DM_REPORT_FIELD_TYPE_SIZE)
-#define FIELD_O(type, strct, sorttype, head, field, width, func, id, desc) {DR_ ## type, sorttype, OFFSET_OF(strct, field), width, id, head, &_ ## func ## _disp, desc},
-#define FIELD_F(type, sorttype, head, width, func, id, desc) {DR_ ## type, sorttype, 0, width, id, head, &_ ## func ## _disp, desc},
+	if (!(repstr = dm_size_to_string(mem, area_start, units, 1, factor,
+					 _show_units(), DM_SIZE_UNIT)))
+		return_0;
 
-static const struct dm_report_field_type _report_fields[] = {
-/* *INDENT-OFF* */
-FIELD_F(TASK, STR, "Name", 16, dm_name, "name", "Name of mapped device.")
-FIELD_F(TASK, STR, "MangledName", 16, dm_mangled_name, "mangled_name", "Mangled name of mapped device.")
-FIELD_F(TASK, STR, "UnmangledName", 16, dm_unmangled_name, "unmangled_name", "Unmangled name of mapped device.")
-FIELD_F(TASK, STR, "UUID", 32, dm_uuid, "uuid", "Unique (optional) identifier for mapped device.")
-FIELD_F(TASK, STR, "MangledUUID", 32, dm_mangled_uuid, "mangled_uuid", "Mangled unique (optional) identifier for mapped device.")
-FIELD_F(TASK, STR, "UnmangledUUID", 32, dm_unmangled_uuid, "unmangled_uuid", "Unmangled unique (optional) identifier for mapped device.")
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
 
-/* FIXME Next one should be INFO */
-FIELD_F(TASK, NUM, "RAhead", 6, dm_read_ahead, "read_ahead", "Read ahead in sectors.")
+	*sortval = (double) area_start;
 
-FIELD_F(INFO, STR, "BlkDevName", 16, dm_blk_name, "blkdevname", "Name of block device.")
-FIELD_F(INFO, STR, "Stat", 4, dm_info_status, "attr", "(L)ive, (I)nactive, (s)uspended, (r)ead-only, read-(w)rite.")
-FIELD_F(INFO, STR, "Tables", 6, dm_info_table_loaded, "tables_loaded", "Which of the live and inactive table slots are filled.")
-FIELD_F(INFO, STR, "Suspended", 9, dm_info_suspended, "suspended", "Whether the device is suspended.")
-FIELD_F(INFO, STR, "Read-only", 9, dm_info_read_only, "readonly", "Whether the device is read-only or writeable.")
-FIELD_F(INFO, STR, "DevNo", 5, dm_info_devno, "devno", "Device major and minor numbers")
-FIELD_O(INFO, dm_info, NUM, "Maj", major, 3, int32, "major", "Block device major number.")
-FIELD_O(INFO, dm_info, NUM, "Min", minor, 3, int32, "minor", "Block device minor number.")
-FIELD_O(INFO, dm_info, NUM, "Open", open_count, 4, int32, "open", "Number of references to open device, if requested.")
-FIELD_O(INFO, dm_info, NUM, "Targ", target_count, 4, int32, "segments", "Number of segments in live table, if present.")
-FIELD_O(INFO, dm_info, NUM, "Event", event_nr, 6, uint32, "events", "Number of most recent event.")
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
 
-FIELD_O(DEPS, dm_deps, NUM, "#Devs", count, 5, int32, "device_count", "Number of devices used by this one.")
-FIELD_F(TREE, STR, "DevNamesUsed", 16, dm_deps_names, "devs_used", "List of names of mapped devices used by this one.")
-FIELD_F(DEPS, STR, "DevNosUsed", 16, dm_deps, "devnos_used", "List of device numbers of devices used by this one.")
-FIELD_F(DEPS, STR, "BlkDevNamesUsed", 16, dm_deps_blk_names, "blkdevs_used", "List of names of block devices used by this one.")
+static int _dm_stats_area_len_disp(struct dm_report *rh,
+				      struct dm_pool *mem __attribute__((unused)),
+				      struct dm_report_field *field, const void *data,
+				      void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	uint64_t area_len;
+	const char *repstr;
+	double *sortval;
+	char units = _disp_units;
+	uint64_t factor = _disp_factor;
+
+	if (!dm_stats_get_current_area_len(dms, &area_len))
+		return_0;
 
-FIELD_F(TREE, NUM, "#Refs", 5, dm_tree_parents_count, "device_ref_count", "Number of mapped devices referencing this one.")
-FIELD_F(TREE, STR, "RefNames", 8, dm_tree_parents_names, "names_using_dev", "List of names of mapped devices using this one.")
-FIELD_F(TREE, STR, "RefDevNos", 9, dm_tree_parents_devs, "devnos_using_dev", "List of device numbers of mapped devices using this one.")
+	if (!(repstr = dm_size_to_string(mem, area_len, units, 1, factor,
+					 _show_units(), DM_SIZE_UNIT)))
+		return_0;
 
-FIELD_O(NAME, dm_split_name, STR, "Subsys", subsystem, 6, dm_subsystem, "subsystem", "Userspace subsystem responsible for this device.")
-FIELD_O(NAME, dm_split_name, STR, "VG", vg_name, 4, dm_vg_name, "vg_name", "LVM Volume Group name.")
-FIELD_O(NAME, dm_split_name, STR, "LV", lv_name, 4, dm_lv_name, "lv_name", "LVM Logical Volume name.")
-FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 7, dm_lv_layer_name, "lv_layer", "LVM device layer.")
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
 
-{0, 0, 0, 0, "", "", NULL, NULL},
-/* *INDENT-ON* */
-};
+	*sortval = (double) area_len;
 
-#undef STR
-#undef NUM
-#undef SIZ
-#undef FIELD_O
-#undef FIELD_F
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
 
-static const char *default_report_options = "name,major,minor,attr,open,segments,events,uuid";
-static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
+static int _dm_stats_area_count_disp(struct dm_report *rh,
+				     struct dm_pool *mem __attribute__((unused)),
+				     struct dm_report_field *field, const void *data,
+				     void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	uint64_t area_count, region;
 
-static int _report_init(const struct command *cmd)
+	region = dm_stats_get_current_region(dms);
+	if (!(area_count = dm_stats_get_region_nr_areas(dms, region)))
+		return_0;
+
+	return dm_report_field_uint64(rh, field, &area_count);
+}
+
+static int _dm_stats_program_id_disp(struct dm_report *rh,
+				     struct dm_pool *mem __attribute__((unused)),
+				     struct dm_report_field *field, const void *data,
+				     void *private __attribute__((unused)))
 {
-	char *options = (char *) default_report_options;
-	const char *keys = "";
-	const char *separator = " ";
-	const char *selection = NULL;
-	int aligned = 1, headings = 1, buffered = 1, field_prefixes = 0;
-	int quoted = 1, columns_as_rows = 0;
-	uint32_t flags = 0;
-	size_t len = 0;
-	int r = 0;
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	const char *program_id;
+	if (!(program_id = dm_stats_get_current_region_program_id(dms)))
+		return_0;
+	return dm_report_field_string(rh, field, (const char * const*) &program_id);
+}
 
-	if (cmd && !strcmp(cmd->name, "splitname"))
-		options = (char *) splitname_report_options;
+static int _dm_stats_aux_data_disp(struct dm_report *rh,
+				     struct dm_pool *mem __attribute__((unused)),
+				     struct dm_report_field *field, const void *data,
+				     void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	const char *aux_data;
+	if (!(aux_data = dm_stats_get_current_region_aux_data(dms)))
+		return_0;
+	return dm_report_field_string(rh, field, (const char * const*) &aux_data);
+}
 
-	/* emulate old dmsetup behaviour */
-	if (_switches[NOHEADINGS_ARG]) {
-		separator = ":";
-		aligned = 0;
-		headings = 0;
-	}
+static int _dm_stats_rrqm_disp(struct dm_report *rh,
+			       struct dm_pool *mem __attribute__((unused)),
+			       struct dm_report_field *field, const void *data,
+			       void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, rrqm;
 
-	if (_switches[UNBUFFERED_ARG])
-		buffered = 0;
+	if (!dm_stats_get_rd_merges_per_sec(dms, &rrqm,
+					    DM_STATS_REGION_CURRENT,
+					    DM_STATS_AREA_CURRENT))
+		return_0;
 
-	if (_switches[ROWS_ARG])
-		columns_as_rows = 1;
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", rrqm))
+		return_0;
 
-	if (_switches[UNQUOTED_ARG])
-		quoted = 0;
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
 
-	if (_switches[NAMEPREFIXES_ARG]) {
-		aligned = 0;
-		field_prefixes = 1;
-	}
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
 
-	if (_switches[OPTIONS_ARG] && _string_args[OPTIONS_ARG]) {
-		if (*_string_args[OPTIONS_ARG] != '+')
-			options = _string_args[OPTIONS_ARG];
-		else {
-			len = strlen(default_report_options) +
-			      strlen(_string_args[OPTIONS_ARG]) + 1;
-			if (!(options = dm_malloc(len))) {
-				err("Failed to allocate option string.");
-				return 0;
-			}
-			if (dm_snprintf(options, len, "%s,%s",
-					default_report_options,
-					&_string_args[OPTIONS_ARG][1]) < 0) {
-				err("snprintf failed");
-				goto out;
-			}
-		}
-	}
+	*sortval = rrqm;
 
-	if (_switches[SORT_ARG] && _string_args[SORT_ARG]) {
-		keys = _string_args[SORT_ARG];
-		buffered = 1;
-		if (cmd && (!strcmp(cmd->name, "status") || !strcmp(cmd->name, "table"))) {
-			err("--sort is not yet supported with status and table");
-			goto out;
-		}
-	}
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
 
-	if (_switches[SEPARATOR_ARG] && _string_args[SEPARATOR_ARG]) {
-		separator = _string_args[SEPARATOR_ARG];
-		aligned = 0;
-	}
+}
 
-	if (_switches[SELECT_ARG] && _string_args[SELECT_ARG])
-		selection = _string_args[SELECT_ARG];
+static int _dm_stats_wrqm_disp(struct dm_report *rh,
+			       struct dm_pool *mem __attribute__((unused)),
+			       struct dm_report_field *field, const void *data,
+			       void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, wrqm;
 
-	if (aligned)
-		flags |= DM_REPORT_OUTPUT_ALIGNED;
+	if (!dm_stats_get_wr_merges_per_sec(dms, &wrqm,
+					    DM_STATS_REGION_CURRENT,
+					    DM_STATS_AREA_CURRENT))
+		return_0;
 
-	if (buffered)
-		flags |= DM_REPORT_OUTPUT_BUFFERED;
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", wrqm))
+		return_0;
 
-	if (headings)
-		flags |= DM_REPORT_OUTPUT_HEADINGS;
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
 
-	if (field_prefixes)
-		flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
 
-	if (!quoted)
-		flags |= DM_REPORT_OUTPUT_FIELD_UNQUOTED;
+	*sortval = wrqm;
 
-	if (columns_as_rows)
-		flags |= DM_REPORT_OUTPUT_COLUMNS_AS_ROWS;
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
 
-	if (!(_report = dm_report_init_with_selection(&_report_type, _report_types,
-				_report_fields, options, separator, flags, keys,
-				selection, NULL, NULL)))
-		goto out;
+}
 
-	if ((_report_type & DR_TREE) && !_build_whole_deptree(cmd)) {
-		err("Internal device dependency tree creation failed.");
-		goto out;
-	}
+static int _dm_stats_rs_disp(struct dm_report *rh,
+			       struct dm_pool *mem __attribute__((unused)),
+			       struct dm_report_field *field, const void *data,
+			       void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, rs;
 
-	if (!_switches[INTERVAL_ARG])
-		_int_args[INTERVAL_ARG] = 1; /* 1s default. */
+	if (!dm_stats_get_reads_per_sec(dms, &rs,
+					DM_STATS_REGION_CURRENT,
+					DM_STATS_AREA_CURRENT))
+		return_0;
 
-	_interval = NSEC_PER_SEC * _int_args[INTERVAL_ARG];
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", rs))
+		return_0;
 
-	if (field_prefixes)
-		dm_report_set_output_field_name_prefix(_report, "dm_");
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
 
-	r = 1;
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
 
-out:
-	if (len)
-		dm_free(options);
+	*sortval = rs;
 
-	return r;
-}
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
 
-/*
- * List devices
- */
-static int _ls(CMD_ARGS)
-{
-	if ((_switches[TARGET_ARG] && _target) ||
-	    (_switches[EXEC_ARG] && _command))
-		return _status(cmd, NULL, argc, argv, NULL, 0);
-	else if ((_switches[TREE_ARG]))
-		return _display_tree(cmd, NULL, 0, NULL, NULL, 0);
-	else
-		return _process_all(cmd, NULL, argc, argv, 0, _display_name);
 }
 
-static int _mangle(CMD_ARGS)
+static int _dm_stats_ws_disp(struct dm_report *rh,
+			     struct dm_pool *mem __attribute__((unused)),
+			     struct dm_report_field *field, const void *data,
+			     void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, ws;
+
+	if (!dm_stats_get_writes_per_sec(dms, &ws,
+					 DM_STATS_REGION_CURRENT,
+					 DM_STATS_AREA_CURRENT))
+		return_0;
+
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", ws))
+		return_0;
+
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = ws;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+
+}
+
+static int _dm_stats_read_secs_disp(struct dm_report *rh,
+				    struct dm_pool *mem __attribute__((unused)),
+				    struct dm_report_field *field, const void *data,
+				    void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	const char *repstr;
+	double *sortval, rsec;
+	char units = _disp_units;
+	uint64_t factor = _disp_factor;
+
+	if (!dm_stats_get_read_sectors_per_sec(dms, &rsec,
+					       DM_STATS_REGION_CURRENT,
+					       DM_STATS_AREA_CURRENT))
+		return_0;
+
+	if (!(repstr = dm_size_to_string(mem, (uint64_t) rsec, units, 1,
+					 factor, _show_units(), DM_SIZE_UNIT)))
+
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = rsec;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
+static int _dm_stats_write_secs_disp(struct dm_report *rh,
+				     struct dm_pool *mem __attribute__((unused)),
+				     struct dm_report_field *field, const void *data,
+				     void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	const char *repstr;
+	double *sortval, wsec;
+	char units = _disp_units;
+	uint64_t factor = _disp_factor;
+
+	if (!dm_stats_get_write_sectors_per_sec(dms, &wsec,
+						DM_STATS_REGION_CURRENT,
+						DM_STATS_AREA_CURRENT))
+		return_0;
+
+	if (!(repstr = dm_size_to_string(mem, (uint64_t) wsec, units, 1,
+					 factor, _show_units(), DM_SIZE_UNIT)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = wsec;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
+static int _dm_stats_arqsz_disp(struct dm_report *rh,
+				struct dm_pool *mem __attribute__((unused)),
+				struct dm_report_field *field, const void *data,
+				void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	const char *repstr;
+	double *sortval, arqsz;
+	char units = _disp_units;
+	uint64_t factor = _disp_factor;
+
+	if (!dm_stats_get_average_request_size(dms, &arqsz,
+					       DM_STATS_REGION_CURRENT,
+					       DM_STATS_AREA_CURRENT))
+		return_0;
+
+
+	if (!(repstr = dm_size_to_string(mem, (uint64_t) arqsz, units, 1,
+					 factor, _show_units(), DM_SIZE_UNIT)))
+
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = arqsz;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
+static int _dm_stats_qusz_disp(struct dm_report *rh,
+			       struct dm_pool *mem __attribute__((unused)),
+			       struct dm_report_field *field, const void *data,
+			       void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, qusz;
+
+	if (!dm_stats_get_average_queue_size(dms, &qusz,
+					     DM_STATS_REGION_CURRENT,
+					     DM_STATS_AREA_CURRENT))
+		return_0;
+
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", qusz))
+		return_0;
+
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = qusz;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
+static int _dm_stats_await_disp(struct dm_report *rh,
+				struct dm_pool *mem __attribute__((unused)),
+				struct dm_report_field *field, const void *data,
+				void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, await;
+
+	if (!dm_stats_get_average_wait_time(dms, &await,
+					    DM_STATS_REGION_CURRENT,
+					    DM_STATS_AREA_CURRENT))
+		return_0;
+
+	/* FIXME: make scale configurable */
+	/* display in msecs */
+	await /= NSEC_PER_MSEC;
+
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", await))
+		return_0;
+
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = await;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
+static int _dm_stats_r_await_disp(struct dm_report *rh,
+				  struct dm_pool *mem __attribute__((unused)),
+				  struct dm_report_field *field, const void *data,
+				  void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, r_await;
+
+	if (!dm_stats_get_average_rd_wait_time(dms, &r_await,
+					       DM_STATS_REGION_CURRENT,
+					       DM_STATS_AREA_CURRENT))
+		return_0;
+
+	/* FIXME: make scale configurable */
+	/* display in msecs */
+	r_await /= NSEC_PER_MSEC;
+
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", r_await))
+		return_0;
+
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = r_await;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
+static int _dm_stats_w_await_disp(struct dm_report *rh,
+				  struct dm_pool *mem __attribute__((unused)),
+				  struct dm_report_field *field, const void *data,
+				  void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, w_await;
+
+	if (!dm_stats_get_average_wr_wait_time(dms, &w_await,
+					       DM_STATS_REGION_CURRENT,
+					       DM_STATS_AREA_CURRENT))
+		return_0;
+
+	/* FIXME: make scale configurable */
+	/* display in msecs */
+	w_await /= NSEC_PER_MSEC;
+
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", w_await))
+		return_0;
+
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = w_await;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
+static int _dm_stats_tput_disp(struct dm_report *rh,
+			       struct dm_pool *mem __attribute__((unused)),
+			       struct dm_report_field *field, const void *data,
+			       void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, tput;
+
+	if (!dm_stats_get_throughput(dms, &tput,
+				     DM_STATS_REGION_CURRENT,
+				     DM_STATS_AREA_CURRENT))
+		return_0;
+
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", tput))
+		return_0;
+
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = tput;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+}
+
+static int _dm_stats_svctm_disp(struct dm_report *rh,
+				struct dm_pool *mem __attribute__((unused)),
+				struct dm_report_field *field, const void *data,
+				void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	char buf[64];
+	char *repstr;
+	double *sortval, svctm;
+
+	if (!dm_stats_get_service_time(dms, &svctm,
+				       DM_STATS_REGION_CURRENT,
+				       DM_STATS_AREA_CURRENT))
+		return_0;
+
+	/* FIXME: make scale configurable */
+	/* display in msecs */
+	svctm /= NSEC_PER_MSEC;
+
+	if (!dm_snprintf(buf, sizeof(buf), "%.2f", svctm))
+		return_0;
+
+	if (!(repstr = dm_pool_strdup(mem, buf)))
+		return_0;
+
+	if (!(sortval = dm_pool_alloc(mem, sizeof(uint64_t))))
+		return_0;
+
+	*sortval = svctm;
+
+	dm_report_field_set_value(field, repstr, sortval);
+	return 1;
+
+}
+
+static int _dm_stats_util_disp(struct dm_report *rh,
+			       struct dm_pool *mem __attribute__((unused)),
+			       struct dm_report_field *field, const void *data,
+			       void *private __attribute__((unused)))
+{
+	const struct dm_stats *dms = (const struct dm_stats *) data;
+	dm_percent_t util;
+
+	if (!dm_stats_get_utilization(dms, &util,
+				      DM_STATS_REGION_CURRENT,
+				      DM_STATS_AREA_CURRENT))
+		return_0;
+
+	dm_report_field_percent(rh, field, &util);
+	return 1;
+}
+
+static void *_task_get_obj(void *obj)
+{
+	return ((struct dmsetup_report_obj *)obj)->task;
+}
+
+static void *_info_get_obj(void *obj)
+{
+	return ((struct dmsetup_report_obj *)obj)->info;
+}
+
+static void *_deps_get_obj(void *obj)
+{
+	return dm_task_get_deps(((struct dmsetup_report_obj *)obj)->deps_task);
+}
+
+static void *_tree_get_obj(void *obj)
+{
+	return ((struct dmsetup_report_obj *)obj)->tree_node;
+}
+
+static void *_split_name_get_obj(void *obj)
+{
+	return ((struct dmsetup_report_obj *)obj)->split_name;
+}
+
+static void *_stats_get_obj(void *obj)
+{
+	return ((struct dmsetup_report_obj *)obj)->stats;
+}
+
+static const struct dm_report_object_type _report_types[] = {
+	{ DR_TASK, "Mapped Device Name", "", _task_get_obj },
+	{ DR_INFO, "Mapped Device Information", "", _info_get_obj },
+	{ DR_DEPS, "Mapped Device Relationship Information", "", _deps_get_obj },
+	{ DR_TREE, "Mapped Device Relationship Information", "", _tree_get_obj },
+	{ DR_NAME, "Mapped Device Name Components", "", _split_name_get_obj },
+	{ DR_STATS, "Mapped Device Statistics","", _stats_get_obj },
+	{ 0, "", "", NULL }
+};
+
+/* Column definitions */
+/* N.B. Field names must not contain the substring 'help' as this will disable --count. */
+#define OFFSET_OF(strct, field) (((char*)&((struct strct*)0)->field) - (char*)0)
+#define STR (DM_REPORT_FIELD_TYPE_STRING)
+#define NUM (DM_REPORT_FIELD_TYPE_NUMBER)
+#define SIZ (DM_REPORT_FIELD_TYPE_SIZE)
+#define TIM (DM_REPORT_FIELD_TYPE_TIME)
+#define FIELD_O(type, strct, sorttype, head, field, width, func, id, desc) {DR_ ## type, sorttype, OFFSET_OF(strct, field), width, id, head, &_ ## func ## _disp, desc},
+#define FIELD_F(type, sorttype, head, width, func, id, desc) {DR_ ## type, sorttype, 0, width, id, head, &_ ## func ## _disp, desc},
+
+static const struct dm_report_field_type _report_fields[] = {
+/* *INDENT-OFF* */
+FIELD_F(TASK, STR, "Name", 16, dm_name, "name", "Name of mapped device.")
+FIELD_F(TASK, STR, "MangledName", 16, dm_mangled_name, "mangled_name", "Mangled name of mapped device.")
+FIELD_F(TASK, STR, "UnmangledName", 16, dm_unmangled_name, "unmangled_name", "Unmangled name of mapped device.")
+FIELD_F(TASK, STR, "UUID", 32, dm_uuid, "uuid", "Unique (optional) identifier for mapped device.")
+FIELD_F(TASK, STR, "MangledUUID", 32, dm_mangled_uuid, "mangled_uuid", "Mangled unique (optional) identifier for mapped device.")
+FIELD_F(TASK, STR, "UnmangledUUID", 32, dm_unmangled_uuid, "unmangled_uuid", "Unmangled unique (optional) identifier for mapped device.")
+
+/* FIXME Next one should be INFO */
+FIELD_F(TASK, NUM, "RAhead", 6, dm_read_ahead, "read_ahead", "Read ahead value.")
+
+FIELD_F(INFO, STR, "BlkDevName", 16, dm_blk_name, "blkdevname", "Name of block device.")
+FIELD_F(INFO, STR, "Stat", 4, dm_info_status, "attr", "(L)ive, (I)nactive, (s)uspended, (r)ead-only, read-(w)rite.")
+FIELD_F(INFO, STR, "Tables", 6, dm_info_table_loaded, "tables_loaded", "Which of the live and inactive table slots are filled.")
+FIELD_F(INFO, STR, "Suspended", 9, dm_info_suspended, "suspended", "Whether the device is suspended.")
+FIELD_F(INFO, STR, "Read-only", 9, dm_info_read_only, "readonly", "Whether the device is read-only or writeable.")
+FIELD_F(INFO, STR, "DevNo", 5, dm_info_devno, "devno", "Device major and minor numbers")
+FIELD_O(INFO, dm_info, NUM, "Maj", major, 3, int32, "major", "Block device major number.")
+FIELD_O(INFO, dm_info, NUM, "Min", minor, 3, int32, "minor", "Block device minor number.")
+FIELD_O(INFO, dm_info, NUM, "Open", open_count, 4, int32, "open", "Number of references to open device, if requested.")
+FIELD_O(INFO, dm_info, NUM, "Targ", target_count, 4, int32, "segments", "Number of segments in live table, if present.")
+FIELD_O(INFO, dm_info, NUM, "Event", event_nr, 6, uint32, "events", "Number of most recent event.")
+
+FIELD_O(DEPS, dm_deps, NUM, "#Devs", count, 5, int32, "device_count", "Number of devices used by this one.")
+FIELD_F(TREE, STR, "DevNamesUsed", 16, dm_deps_names, "devs_used", "List of names of mapped devices used by this one.")
+FIELD_F(DEPS, STR, "DevNosUsed", 16, dm_deps, "devnos_used", "List of device numbers of devices used by this one.")
+FIELD_F(DEPS, STR, "BlkDevNamesUsed", 16, dm_deps_blk_names, "blkdevs_used", "List of names of block devices used by this one.")
+
+FIELD_F(TREE, NUM, "#Refs", 5, dm_tree_parents_count, "device_ref_count", "Number of mapped devices referencing this one.")
+FIELD_F(TREE, STR, "RefNames", 8, dm_tree_parents_names, "names_using_dev", "List of names of mapped devices using this one.")
+FIELD_F(TREE, STR, "RefDevNos", 9, dm_tree_parents_devs, "devnos_using_dev", "List of device numbers of mapped devices using this one.")
+
+FIELD_O(NAME, dm_split_name, STR, "Subsys", subsystem, 6, dm_subsystem, "subsystem", "Userspace subsystem responsible for this device.")
+FIELD_O(NAME, dm_split_name, STR, "VG", vg_name, 4, dm_vg_name, "vg_name", "LVM Volume Group name.")
+FIELD_O(NAME, dm_split_name, STR, "LV", lv_name, 4, dm_lv_name, "lv_name", "LVM Logical Volume name.")
+FIELD_O(NAME, dm_split_name, STR, "LVLayer", lv_layer, 7, dm_lv_layer_name, "lv_layer", "LVM device layer.")
+
+/* basic stats counters */
+FIELD_F(STATS, NUM, "Reads", 8, dm_stats_reads, "reads", "Number of reads completed.")
+FIELD_F(STATS, NUM, "RdMrges", 8, dm_stats_reads_merged, "reads_merged", "Number of reads merged.")
+FIELD_F(STATS, NUM, "RdSectors", 8, dm_stats_read_sectors, "read_sectors", "Number of sectors read.")
+FIELD_F(STATS, NUM, "RdNsec", 8, dm_stats_read_nsecs, "read_nsecs", "Time spent reading.")
+FIELD_F(STATS, NUM, "Writes", 8, dm_stats_writes, "writes", "Number of writes completed.")
+FIELD_F(STATS, NUM, "WrMerges", 8, dm_stats_writes_merged, "writes_merged", "Number of writes merged.")
+FIELD_F(STATS, NUM, "WrSectors", 8, dm_stats_write_sectors, "write_sectors", "Number of sectors written.")
+FIELD_F(STATS, NUM, "WrNsec", 8, dm_stats_write_nsecs, "write_nsecs", "Time spent writing.")
+FIELD_F(STATS, NUM, "InProgress", 8, dm_stats_io_in_progress, "in_progress", "Number of I/Os currently in progress.")
+FIELD_F(STATS, NUM, "IoNsec", 8, dm_stats_io_nsecs, "io_nsecs", "Time spent doing I/O.")
+FIELD_F(STATS, NUM, "WtIoNsec", 8, dm_stats_weighted_io_nsecs, "weighted_io_nsecs", "Weighted time spent doing I/O.")
+FIELD_F(STATS, NUM, "TotalRdNsec", 8, dm_stats_total_read_nsecs, "total_rd_nsecs", "Total time spent reading.")
+FIELD_F(STATS, NUM, "TotalWrNsec", 8, dm_stats_total_write_nsecs, "total_wr_nsecs", "Total time spent writing.")
+
+/* Stats report meta-fields */
+FIELD_F(STATS, NUM, "RgID", 5, dm_stats_region_id, "region_id", "Region ID.")
+FIELD_F(STATS, SIZ, "RStart", 5, dm_stats_region_start, "region_start", "Region start.")
+FIELD_F(STATS, SIZ, "RSize", 5, dm_stats_region_len, "region_len", "Region length.")
+FIELD_F(STATS, NUM, "ArID", 5, dm_stats_area_id, "area_id", "Area ID.")
+FIELD_F(STATS, SIZ, "AStrt", 5, dm_stats_area_start, "area_start", "Area start.")
+FIELD_F(STATS, SIZ, "ASize", 5, dm_stats_area_len, "area_len", "Area length.")
+FIELD_F(STATS, NUM, "#Areas", 6, dm_stats_area_count, "area_count", "Area count.")
+FIELD_F(STATS, STR, "ProgID", 6, dm_stats_program_id, "program_id", "Program ID.")
+FIELD_F(STATS, STR, "AuxDat", 6, dm_stats_aux_data, "aux_data", "Auxiliary data.")
+
+/* Stats derived metrics */
+FIELD_F(STATS, NUM, "RRqM/s", 8, dm_stats_rrqm, "rrqm", "Read requests merged per second.")
+FIELD_F(STATS, NUM, "WRqM/s", 8, dm_stats_wrqm, "wrqm", "Write requests merged per second.")
+FIELD_F(STATS, NUM, "R/s", 5, dm_stats_rs, "rs", "Reads per second.")
+FIELD_F(STATS, NUM, "W/s", 5, dm_stats_ws, "ws", "Writes per second.")
+FIELD_F(STATS, NUM, "RSz/s", 5, dm_stats_read_secs, "rsize_sec", "Size of data read per second.")
+FIELD_F(STATS, NUM, "WSz/s", 5, dm_stats_write_secs, "wsize_sec", "Size of data written per second.")
+FIELD_F(STATS, NUM, "AvRqSz", 5, dm_stats_arqsz, "arqsz", "Average request size.")
+FIELD_F(STATS, NUM, "QSize", 5, dm_stats_qusz, "qusz", "Average queue size.")
+FIELD_F(STATS, NUM, "AWait", 5, dm_stats_await, "await", "Averate wait time.")
+FIELD_F(STATS, NUM, "RdAWait", 5, dm_stats_r_await, "r_await", "Averate read wait time.")
+FIELD_F(STATS, NUM, "WrAWait", 5, dm_stats_w_await, "w_await", "Averate write wait time.")
+FIELD_F(STATS, NUM, "TPut", 5, dm_stats_tput, "tput", "Throughput.")
+FIELD_F(STATS, NUM, "SvcTm", 5, dm_stats_svctm, "svctm", "Service time.")
+FIELD_F(STATS, NUM, "Util%", 10, dm_stats_util, "util", "Utilization.")
+
+{0, 0, 0, 0, "", "", NULL, NULL},
+/* *INDENT-ON* */
+};
+
+#undef FIELD_O
+#undef FIELD_F
+
+#undef STR
+#undef NUM
+#undef SIZ
+
+static const char *default_report_options = "name,major,minor,attr,open,segments,events,uuid";
+static const char *splitname_report_options = "vg_name,lv_name,lv_layer";
+
+#define DEV_INFO_STATS "name,region_id"
+#define RD_STATS "reads,reads_merged,read_sectors,read_nsecs,total_rd_nsecs"
+#define WR_STATS "writes,writes_merged,write_sectors,write_nsecs,total_wr_nsecs"
+#define IO_STATS "in_progress,io_nsecs,weighted_io_nsecs"
+#define METRICS "rrqm,wrqm,rs,ws,rsize_sec,wsize_sec,arqsz,qusz,util,await,r_await,w_await"
+static const char *_stats_default_report_options = DEV_INFO_STATS ",area_id," METRICS;
+static const char *_stats_list_options = "name,region_id,region_start,region_len,area_len,area_count,program_id";
+
+static int _report_init(const struct command *cmd)
+{
+	char *options = (char *) default_report_options;
+	char *opt_fields = NULL; /* optional fields from command line */
+	const char *keys = "";
+	const char *separator = " ";
+	const char *selection = NULL;
+	int aligned = 1, headings = 1, buffered = 1, field_prefixes = 0;
+	int quoted = 1, columns_as_rows = 0;
+	uint32_t flags = 0;
+	size_t len = 0;
+	int r = 0;
+
+	if (cmd && !strcmp(cmd->name, "splitname"))
+		options = (char *) splitname_report_options;
+
+	if (cmd && !strcmp(cmd->name, "stats"))
+		options = (char *) _stats_default_report_options;
+
+	if (cmd && !strcmp(cmd->name, "list"))
+		options = (char *) _stats_list_options;
+
+	/* emulate old dmsetup behaviour */
+	if (_switches[NOHEADINGS_ARG]) {
+		separator = ":";
+		aligned = 0;
+		headings = 0;
+	}
+
+	if (_switches[UNBUFFERED_ARG])
+		buffered = 0;
+
+	if (_switches[ROWS_ARG])
+		columns_as_rows = 1;
+
+	if (_switches[UNQUOTED_ARG])
+		quoted = 0;
+
+	if (_switches[NAMEPREFIXES_ARG]) {
+		aligned = 0;
+		field_prefixes = 1;
+	}
+
+	if (_switches[OPTIONS_ARG] && _string_args[OPTIONS_ARG]) {
+		/* Count & interval forbidden for help. */
+		if (strstr(_string_args[OPTIONS_ARG], "help")) {
+			_switches[COUNT_ARG] = 0;
+			_count = 1;
+			_switches[INTERVAL_ARG] = 0;
+		}
+
+		if (*_string_args[OPTIONS_ARG] != '+')
+			options = _string_args[OPTIONS_ARG];
+		else {
+			char *tmpopts;
+			opt_fields = _string_args[OPTIONS_ARG] + 1;
+			len = strlen(options) + strlen(opt_fields) + 2;
+			if (!(tmpopts = dm_malloc(len))) {
+				err("Failed to allocate option string.");
+				return 0;
+			}
+			if (dm_snprintf(tmpopts, len, "%s,%s",
+					options, opt_fields) < 0) {
+				dm_free(tmpopts);
+				return 0;
+			}
+			options = tmpopts;
+		}
+	}
+
+	if (_switches[SORT_ARG] && _string_args[SORT_ARG]) {
+		keys = _string_args[SORT_ARG];
+		buffered = 1;
+		if (cmd && (!strcmp(cmd->name, "status") || !strcmp(cmd->name, "table"))) {
+			err("--sort is not yet supported with status and table");
+			goto out;
+		}
+	}
+
+	if (_switches[SEPARATOR_ARG] && _string_args[SEPARATOR_ARG]) {
+		separator = _string_args[SEPARATOR_ARG];
+		aligned = 0;
+	}
+
+	if (_switches[SELECT_ARG] && _string_args[SELECT_ARG])
+		selection = _string_args[SELECT_ARG];
+
+	if (aligned)
+		flags |= DM_REPORT_OUTPUT_ALIGNED;
+
+	if (buffered)
+		flags |= DM_REPORT_OUTPUT_BUFFERED;
+
+	if (headings)
+		flags |= DM_REPORT_OUTPUT_HEADINGS;
+
+	if (field_prefixes)
+		flags |= DM_REPORT_OUTPUT_FIELD_NAME_PREFIX;
+
+	if (!quoted)
+		flags |= DM_REPORT_OUTPUT_FIELD_UNQUOTED;
+
+	if (columns_as_rows)
+		flags |= DM_REPORT_OUTPUT_COLUMNS_AS_ROWS;
+
+	if (!(_report = dm_report_init_with_selection(&_report_type, _report_types,
+				_report_fields, options, separator, flags, keys,
+				selection, NULL, NULL)))
+		goto out;
+
+	if ((_report_type & DR_TREE) && !_build_whole_deptree(cmd)) {
+		err("Internal device dependency tree creation failed.");
+		goto out;
+	}
+
+	if (!_switches[INTERVAL_ARG])
+		_int_args[INTERVAL_ARG] = 1; /* 1s default. */
+
+	_interval = NSEC_PER_SEC * (uint64_t) _int_args[INTERVAL_ARG];
+
+	if (field_prefixes)
+		dm_report_set_output_field_name_prefix(_report, "dm_");
+
+	r = 1;
+
+out:
+	if (len)
+		dm_free(options);
+
+	return r;
+}
+
+/*
+ * List devices
+ */
+static int _ls(CMD_ARGS)
+{
+	if ((_switches[TARGET_ARG] && _target) ||
+	    (_switches[EXEC_ARG] && _command))
+		return _status(cmd, NULL, argc, argv, NULL, 0);
+	else if ((_switches[TREE_ARG]))
+		return _display_tree(cmd, NULL, 0, NULL, NULL, 0);
+	else
+		return _process_all(cmd, NULL, argc, argv, 0, _display_name);
+}
+
+static int _mangle(CMD_ARGS)
+{
+	const char *name, *uuid;
+	char *new_name = NULL, *new_uuid = NULL;
+	struct dm_task *dmt;
+	struct dm_info info;
+	int r = 0;
+	int target_format;
+
+	if (names)
+		name = names->name;
+	else {
+		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+			return _process_all(cmd, NULL, argc, argv, 0, _mangle);
+		name = argv[1];
+	}
+
+	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+		return 0;
+
+	if (!(_set_task_device(dmt, name, 0)))
+		goto out;
+
+	if (!_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
+	if (!_task_run(dmt))
+		goto out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto out;
+
+	uuid = dm_task_get_uuid(dmt);
+
+	target_format = _switches[MANGLENAME_ARG] ? _int_args[MANGLENAME_ARG]
+						  : DEFAULT_DM_NAME_MANGLING;
+
+	if (target_format == DM_STRING_MANGLING_AUTO) {
+		if (strstr(name, "\\x5cx")) {
+			log_error("The name \"%s\" seems to be mangled more than once. "
+				  "Manual intervention required to rename the device.", name);
+			goto out;
+		}
+		if (strstr(uuid, "\\x5cx")) {
+			log_error("The UUID \"%s\" seems to be mangled more than once. "
+				  "Manual intervention required to correct the device UUID.", uuid);
+			goto out;
+		}
+	}
+
+	if (target_format == DM_STRING_MANGLING_NONE) {
+		if (!(new_name = dm_task_get_name_unmangled(dmt)))
+			goto out;
+		if (!(new_uuid = dm_task_get_uuid_unmangled(dmt)))
+			goto out;
+	}
+	else {
+		if (!(new_name = dm_task_get_name_mangled(dmt)))
+			goto out;
+		if (!(new_uuid = dm_task_get_uuid_mangled(dmt)))
+			goto out;
+	}
+
+	/* We can't rename the UUID, the device must be reactivated manually. */
+	if (strcmp(uuid, new_uuid)) {
+		log_error("%s: %s: UUID in incorrect form. ", name, uuid);
+		log_error("Unable to change device UUID. The device must be deactivated first.");
+		r = 0;
+		goto out;
+	}
+
+	/* Nothing to do if the name is in correct form already. */
+	if (!strcmp(name, new_name)) {
+		log_print("%s: %s: name %salready in correct form", name,
+			  *uuid ? uuid : "[no UUID]", *uuid ? "and UUID " : "");
+		r = 1;
+		goto out;
+	}
+	else
+		log_print("%s: renaming to %s", name, new_name);
+
+	/* Rename to correct form of the name. */
+	r = _do_rename(name, new_name, NULL);
+
+out:
+	dm_free(new_name);
+	dm_free(new_uuid);
+	dm_task_destroy(dmt);
+	return r;
+}
+
+static int _stats(CMD_ARGS);
+static int _bind_stats_device(struct dm_stats *dms, const char *name)
+{
+	if (name && !dm_stats_bind_name(dms, name))
+		return 0;
+	else if (_switches[UUID_ARG] && !dm_stats_bind_uuid(dms, _uuid))
+		return 0;
+	else if (_switches[MAJOR_ARG] && _switches[MINOR_ARG]
+		 && !dm_stats_bind_devno(dms, _int_args[MAJOR_ARG],
+					 _int_args[MINOR_ARG]))
+		return 0;
+
+	return 1;
+}
+
+static int _stats_clear_regions(struct dm_stats *dms, uint64_t region_id)
+{
+	int allregions = (region_id == DM_STATS_REGIONS_ALL);
+
+	if (!dm_stats_list(dms, NULL))
+		goto_out;
+
+	if (!dm_stats_get_nr_regions(dms))
+		goto done;
+
+	dm_stats_walk_do(dms) {
+		if (allregions)
+			region_id = dm_stats_get_current_region(dms);
+
+		if (!dm_stats_region_present(dms, region_id)) {
+			log_error("No such region: %"PRIu64".", region_id);
+			goto out;
+		}
+		if (!dm_stats_clear_region(dms, region_id)) {
+			log_error("Clearing statistics region %"PRIu64" failed.",
+				  region_id);
+			goto out;
+		}
+		log_info("Cleared statistics region %"PRIu64".", region_id);
+		dm_stats_walk_next_region(dms);
+	} dm_stats_walk_while(dms);
+done:
+	return 1;
+
+out:
+	return 0;
+}
+
+static int _stats_clear(CMD_ARGS)
+{
+	struct dm_stats *dms;
+	uint64_t region_id;
+	char *name = NULL;
+	int allregions = _switches[ALL_REGIONS_ARG];
+
+	if (!_switches[REGION_ID_ARG] && !_switches[ALL_REGIONS_ARG]) {
+		err("Please specify a region_id.");
+		return 0;
+	}
+
+	if (names)
+		name = names->name;
+	else {
+		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+			return _process_all(cmd, subcommand, argc, argv, 0, _stats_clear);
+		name = argv[1];
+	}
+
+	/* create does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
+	region_id = (allregions) ? DM_STATS_REGIONS_ALL
+		     : (uint64_t) _int_args[REGION_ID_ARG];
+
+	dms = dm_stats_create(DM_STATS_PROGRAM_ID);
+
+	if (!_bind_stats_device(dms, name))
+		goto_out;
+
+	if (!_stats_clear_regions(dms, region_id))
+		goto_out;
+
+	dm_stats_destroy(dms);
+	return 1;
+
+out:
+	dm_stats_destroy(dms);
+	return 0;
+}
+
+static uint64_t _factor_from_units(char *argptr, char *unit_type)
+{
+	return dm_units_to_factor(argptr, unit_type, 0, NULL);
+}
+
+/**
+ * Parse a start, length, or area size argument in bytes from a string
+ * using optional units as supported by _factor_from_units().
+ */
+static int _size_from_string(char *argptr, uint64_t *size, const char *name)
+{
+	uint64_t factor;
+	char *endptr = NULL, unit_type;
+	if (!argptr)
+		return 0;
+
+	*size = strtoull(argptr, &endptr, 10);
+	if (endptr == argptr) {
+		*size = 0;
+		log_error("Invalid %s argument: \"%s\"",
+			  name, (*argptr) ? argptr : "");
+		return 0;
+	}
+
+	if (*endptr == '\0') {
+		*size *= 512;
+		return 1;
+	}
+
+	factor = _factor_from_units(endptr, &unit_type);
+	if (factor)
+		*size *= factor;
+
+	return 1;
+}
+
+static int _stats_create_segments(struct dm_stats *dms,
+				  const char *name, int64_t step,
+				  const char *program_id, const char *aux_data)
+{
+	uint64_t start, length, region_id = UINT64_C(0);
+	char *target_type, *params; /* unused */
+	struct dm_task *dmt;
+	struct dm_info info;
+	void *next = NULL;
+	const char *devname = NULL;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_TABLE)))
+		return 0;
+
+	if (!_set_task_device(dmt, name, 0))
+		goto out;
+
+	if (!dm_task_no_open_count(dmt))
+		goto out;
+
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
+
+	if (!_task_run(dmt))
+		goto out;
+
+	if (!dm_task_get_info(dmt, &info) || !info.exists)
+		goto out;
+
+	if (!(devname = dm_task_get_name(dmt)))
+		goto out;
+
+	do {
+		next = dm_get_next_target(dmt, next, &start, &length,
+					  &target_type, &params);
+		if (!dm_stats_create_region(dms, &region_id, start, length,
+					    step, program_id, aux_data)) {
+			log_error("Could not create statistics region.");
+		}
+		printf("Created region %"PRIu64" on %s\n",
+		       region_id, devname);
+	} while (next);
+
+	dm_stats_destroy(dms);
+	dm_task_destroy(dmt);
+	return 1;
+
+out:
+	dm_task_destroy(dmt);
+	return 0;
+}
+
+static int _stats_create(CMD_ARGS)
+{
+	struct dm_stats *dms;
+	const char *name, *aux_data = "", *program_id = DM_STATS_PROGRAM_ID;
+	uint64_t region_id;
+	uint64_t start = 0, len = 0, areas = 0, area_size = 0;
+	int64_t step = 0;
+
+	if (_switches[ALL_REGIONS_ARG]) {
+		log_error("Cannot use --allregions with create.");
+		return 0;
+	}
+
+	if (_switches[ALL_PROGRAMS_ARG]) {
+		log_error("Cannot use --allprograms with create.");
+		return 0;
+	}
+
+	if (_switches[AREAS_ARG] && _switches[AREA_SIZE_ARG]) {
+		log_error("Please specify one of --areas and --areasize.");
+		return 0;
+	}
+
+	if (_switches[PROGRAM_ID_ARG]
+	    && !strlen(_string_args[PROGRAM_ID_ARG]) && !_switches[FORCE_ARG]) {
+		log_error("Creating a region with no program "
+			  "id requires --force.");
+			return 0;
+	}
+
+	if (names)
+		name = names->name;
+	else {
+		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
+			if (!_switches[FORCE_ARG]) {
+				log_error("Creating regions on all devices "
+					  "requires --force.");
+				return 0;
+			}
+			return _process_all(cmd, subcommand, argc, argv, 0, _stats_create);
+		}
+		name = argv[1];
+	}
+
+	/* create does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
+	if (_switches[AREAS_ARG])
+		areas = (uint64_t) _int_args[AREAS_ARG];
+
+	if (_switches[AREA_SIZE_ARG])
+		if (!_size_from_string(_string_args[AREA_SIZE_ARG],
+				       &area_size, "areasize"))
+			return 0;
+
+	areas = (areas) ? areas : 1;
+	/* bytes to sectors or area count - promote to int before conversion */
+	step = (area_size) ? ((int64_t) area_size / 512) : -((int64_t) areas);
+
+	if (_switches[START_ARG]) {
+		if (!_size_from_string(_string_args[START_ARG],
+				       &start, "start"))
+			return 0;
+	}
+
+	/* bytes to sectors */
+	start /= 512;
+
+	if (_switches[LENGTH_ARG]) {
+		if (!_size_from_string(_string_args[LENGTH_ARG],
+				       &len, "length"))
+			return 0;
+	}
+
+	/* bytes to sectors */
+	len /= 512;
+
+	if (_switches[PROGRAM_ID_ARG])
+		program_id = _string_args[PROGRAM_ID_ARG];
+	if (!strlen(program_id) && !_switches[FORCE_ARG])
+		program_id = DM_STATS_PROGRAM_ID;
+
+	if (_switches[AUX_DATA_ARG])
+		aux_data = _string_args[AUX_DATA_ARG];
+
+	dms = dm_stats_create(DM_STATS_PROGRAM_ID);
+	if (!_bind_stats_device(dms, name))
+		goto_out;
+
+	if (!strlen(program_id))
+		/* force creation of a region with no id */
+		dm_stats_set_program_id(dms, 1, NULL);
+
+	if (_switches[SEGMENTS_ARG])
+		return _stats_create_segments(dms, name, step,
+					      program_id, aux_data);
+
+	if (!dm_stats_create_region(dms, &region_id, start, len,
+				    step, program_id, aux_data)) {
+		log_error("Could not create statistics region.");
+		goto out;
+	}
+
+	/* FIXME: support --quiet and --export output modes */
+	printf("Created region: %"PRIu64"\n", region_id);
+	dm_stats_destroy(dms);
+	return 1;
+
+out:
+	dm_stats_destroy(dms);
+	return 0;
+}
+
+static int _stats_delete(CMD_ARGS)
+{
+	struct dm_stats *dms;
+	uint64_t region_id;
+	char *name = NULL;
+	const char *program_id = DM_STATS_PROGRAM_ID;
+	int allregions = _switches[ALL_REGIONS_ARG];
+
+	if (!_switches[REGION_ID_ARG] && !allregions) {
+		err("Please specify a region_id.");
+		return 0;
+	}
+
+	if (names)
+		name = names->name;
+	else {
+		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
+			if (!_switches[FORCE_ARG]) {
+				log_error("Deleting regions from all devices "
+					  "requires --force.");
+				return 0;
+			}
+			return _process_all(cmd, subcommand, argc, argv, 0, _stats_delete);
+		}
+		name = argv[1];
+	}
+
+	/* delete does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
+	if (_switches[ALL_PROGRAMS_ARG])
+		program_id = DM_STATS_ALL_PROGRAMS;
+
+	region_id = (uint64_t) _int_args[REGION_ID_ARG];
+
+	dms = dm_stats_create(program_id);
+
+	if (!_bind_stats_device(dms, name))
+		goto_out;
+
+	if (allregions && !dm_stats_list(dms, program_id))
+		goto_out;
+
+	if (allregions && !dm_stats_get_nr_regions(dms))
+		/* no regions present */
+		goto done;
+
+	dm_stats_walk_do(dms) {
+		if (_switches[ALL_REGIONS_ARG])
+			region_id = dm_stats_get_current_region(dms);
+		if (!dm_stats_delete_region(dms, region_id)) {
+			log_error("Could not delete statistics region.");
+			goto out;
+		}
+		log_info("Deleted statistics region %" PRIu64, region_id);
+		dm_stats_walk_next_region(dms);
+	} dm_stats_walk_while(dms);
+
+done:
+	dm_stats_destroy(dms);
+	return 1;
+
+out:
+	dm_stats_destroy(dms);
+	return 0;
+}
+
+static int _stats_list(CMD_ARGS)
 {
-	const char *name, *uuid;
-	char *new_name = NULL, *new_uuid = NULL;
-	struct dm_task *dmt;
+	struct dm_stats *dms;
+	const char *name, *program_id = DM_STATS_PROGRAM_ID;
+	struct dm_task *dmt = NULL;
 	struct dm_info info;
-	int r = 0;
-	int target_format;
+	struct dmsetup_report_obj obj;
 
 	if (names)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
-			return _process_all(cmd, NULL, argc, argv, 0, _mangle);
+			return _process_all(cmd, subcommand, argc, argv, 0, _stats_list);
 		name = argv[1];
 	}
 
-	if (!(dmt = dm_task_create(DM_DEVICE_STATUS)))
+	if (_switches[PROGRAM_ID_ARG])
+		program_id = _string_args[PROGRAM_ID_ARG];
+
+	if (_switches[ALL_PROGRAMS_ARG])
+		program_id = "";
+
+	if (_switches[OPTIONS_ARG] && !strcmp(_string_args[OPTIONS_ARG], "help"))
+		/* field help already output from _report_init(). */
+		return 1;
+
+	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
+		goto_out;
+
+	if (!_bind_stats_device(dms, name))
+		goto_out;
+
+	if (!dm_stats_list(dms, program_id)) {
+		log_error("Could not list statistics regions.");
+		goto out;
+	}
+
+	if (_report && !_stats_report_init) {
+		dm_report_free(_report);
+		_report_init(cmd);
+		_stats_report_init = 1;
+	}
+
+	if (!dm_stats_get_nr_regions(dms)) {
+		log_info("No statistics regions present.");
+		goto none;
+	}
+
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
 		return 0;
 
-	if (!(_set_task_device(dmt, name, 0)))
+	if (!_set_task_device(dmt, name, 0))
 		goto out;
 
-	if (!_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
 		goto out;
 
 	if (!_task_run(dmt))
 		goto out;
 
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!dm_task_get_info(dmt, &info))
 		goto out;
 
-	uuid = dm_task_get_uuid(dmt);
+	obj.task = dmt;
+	obj.stats = dms;
+	obj.info = &info;
 
-	target_format = _switches[MANGLENAME_ARG] ? _int_args[MANGLENAME_ARG]
-						  : DEFAULT_DM_NAME_MANGLING;
+	dm_stats_walk_do(obj.stats) {
+		dm_report_object(_report, &obj);
+		dm_stats_walk_next_region(obj.stats);
+	} dm_stats_walk_while(obj.stats);
 
-	if (target_format == DM_STRING_MANGLING_AUTO) {
-		if (strstr(name, "\\x5cx")) {
-			log_error("The name \"%s\" seems to be mangled more than once. "
-				  "Manual intervention required to rename the device.", name);
+	dm_task_destroy(dmt);
+
+none:
+	dm_stats_destroy(dms);
+	return 1;
+
+out:
+	if (dmt)
+		dm_task_destroy(dmt);
+	dm_stats_destroy(dms);
+	return 0;
+}
+
+static int _stats_print(CMD_ARGS)
+{
+	struct dm_stats *dms;
+	char *name, *stbuff = NULL;
+	uint64_t region_id;
+	unsigned clear = (unsigned) _switches[CLEAR_ARG];
+	int allregions = _switches[ALL_REGIONS_ARG];
+
+	if (!_switches[REGION_ID_ARG] && !allregions) {
+		err("Please specify a region_id.");
+		return 0;
+	}
+
+	if (names)
+		name = names->name;
+	else {
+		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+			return _process_all(cmd, subcommand, argc, argv, 0, _stats_print);
+		name = argv[1];
+	}
+
+	/* print does not use a report */
+	if (_report) {
+		dm_report_free(_report);
+		_report = NULL;
+	}
+
+	region_id = (uint64_t) _int_args[REGION_ID_ARG];
+
+	dms = dm_stats_create(DM_STATS_PROGRAM_ID);
+
+	if (!_bind_stats_device(dms, name))
+		goto_out;
+
+	if (!dm_stats_list(dms, NULL))
+		goto_out;
+
+	if (allregions && !dm_stats_get_nr_regions(dms))
+		goto done;
+
+	dm_stats_walk_do(dms) {
+		if (_switches[ALL_REGIONS_ARG])
+			region_id = dm_stats_get_current_region(dms);
+
+		if (!dm_stats_region_present(dms, region_id)) {
+			log_error("No such region: %"PRIu64".", region_id);
 			goto out;
 		}
-		if (strstr(uuid, "\\x5cx")) {
-			log_error("The UUID \"%s\" seems to be mangled more than once. "
-				  "Manual intervention required to correct the device UUID.", uuid);
+
+		/*FIXME: line control for large regions */
+		if (!(stbuff = dm_stats_print_region(dms, region_id, 0, 0, clear))) {
+			log_error("Could not print statistics region.");
 			goto out;
 		}
-	}
 
-	if (target_format == DM_STRING_MANGLING_NONE) {
-		if (!(new_name = dm_task_get_name_unmangled(dmt)))
-			goto out;
-		if (!(new_uuid = dm_task_get_uuid_unmangled(dmt)))
-			goto out;
-	}
+		printf("%s", stbuff);
+
+		dm_stats_buffer_destroy(dms, stbuff);
+		dm_stats_walk_next_region(dms);
+
+	} dm_stats_walk_while(dms);
+
+done:
+	dm_stats_destroy(dms);
+	return 1;
+
+out:
+	dm_stats_destroy(dms);
+	return 0;
+}
+
+static int _stats_report(CMD_ARGS)
+{
+	int r = 0;
+
+	struct dm_task *dmt;
+	char *name = NULL;
+
+	if (names)
+		name = names->name;
 	else {
-		if (!(new_name = dm_task_get_name_mangled(dmt)))
-			goto out;
-		if (!(new_uuid = dm_task_get_uuid_mangled(dmt)))
-			goto out;
+		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+			return _process_all(cmd, subcommand, argc, argv, 0, _info);
+		name = argv[1];
 	}
 
-	/* We can't rename the UUID, the device must be reactivated manually. */
-	if (strcmp(uuid, new_uuid)) {
-		log_error("%s: %s: UUID in incorrect form. ", name, uuid);
-		log_error("Unable to change device UUID. The device must be deactivated first.");
-		r = 0;
+	if (!_report)
 		goto out;
-	}
 
-	/* Nothing to do if the name is in correct form already. */
-	if (!strcmp(name, new_name)) {
-		log_print("%s: %s: name %salready in correct form", name,
-			  *uuid ? uuid : "[no UUID]", *uuid ? "and UUID " : "");
-		r = 1;
+	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
+		return 0;
+
+	if (!_set_task_device(dmt, name, 0))
 		goto out;
-	}
-	else
-		log_print("%s: renaming to %s", name, new_name);
 
-	/* Rename to correct form of the name. */
-	r = _do_rename(name, new_name, NULL);
+	if (_switches[CHECKS_ARG] && !dm_task_enable_checks(dmt))
+		goto out;
 
-out:
-	dm_free(new_name);
-	dm_free(new_uuid);
+	if (!_task_run(dmt))
+		goto out;
+
+	r = _display_info(dmt);
+
+      out:
 	dm_task_destroy(dmt);
 	return r;
 }
 
-static int _dmsetup_help(CMD_ARGS);
+/*
+ * Command dispatch tables and usage.
+ */
+static int _stats_help(CMD_ARGS);
 
 /*
- * Dispatch table
+ * dmsetup stats <cmd> [options] [device_name]
+ * dmstats <cmd> [options] [device_name]
+ *
+ *    clear [--regionid id] <device_name>
+ *    create [--areas nr_areas] [--areasize size]
+ *           [ [--start start] [--length len] | [--segments]]
+ *           [--auxdata data] [--programid id] [<device_name>]
+ *    delete [--regionid] <device_name>
+ *    delete_all [--programid id]
+ *    list [--programid id] [<device_name>]
+ *    print [--clear] [--programid id] [--regionid id] [<device_name>]
+ *    report [--interval seconds] [--count count] [--units units] [--regionid id]
+ *           [--programid id] [<device>]
  */
+
+#define AREA_OPTS "[--areas <nr_areas>] [--areasize <size>] "
+#define CREATE_OPTS "[--start <start> [--length <len>]]\n\t\t" AREA_OPTS
+#define ID_OPTS "[--programid <id>] [--auxdata <data> ] "
+#define SELECT_OPTS "[--programid <id>] [--regionid <id>] "
+#define PRINT_OPTS "[--clear] " SELECT_OPTS
+#define REPORT_OPTS "[--interval <seconds>] [--count <cnt>]\n\t\t[--units <u>]" SELECT_OPTS
+
+static struct command _stats_subcommands[] = {
+	{"help", "", 0, 0, 0, 0, _stats_help},
+	{"clear", "--regionid <id> [<device>]", 0, -1, 1, 0, _stats_clear},
+	{"create", CREATE_OPTS "\n\t\t" ID_OPTS "[<device>]", 0, -1, 1, 0, _stats_create},
+	{"delete", "--regionid <id> <device>", 1, -1, 1, 0, _stats_delete},
+	{"list", "[--programid <id>] [<device>]", 0, -1, 1, 0, _stats_list},
+	{"print", PRINT_OPTS "[<device>]", 0, -1, 1, 0, _stats_print},
+	{"report", REPORT_OPTS "[<device>]", 0, -1, 1, 0, _stats_report},
+	{"version", "", 0, -1, 1, 0, _version},
+	{NULL, NULL, 0, 0, 0, 0, NULL}
+};
+
+#undef AREA_OPTS
+#undef CREATE_OPTS
+#undef ID_OPTS
+#undef PRINT_OPTS
+#undef REPORT_OPTS
+#undef SELECT_OPTS
+
+static int _dmsetup_help(CMD_ARGS);
+
 static struct command _dmsetup_commands[] = {
 	{"help", "[-c|-C|--columns]", 0, 0, 0, 0, _dmsetup_help},
 	{"create", "<dev_name>\n"
 	  "\t    [-j|--major <major> -m|--minor <minor>]\n"
 	  "\t    [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
 	  "\t    [-u|uuid <uuid>] [{--addnodeonresume|--addnodeoncreate}]\n"
-	  "\t    [--notable | --table <table> | <table_file>]",
-	 1, 2,0,  0, _create},
+	  "\t    [--notable | --table <table> | <table_file>]", 1, 2, 0, 0, _create},
 	{"remove", "[-f|--force] [--deferred] <device>", 0, -1, 1, 0, _remove},
-	{"remove_all", "[-f|--force]", 0, 0, 0,  0, _remove_all},
+	{"remove_all", "[-f|--force]", 0, 0, 0, 0, _remove_all},
 	{"suspend", "[--noflush] <device>", 0, -1, 1, 0, _suspend},
 	{"resume", "<device> [{--addnodeonresume|--addnodeoncreate}]", 0, -1, 1, 0, _resume},
 	{"load", "<device> [<table_file>]", 0, 2, 0, 0, _load},
@@ -3113,6 +4488,7 @@ static struct command _dmsetup_commands[] = {
 	{"ls", "[--target <target_type>] [--exec <command>] [-o options] [--tree]", 0, 0, 0, 0, _ls},
 	{"info", "[<device>]", 0, -1, 1, 0, _info},
 	{"deps", "[-o options] [<device>]", 0, -1, 1, 0, _deps},
+	{"stats", "<command> [<options>] [<devices>]", 1, -1, 1, 1, _stats},
 	{"status", "[<device>] [--noflush] [--target <target_type>]", 0, -1, 1, 0, _status},
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, 0, _status},
 	{"wait", "<device> [<event_nr>] [--noflush]", 0, 2, 0, 0, _wait},
@@ -3131,6 +4507,32 @@ static struct command _dmsetup_commands[] = {
 	{NULL, NULL, 0, 0, 0, 0, NULL}
 };
 
+/*
+ * Usage and help text.
+ */
+
+static void _stats_usage(FILE *out)
+{
+	int i;
+
+	fprintf(out, "Usage:\n");
+	fprintf(out, "stats [-h|--help]\n");
+	fprintf(out, "        [-v|--verbose [-v|--verbose ...]]\n");
+	fprintf(out, "        [--areas <nr_areas>] [--areasize <size>]\n");
+	fprintf(out, "        [--auxdata <data>] [--clear]\n");
+	fprintf(out, "        [--count <count>] [--interval <seconds>]\n");
+	fprintf(out, "        [-o <fields>] [-O|--sort <sort_fields>]\n");
+	fprintf(out, "	   [--programid <id>]\n");
+	fprintf(out, "        [--start <start>] [--length <length>]\n");
+	fprintf(out, "        [--segments] [--units <units>]\n\n");
+	for (i = 0; _stats_subcommands[i].name; i++)
+		fprintf(out, "\t%s %s\n", _stats_subcommands[i].name, _stats_subcommands[i].help);
+	fprintf(out, "<device> may be device name or -u <uuid> or "
+		     "-j <major> -m <minor>\n");
+	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
+	fprintf(out, "\n");
+}
+
 static void _dmsetup_usage(FILE *out)
 {
 	int i;
@@ -3144,7 +4546,6 @@ static void _dmsetup_usage(FILE *out)
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [-S|--select <selection>] [--nameprefixes] [--noheadings]\n"
-		"        [--count <count>] [--interval <seconds>]\n"
 		"        [--separator <separator>]\n\n");
 	for (i = 0; _dmsetup_commands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _dmsetup_commands[i].name, _dmsetup_commands[i].help);
@@ -3166,6 +4567,37 @@ static void _losetup_usage(FILE *out)
 		     "[-o offset] [-f|loop_device] [file]\n\n");
 }
 
+static int _stats_help(CMD_ARGS)
+{
+	_stats_usage(stderr);
+
+	/**
+	 * main() increments this to ensure reports are set up for
+	 * stats use so decrement that count here; if the counter is
+	 * still non-zero then the user explicitly requested the
+	 * columns help output.
+	 */
+	_switches[COLS_ARG]--;
+
+	if (_switches[COLS_ARG]) {
+		_switches[OPTIONS_ARG] = 1;
+		_string_args[OPTIONS_ARG] = (char *) "help";
+		_switches[SORT_ARG] = 0;
+
+		if (_report) {
+			dm_report_free(_report);
+			_report = NULL;
+		}
+		(void) _report_init(cmd);
+	}
+
+	/* help text already output: don't repeat from main */
+	dm_report_free(_report);
+	_report = NULL;
+
+	return 1;
+}
+
 static int _dmsetup_help(CMD_ARGS)
 {
 	_dmsetup_usage(stderr);
@@ -3202,6 +4634,43 @@ static const struct command *_find_dmsetup_command(const char *name)
 	return _find_command(_dmsetup_commands, name);
 }
 
+static const struct command *_find_stats_subcommand(const char *name)
+{
+	return _find_command(_stats_subcommands, name);
+}
+
+static int _stats(CMD_ARGS)
+{
+	const struct command *stats_cmd;
+
+	if (_switches[HELP_ARG]) {
+		stats_cmd = _find_stats_subcommand("help");
+		goto doit;
+	}
+
+	if (!(stats_cmd = _find_stats_subcommand(subcommand))) {
+		log_error("Unknown stats command.");
+		_stats_help(stats_cmd, NULL, argc, argv, NULL, multiple_devices);
+		return 0;
+	}
+
+	if (_switches[ALL_PROGRAMS_ARG] && _switches[PROGRAM_ID_ARG]) {
+		log_error("Please supply one of --allprograms and --programid");
+		return 0;
+	}
+
+	if (_switches[ALL_REGIONS_ARG] && _switches[REGION_ID_ARG]) {
+		log_error("Please supply one of --allregions and --regionid");
+		return 0;
+	}
+
+doit:
+	if (!stats_cmd->fn(stats_cmd, NULL, argc, argv, NULL, multiple_devices))
+		return 0;
+
+	return 1;
+}
+
 static int _process_tree_options(const char *options)
 {
 	const char *s, *end;
@@ -3552,11 +5021,19 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 	char *namebase, *s;
 	static int ind;
 	int c, r;
+	/* "stats" command and sub-command when run as 'dmstats'. */
+	char *stats_p = NULL, *stats_c = NULL;
 
 #ifdef HAVE_GETOPTLONG
 	static struct option long_options[] = {
 		{"readonly", 0, &ind, READ_ONLY},
+		{"allprograms", 0, &ind, ALL_PROGRAMS_ARG},
+		{"allregions", 0, &ind, ALL_REGIONS_ARG},
+		{"areas", 1, &ind, AREAS_ARG},
+		{"areasize", 1, &ind, AREA_SIZE_ARG},
+		{"auxdata", 1, &ind, AUX_DATA_ARG},
 		{"checks", 0, &ind, CHECKS_ARG},
+		{"clear", 0, &ind, CLEAR_ARG},
 		{"columns", 0, &ind, COLS_ARG},
 		{"count", 1, &ind, COUNT_ARG},
 		{"deferred", 0, &ind, DEFERRED_ARG},
@@ -3567,6 +5044,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"help", 0, &ind, HELP_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
 		{"interval", 1, &ind, INTERVAL_ARG},
+		{"length", 1, &ind, LENGTH_ARG},
 		{"manglename", 1, &ind, MANGLENAME_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
@@ -3576,22 +5054,28 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"noheadings", 0, &ind, NOHEADINGS_ARG},
 		{"nolockfs", 0, &ind, NOLOCKFS_ARG},
 		{"noopencount", 0, &ind, NOOPENCOUNT_ARG},
+		{"nosuffix", 0, &ind, NOSUFFIX_ARG},
 		{"notable", 0, &ind, NOTABLE_ARG},
 		{"udevcookie", 1, &ind, UDEVCOOKIE_ARG},
 		{"noudevrules", 0, &ind, NOUDEVRULES_ARG},
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
+		{"programid", 1, &ind, PROGRAM_ID_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
+		{"regionid", 1, &ind, REGION_ID_ARG},
 		{"retry", 0, &ind, RETRY_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
+		{"segments", 0, &ind, SEGMENTS_ARG},
 		{"separator", 1, &ind, SEPARATOR_ARG},
 		{"setuuid", 0, &ind, SETUUID_ARG},
 		{"showkeys", 0, &ind, SHOWKEYS_ARG},
 		{"sort", 1, &ind, SORT_ARG},
+		{"start", 1, &ind, START_ARG},
 		{"table", 1, &ind, TABLE_ARG},
 		{"target", 1, &ind, TARGET_ARG},
 		{"tree", 0, &ind, TREE_ARG},
 		{"uid", 1, &ind, UID_ARG},
+		{"units", 1, &ind, UNITS_ARG},
 		{"uuid", 1, &ind, UUID_ARG},
 		{"unbuffered", 0, &ind, UNBUFFERED_ARG},
 		{"unquoted", 0, &ind, UNQUOTED_ARG},
@@ -3655,22 +5139,50 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		return r;
 	}
 
+	if (!strcmp(base, "dmstats")) {
+		/* save the offset to the 'stats' in 'dmstats' */
+		stats_p = (*argvp)[0] + strlen(namebase) - strlen(base) + 2;
+		stats_c = (*argvp)[1]; /* stats command */
+	}
+
 	free(namebase);
 
 	optarg = 0;
 	optind = OPTIND_INIT;
 	while ((ind = -1, c = GETOPTLONG_FN(*argcp, *argvp, "cCfG:hj:m:M:no:O:rS:u:U:vy",
 					    long_options, NULL)) != -1) {
+		if (ind == ALL_PROGRAMS_ARG)
+			_switches[ALL_PROGRAMS_ARG]++;
+		if (ind == ALL_REGIONS_ARG)
+			_switches[ALL_REGIONS_ARG]++;
+		if (ind == AREAS_ARG) {
+			_switches[AREAS_ARG]++;
+			_int_args[AREAS_ARG] = atoi(optarg);
+		}
+		if (ind == AREA_SIZE_ARG) {
+			_switches[AREA_SIZE_ARG]++;
+			_string_args[AREA_SIZE_ARG] = optarg;
+		}
+		if (ind == AUX_DATA_ARG) {
+			_switches[AUX_DATA_ARG]++;
+			_string_args[AUX_DATA_ARG] = optarg;
+		}
 		if (c == ':' || c == '?')
 			return 0;
 		if (c == 'h' || ind == HELP_ARG)
 			_switches[HELP_ARG]++;
+		if (ind == CLEAR_ARG)
+			_switches[CLEAR_ARG]++;
 		if (c == 'c' || c == 'C' || ind == COLS_ARG)
 			_switches[COLS_ARG]++;
 		if (c == 'f' || ind == FORCE_ARG)
 			_switches[FORCE_ARG]++;
 		if (c == 'r' || ind == READ_ONLY)
 			_switches[READ_ONLY]++;
+		if (ind == LENGTH_ARG) {
+			_switches[LENGTH_ARG]++;
+			_string_args[LENGTH_ARG] = optarg;
+		}
 		if (c == 'j' || ind == MAJOR_ARG) {
 			_switches[MAJOR_ARG]++;
 			_int_args[MAJOR_ARG] = atoi(optarg);
@@ -3679,16 +5191,30 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[MINOR_ARG]++;
 			_int_args[MINOR_ARG] = atoi(optarg);
 		}
+		if (ind == NOSUFFIX_ARG)
+			_switches[NOSUFFIX_ARG]++;
 		if (c == 'n' || ind == NOTABLE_ARG)
 			_switches[NOTABLE_ARG]++;
 		if (c == 'o' || ind == OPTIONS_ARG) {
 			_switches[OPTIONS_ARG]++;
 			_string_args[OPTIONS_ARG] = optarg;
 		}
+		if (ind == PROGRAM_ID_ARG) {
+			_switches[PROGRAM_ID_ARG]++;
+			_string_args[PROGRAM_ID_ARG] = optarg;
+		}
+		if (ind == REGION_ID_ARG) {
+			_switches[REGION_ID_ARG]++;
+			_int_args[REGION_ID_ARG] = atoi(optarg);
+		}
 		if (ind == SEPARATOR_ARG) {
 			_switches[SEPARATOR_ARG]++;
 			_string_args[SEPARATOR_ARG] = optarg;
 		}
+		if (ind == UNITS_ARG) {
+			_switches[UNITS_ARG]++;
+			_string_args[UNITS_ARG] = optarg;
+		}
 		if (c == 'O' || ind == SORT_ARG) {
 			_switches[SORT_ARG]++;
 			_string_args[SORT_ARG] = optarg;
@@ -3697,6 +5223,10 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[SELECT_ARG]++;
 			_string_args[SELECT_ARG] = optarg;
 		}
+		if (ind == START_ARG) {
+			_switches[START_ARG]++;
+			_string_args[START_ARG] = optarg;
+		}
 		if (c == 'v' || ind == VERBOSE_ARG)
 			_switches[VERBOSE_ARG]++;
 		if (c == 'u' || ind == UUID_ARG) {
@@ -3752,6 +5282,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[TARGET_ARG]++;
 			_target = optarg;
 		}
+		if (ind == SEGMENTS_ARG)
+			_switches[SEGMENTS_ARG]++;
 		if (ind == INACTIVE_ARG)
 		       _switches[INACTIVE_ARG]++;
 		if (ind == INTERVAL_ARG) {
@@ -3860,6 +5392,15 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 
 	*argvp += optind;
 	*argcp -= optind;
+
+	/* preserve sub-command in argv[0] */
+	if (stats_p) {
+		(*argvp)--;
+		(*argcp)++;
+		(*argvp)[0] = stats_p;
+		(*argvp)[1] = stats_c;
+	}
+
 	return 1;
 }
 
@@ -3881,7 +5422,8 @@ static int _do_report_wait(void)
 	if (!dm_timestamp_get(_ts_start))
 		goto_out;
 
-	if (usleep(_interval / NSEC_PER_USEC)) {
+	/* FIXME: compensate for interval drift from time spent reporting. */
+	if (usleep((useconds_t) (_interval / NSEC_PER_USEC))) {
 		if (errno == EINTR)
 			log_error("Report interval interrupted by signal.");
 		if (errno == EINVAL)
@@ -3923,7 +5465,8 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
-	if (_switches[HELP_ARG]) {
+	/* let stats do its own --help handling. */
+	if (_switches[HELP_ARG] && strcmp("stats", argv[0])) {
 		if ((cmd = _find_dmsetup_command("help")))
 			goto doit;
 		goto unknown;
@@ -3950,13 +5493,30 @@ unknown:
 	if (argc < cmd->min_args + 1 ||
 	    (cmd->max_args >= 0 && argc > cmd->max_args + 1)) {
 		fprintf(stderr, "Incorrect number of arguments\n");
-		_dmsetup_usage(stderr);
+		if (!strcmp(cmd->name, "stats"))
+			_stats_usage(stderr);
+		else
+			_dmsetup_usage(stderr);
 		goto out;
 	}
 
 	if (!_switches[COLS_ARG] && !strcmp(cmd->name, "splitname"))
 		_switches[COLS_ARG]++;
 
+	/**
+	 * Unconditionally increment for "stats" commands; the only
+	 * command to not require this is non-columns "stats help".
+	 * In that case _stats_help will remove the extra count
+	 * before displaying the help message.
+	 */
+	if (!strcmp(cmd->name, "stats")) {
+		_switches[COLS_ARG]++;
+		if (!_switches[UNITS_ARG]) {
+			_switches[UNITS_ARG]++;
+			_string_args[UNITS_ARG] = (char *) "h";
+		}
+	}
+
 	if (!strcmp(cmd->name, "mangle"))
 		dm_set_name_mangling_mode(DM_STRING_MANGLING_NONE);
 
@@ -3974,10 +5534,19 @@ unknown:
 		goto out;
 
 	if (_switches[COUNT_ARG])
-		_count = _int_args[COUNT_ARG] ? : UINT32_MAX;
+		_count = ((uint32_t)_int_args[COUNT_ARG]) ? : UINT32_MAX;
 	else if (_switches[INTERVAL_ARG])
 		_count = UINT32_MAX;
 
+	if (_switches[UNITS_ARG]) {
+		_disp_factor = _factor_from_units(_string_args[UNITS_ARG],
+						  &_disp_units);
+		if (!_disp_factor) {
+			log_error("Invalid --units argument.");
+			goto out;
+		}
+	}
+
 	/*
 	 * Extract subcommand?
 	 * dmsetup <command> <subcommand> [args...]
@@ -3987,16 +5556,14 @@ unknown:
 		argc--, argv++;
 	}
 
-	if (_count > 1) {
-		_ts_start = dm_timestamp_alloc();
-		_ts_end = dm_timestamp_alloc();
-		if (!_ts_start || !_ts_end) {
-			log_error("Could not allocate timestamp objects.");
-			goto out;
-		}
-		/* Pretend we have the configured interval for the first iteration. */
-		_last_interval = _interval;
+	_ts_start = dm_timestamp_alloc();
+	_ts_end = dm_timestamp_alloc();
+	if (!_ts_start || !_ts_end) {
+		log_error("Could not allocate timestamp objects.");
+		goto out;
 	}
+	/* Pretend we have the configured interval for the first iteration. */
+	_last_interval = _interval;
 doit:
 	multiple_devices = (cmd->repeatable_cmd && argc != 2 &&
 			    (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
@@ -4005,7 +5572,8 @@ doit:
 		r = _perform_command_for_all_repeatable_args(cmd, subcommand, argc, argv, NULL, multiple_devices);
 
 		if (_report) {
-			if (_count > 1)
+			/* only output headings for repeating reports */
+			if (_int_args[COUNT_ARG] != 1)
 				dm_report_column_headings(_report);
 			dm_report_output(_report);
 
@@ -4016,6 +5584,7 @@ doit:
 					goto_out;
 			}
 		}
+
 	} while (--_count);
 
 out:
@@ -4025,6 +5594,9 @@ out:
 	if (_dtree)
 		dm_tree_free(_dtree);
 
+	dm_timestamp_destroy(_ts_start);
+	dm_timestamp_destroy(_ts_end);
+
 	dm_free(_table);
 
 	if (_initial_timestamp)


