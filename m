From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 31 Jul 2015 21:00:26 +0000 (UTC)
Subject: master - dmsetup: Add --count and --interval to reports.
Message-ID: <20150731210026.361C560D06@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a161e29c59e01605401c9096f5ad5ace2ae03d9a
Commit:        a161e29c59e01605401c9096f5ad5ace2ae03d9a
Parent:        72f754e2bc571ada133057c5a248162dc349cf93
Author:        Bryn M. Reeves <breeves@redhat.com>
AuthorDate:    Fri Jul 31 21:59:34 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 31 21:59:34 2015 +0100

dmsetup: Add --count and --interval to reports.

For example, to monitor active devices every second you can now run
dmsetup info -c --count 0.
---
 WHATS_NEW_DM                        |    2 +
 libdm/.exported_symbols.DM_1_02_104 |    5 +++
 libdm/libdevmapper.h                |   44 ++++++++++++++++++++++++
 libdm/libdm-report.c                |   44 ++++++++++++++++++++++++
 man/dmsetup.8.in                    |   18 ++++++++++
 tools/dmsetup.c                     |   64 ++++++++++++++++++++++++++++++-----
 6 files changed, 168 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 81acfe9..2a006db 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.104 -
 =================================
+  Add dmsetup --interval and --count to repeat reports at specified intervals.
+  Add report interval and waiting functions to libdevmapper.
   Add dm_timestamp functions to libdevmapper.
 
 Version 1.02.103 - 24th July 2015
diff --git a/libdm/.exported_symbols.DM_1_02_104 b/libdm/.exported_symbols.DM_1_02_104
index 9fafa48..815c689 100644
--- a/libdm/.exported_symbols.DM_1_02_104
+++ b/libdm/.exported_symbols.DM_1_02_104
@@ -1,3 +1,8 @@
+dm_report_set_interval_ms
+dm_report_set_interval_ns
+dm_report_get_interval_ms
+dm_report_get_interval_ns
+dm_report_wait
 dm_size_to_string
 dm_timestamp_alloc
 dm_timestamp_compare
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 001d4c0..11ba0a3 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1928,6 +1928,50 @@ int dm_report_field_percent(struct dm_report *rh, struct dm_report_field *field,
 void dm_report_field_set_value(struct dm_report_field *field, const void *value,
 			       const void *sortvalue);
 
+/*
+ * Set an interval (in nanoseconds) for this dm_report object that will
+ * be used by any subsequent call to dm_report_wait_interval. This is
+ * only useful for repeating reports (e.g. statistics).
+ *
+ * The default value is zero: no interval.
+ */
+void dm_report_set_interval_ns(struct dm_report *rh, uint64_t interval_ns);
+
+/*
+ * Set an interval in milliseconds for this dm_report object that will
+ * be used by any subsequent call to dm_report_wait. This is only
+ * useful for repeating reports (e.g. statistics).
+ *
+ * The default value is zero: no interval.
+ */
+void dm_report_set_interval_ms(struct dm_report *rh, uint64_t interval_ms);
+
+/*
+ * Retrieve the configured interval of the dm_report handle rh in
+ * nanoseconds.
+ */
+uint64_t dm_report_get_interval_ns(struct dm_report *rh);
+
+/*
+ * Retrieve the configured interval of the dm_report handle rh in
+ * milliseconds.
+ */
+uint64_t dm_report_get_interval_ms(struct dm_report *rh);
+
+/*
+ * Suspend the calling thread until the current reporting interval
+ * expires. When this function returns the caller should obtain updated
+ * report data and call dm_report_object() and dm_report_output() as
+ * necessary in order to produce the new interval's reporting output.
+ *
+ * Delivery of a non-blocked signal to the thread carrying out the
+ * wait will cause the function to return prematurely with an error.
+ *
+ * Attempting to wait on a report that has no interval set is also
+ * treated as an error.
+ */
+int dm_report_wait(struct dm_report *rh);
+
 /*************************
  * config file parse/print
  *************************/
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 34374bb..5ae994d 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -43,6 +43,8 @@ struct dm_report {
 	uint32_t flags;
 	const char *separator;
 
+	uint64_t interval_ns;	/* Reporting interval in nanoseconds */
+
 	uint32_t keys_count;
 
 	/* Ordered list of fields needed for this report */
@@ -4210,3 +4212,45 @@ int dm_report_output(struct dm_report *rh)
 	else
 		return _output_as_columns(rh);
 }
+
+#define NSEC_PER_USEC	UINT64_C(1000)
+#define NSEC_PER_MSEC	UINT64_C(1000000)
+#define NSEC_PER_SEC	UINT64_C(1000000000)
+
+void dm_report_set_interval_ns(struct dm_report *rh, uint64_t interval_ns)
+{
+	rh->interval_ns = interval_ns;
+}
+
+void dm_report_set_interval_ms(struct dm_report *rh, uint64_t interval_ms)
+{
+	rh->interval_ns = interval_ms * NSEC_PER_MSEC;
+}
+
+uint64_t dm_report_get_interval_ns(struct dm_report *rh)
+{
+	return rh->interval_ns;
+}
+
+uint64_t dm_report_get_interval_ms(struct dm_report *rh)
+{
+	return (rh->interval_ns / NSEC_PER_MSEC);
+}
+
+int dm_report_wait(struct dm_report *rh)
+{
+	int r = 1;
+
+	if (!rh->interval_ns)
+		return_0;
+
+	if (usleep(rh->interval_ns / NSEC_PER_USEC)) {
+		if (errno == EINTR)
+			log_error("Report interval interrupted by signal.");
+		if (errno == EINVAL)
+			log_error("Report interval too short.");
+		r = 0;
+	}
+
+	return r;
+}
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index 57fbdf9..14e393a 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -42,6 +42,10 @@ dmsetup \(em low level logical volume management
 .IR sort_fields ]
 .RB [ \-S | \-\-select
 .IR Selection ]
+.RB [ \-\-interval
+.IR seconds ]
+.RB [ \-\-count
+.IR count ]
 .RI [ device_name ]
 .RE
 .br
@@ -187,6 +191,10 @@ In some cases these checks may slow down operations noticeably.
 .BR \-c | \-C | \-\-columns
 Display output in columns rather than as Field: Value lines.
 .TP
+.B \-\-count \fIcount
+Specify the number of times to repeat a report. Set this to zero
+continue until interrupted.  The default interval is one second.
+.TP
 .BR \-h | \-\-help
 Outputs a summary of the commands available, optionally including
 the list of report fields (synonym with \fBhelp\fP command).
@@ -196,6 +204,12 @@ When returning any table information from the kernel report on the
 inactive table instead of the live table.
 Requires kernel driver version 4.16.0 or above.
 .TP
+.B \-\-interval \fIseconds
+Specify the interval in seconds between successive iterations for
+repeating reports. If \-\-interval is specified but \-\-count is not,
+reports will continue to repeat until interrupted.
+The default interval is one second.
+.TP
 .IR \fB\-\-manglename \ { none | hex | auto }
 Mangle any character not on a whitelist using mangling_mode when
 processing device-mapper device names and UUIDs. The names and UUIDs
@@ -355,6 +369,10 @@ Outputs some brief information about the device in the form:
 .IR fields ]
 .RB [ \-O | \-\-sort
 .IR sort_fields ]
+.RB [ \-\-interval
+.IR seconds ]
+.RB [ \-\-count
+.IR count ]
 .RI [ device_name ]
 .br
 Output you can customise.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f36119f..4b23d72 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -111,6 +111,7 @@ enum {
 	ADD_NODE_ON_RESUME_ARG,
 	CHECKS_ARG,
 	COLS_ARG,
+	COUNT_ARG,
 	DEFERRED_ARG,
 	SELECT_ARG,
 	EXEC_ARG,
@@ -118,6 +119,7 @@ enum {
 	GID_ARG,
 	HELP_ARG,
 	INACTIVE_ARG,
+	INTERVAL_ARG,
 	MANGLENAME_ARG,
 	MAJOR_ARG,
 	MINOR_ARG,
@@ -182,6 +184,11 @@ static struct dm_tree *_dtree;
 static struct dm_report *_report;
 static report_type_t _report_type;
 static dev_name_t _dev_name_type;
+static uint32_t _count = 1; /* count of repeating reports */
+
+#define NSEC_PER_USEC	UINT64_C(1000)
+#define NSEC_PER_MSEC	UINT64_C(1000000)
+#define NSEC_PER_SEC	UINT64_C(1000000000)
 
 /*
  * Commands
@@ -2845,6 +2852,7 @@ static int _report_init(const struct command *cmd)
 	int aligned = 1, headings = 1, buffered = 1, field_prefixes = 0;
 	int quoted = 1, columns_as_rows = 0;
 	uint32_t flags = 0;
+	uint32_t interval;
 	size_t len = 0;
 	int r = 0;
 
@@ -2936,6 +2944,11 @@ static int _report_init(const struct command *cmd)
 		goto out;
 	}
 
+	/* Default interval is 1 second. */
+	interval = _switches[INTERVAL_ARG] ? _int_args[INTERVAL_ARG] : 1;
+
+	dm_report_set_interval_ns(_report, NSEC_PER_SEC * interval);
+
 	if (field_prefixes)
 		dm_report_set_output_field_name_prefix(_report, "dm_");
 
@@ -3110,6 +3123,7 @@ static void _dmsetup_usage(FILE *out)
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [-S|--select <selection>] [--nameprefixes] [--noheadings]\n"
+		"        [--count <count>] [--interval <seconds>]\n"
 		"        [--separator <separator>]\n\n");
 	for (i = 0; _dmsetup_commands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _dmsetup_commands[i].name, _dmsetup_commands[i].help);
@@ -3523,6 +3537,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"readonly", 0, &ind, READ_ONLY},
 		{"checks", 0, &ind, CHECKS_ARG},
 		{"columns", 0, &ind, COLS_ARG},
+		{"count", 1, &ind, COUNT_ARG},
 		{"deferred", 0, &ind, DEFERRED_ARG},
 		{"select", 1, &ind, SELECT_ARG},
 		{"exec", 1, &ind, EXEC_ARG},
@@ -3530,6 +3545,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"gid", 1, &ind, GID_ARG},
 		{"help", 0, &ind, HELP_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
+		{"interval", 1, &ind, INTERVAL_ARG},
 		{"manglename", 1, &ind, MANGLENAME_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
@@ -3674,6 +3690,14 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 			_switches[ADD_NODE_ON_CREATE_ARG]++;
 		if (ind == CHECKS_ARG)
 			_switches[CHECKS_ARG]++;
+		if (ind == COUNT_ARG) {
+			_switches[COUNT_ARG]++;
+			_int_args[COUNT_ARG] = atoi(optarg);
+			if (_int_args[COUNT_ARG] < 0) {
+				log_error("Count must be zero or greater.");
+				return 0;
+			}
+		}
 		if (ind == UDEVCOOKIE_ARG) {
 			_switches[UDEVCOOKIE_ARG]++;
 			_udev_cookie = _get_cookie_value(optarg);
@@ -3709,6 +3733,14 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		}
 		if (ind == INACTIVE_ARG)
 		       _switches[INACTIVE_ARG]++;
+		if (ind == INTERVAL_ARG) {
+			_switches[INTERVAL_ARG]++;
+			_int_args[INTERVAL_ARG] = atoi(optarg);
+			if (_int_args[INTERVAL_ARG] <= 0) {
+				log_error("Interval must be a positive integer.");
+				return 0;
+			}
+		}
 		if (ind == MANGLENAME_ARG) {
 			_switches[MANGLENAME_ARG]++;
 			if (!strcasecmp(optarg, "none"))
@@ -3880,13 +3912,18 @@ unknown:
 		goto out;
 	}
 
-	if (_switches[COLS_ARG] && !_report_init(cmd))
+#ifdef UDEV_SYNC_SUPPORT
+	if (!_set_up_udev_support(dev_dir))
 		goto out;
+#endif
 
-	#ifdef UDEV_SYNC_SUPPORT
-	if (!_set_up_udev_support(dev_dir))
+	if (_switches[COLS_ARG] && !_report_init(cmd))
 		goto out;
-	#endif
+
+	if (_switches[COUNT_ARG])
+		_count = _int_args[COUNT_ARG] ? : UINT32_MAX;
+	else if (_switches[INTERVAL_ARG])
+		_count = UINT32_MAX;
 
 	/*
 	 * Extract subcommand?
@@ -3897,17 +3934,26 @@ unknown:
 		argc--, argv++;
 	}
 
-      doit:
+doit:
 	multiple_devices = (cmd->repeatable_cmd && argc != 2 &&
 			    (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
 
-	r = _perform_command_for_all_repeatable_args(cmd, subcommand, argc, argv, NULL, multiple_devices);
+	do {
+		r = _perform_command_for_all_repeatable_args(cmd, subcommand, argc, argv, NULL, multiple_devices);
+
+		if (_report) {
+			dm_report_output(_report);
+
+			if (_count > 1) {
+				printf("\n");
+				dm_report_wait(_report);
+			}
+		}
+	} while (--_count);
 
 out:
-	if (_report) {
-		dm_report_output(_report);
+	if (_report)
 		dm_report_free(_report);
-	}
 
 	if (_dtree)
 		dm_tree_free(_dtree);


