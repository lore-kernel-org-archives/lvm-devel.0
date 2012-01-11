From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Jan 2012 12:46:21 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in tools/dms ...
Message-ID: <20120111124621.5095.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-01-11 12:46:20

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Support different device name types on output of dmsetup deps, ls and info -c command.
	
	Add 'blkdevname' and 'blkdevs_used' field to dmsetup info -c -o.
	Add 'blkdevname' option to dmsetup ls --tree to see block device names.
	Add '-o options' to dmsetup deps and ls to select device name type on output.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.530&r2=1.531
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.170&r2=1.171

--- LVM2/WHATS_NEW_DM	2012/01/11 12:34:44	1.530
+++ LVM2/WHATS_NEW_DM	2012/01/11 12:46:19	1.531
@@ -1,5 +1,8 @@
 Version 1.02.68 -
 ==================================
+  Add 'blkdevname' and 'blkdevs_used' field to dmsetup info -c -o.
+  Add 'blkdevname' option to dmsetup ls --tree to see block device names.
+  Add '-o options' to dmsetup deps and ls to select device name type on output.
   Add dm_device_get_name to get map name or block device name for given devno.
   Remove empty devices when clearing left-over inactive tables in deptree.
   Add dm_uuid_prefix/dm_set_uuid_prefix to override hard-coded LVM- prefix.
--- LVM2/man/dmsetup.8.in	2012/01/09 12:28:47	1.48
+++ LVM2/man/dmsetup.8.in	2012/01/11 12:46:20	1.49
@@ -20,6 +20,8 @@
 .RE
 .br
 .B dmsetup deps
+.RB [ \-o
+.IR options ]
 .RI [ device_name ]
 .br
 .B dmsetup help
@@ -51,10 +53,9 @@
 .IR target_type ]
 .RB [ \-\-exec
 .IR command ]
-.RB [ \-\-tree
-.RS
+.RB [ \-\-tree ]
 .RB [ \-o
-.IR options ]]
+.IR options ]
 .RE
 .br
 .B dmsetup message
@@ -268,10 +269,14 @@
 .br
 .TP
 .B deps
+.RB [ \-o
+.IR options ]
 .RI [ device_name ]
 .br
-Outputs a list of (major, minor) pairs for devices referenced by the
-live table for the specified device.
+Outputs a list of devices referenced by the live table for the specified
+device. Device names on output can be customised by following options:
+devno (major and minor pair, used by default), blkdevname (block device name),
+devname (map name for device-mapper devices, equal to blkdevname otherwise).
 .br
 .TP
 .B help
@@ -323,17 +328,20 @@
 .IR target_type ]
 .RB [ \-\-exec
 .IR command ]
-.RB [ \-\-tree
+.RB [ \-\-tree ]
 .RB [ \-o
-.IR options ]]
+.IR options ]
 .br
 List device names.  Optionally only list devices that have at least
 one target of the specified type.  Optionally execute a command for
 each device.  The device name is appended to the supplied command.
+Device names on output can be customised by following options: devno (major
+and minor pair, used by default), blkdevname (block device name),
+devname (map name for device-mapper devices, equal to blkdevname otherwise).
 --tree displays dependencies between devices as a tree.
 It accepts a comma-separate list of options.
 Some specify the information displayed against each node:
-device/nodevice; active, open, rw, uuid.
+device/nodevice; blkdevname; active, open, rw, uuid.
 Others specify how the tree is displayed:
 ascii, utf, vt100; compact, inverted, notrunc.
 .br
--- LVM2/tools/dmsetup.c	2011/12/01 14:57:30	1.170
+++ LVM2/tools/dmsetup.c	2012/01/11 12:46:20	1.171
@@ -168,6 +168,12 @@
 	DR_NAME = 16
 } report_type_t;
 
+typedef enum {
+	DN_DEVNO,	/* Major and minor number pair */
+	DN_BLK,		/* Block device name (e.g. dm-0) */
+	DN_MAP		/* Map name (for dm devices only, equal to DN_BLK otherwise) */
+} dev_name_t;
+
 static int _switches[NUM_SWITCHES];
 static int _int_args[NUM_SWITCHES];
 static char *_string_args[NUM_SWITCHES];
@@ -182,6 +188,7 @@
 static struct dm_tree *_dtree;
 static struct dm_report *_report;
 static report_type_t _report_type;
+static dev_name_t _dev_name_type;
 
 /*
  * Commands
@@ -1767,6 +1774,8 @@
 	struct dm_task *dmt;
 	struct dm_info info;
 	char *name = NULL;
+	char dev_name[PATH_MAX];
+	int major, minor;
 
 	if (names)
 		name = names->name;
@@ -1813,10 +1822,17 @@
 		printf("%s: ", name);
 	printf("%d dependencies\t:", deps->count);
 
-	for (i = 0; i < deps->count; i++)
-		printf(" (%d, %d)",
-		       (int) MAJOR(deps->device[i]),
-		       (int) MINOR(deps->device[i]));
+	for (i = 0; i < deps->count; i++) {
+		major = (int) MAJOR(deps->device[i]);
+		minor = (int) MINOR(deps->device[i]);
+
+		if ((_dev_name_type == DN_BLK || _dev_name_type == DN_MAP) &&
+		    dm_device_get_name(major, minor, _dev_name_type == DN_BLK,
+				       dev_name, PATH_MAX))
+			printf(" (%s)", dev_name);
+		else
+			printf(" (%d, %d)", major, minor);
+	}
 	printf("\n");
 
 	if (multiple_devices && _switches[VERBOSE_ARG])
@@ -1831,8 +1847,16 @@
 
 static int _display_name(CMD_ARGS)
 {
-	printf("%s\t(%d, %d)\n", names->name,
-	       (int) MAJOR(names->dev), (int) MINOR(names->dev));
+	char dev_name[PATH_MAX];
+
+	if ((_dev_name_type == DN_BLK || _dev_name_type == DN_MAP) &&
+	    dm_device_get_name((int) MAJOR(names->dev), (int) MINOR(names->dev),
+			       _dev_name_type == DN_BLK, dev_name, PATH_MAX))
+		printf("%s\t(%s)\n", names->name, dev_name);
+	else
+		printf("%s\t(%d:%d)\n", names->name,
+					(int) MAJOR(names->dev),
+					(int) MINOR(names->dev));
 
 	return 1;
 }
@@ -1843,6 +1867,7 @@
 
 enum {
 	TR_DEVICE=0,	/* display device major:minor number */
+	TR_BLKDEVNAME,	/* display device kernel name */
 	TR_TABLE,
 	TR_STATUS,
 	TR_ACTIVE,
@@ -2062,6 +2087,7 @@
 	const char *name;
 	const struct dm_info *info;
 	int first_on_line = 0;
+	char dev_name[PATH_MAX];
 
 	/* Sub-tree for targets has 2 more depth */
 	if (depth + 2 > MAX_DEPTH)
@@ -2069,7 +2095,8 @@
 
 	name = dm_tree_node_get_name(node);
 
-	if ((!name || !*name) && !_tree_switches[TR_DEVICE])
+	if ((!name || !*name) &&
+	    (!_tree_switches[TR_DEVICE] && !_tree_switches[TR_BLKDEVNAME]))
 		return;
 
 	/* Indicate whether there are more nodes at this depth */
@@ -2094,6 +2121,13 @@
 
 	info = dm_tree_node_get_info(node);
 
+	if (_tree_switches[TR_BLKDEVNAME] &&
+	    dm_device_get_name(info->major, info->minor, 1, dev_name, PATH_MAX)) {
+		_out_string(name ? " <" : "<");
+		_out_string(dev_name);
+		_out_char('>');
+	}
+
 	if (_tree_switches[TR_DEVICE]) {
 		_out_string(name ? " (" : "(");
 		(void) _out_int(info->major);
@@ -2244,6 +2278,24 @@
 	return dm_report_field_uint32(rh, field, &value);
 }
 
+static int _dm_blk_name_disp(struct dm_report *rh,
+			     struct dm_pool *mem __attribute__((unused)),
+			     struct dm_report_field *field, const void *data,
+			     void *private __attribute__((unused)))
+{
+	char dev_name[PATH_MAX];
+	const char *s = dev_name;
+	const struct dm_info *info = data;
+
+	if (!dm_device_get_name(info->major, info->minor, 1, dev_name, PATH_MAX)) {
+		log_error("Could not resolve block device name for %d:%d.",
+			  info->major, info->minor);
+		return 0;
+	}
+
+	return dm_report_field_string(rh, field, &s);
+}
+
 static int _dm_info_status_disp(struct dm_report *rh,
 				struct dm_pool *mem __attribute__((unused)),
 				struct dm_report_field *field, const void *data,
@@ -2323,7 +2375,7 @@
 			       struct dm_report_field *field, const void *data,
 			       void *private)
 {
-	char buf[DM_MAX_TYPE_NAME], *repstr;
+	char buf[PATH_MAX], *repstr;
 	const struct dm_info *info = data;
 
 	if (!dm_pool_begin_object(mem, 8)) {
@@ -2331,10 +2383,17 @@
 		return 0;
 	}
 
-	if (dm_snprintf(buf, sizeof(buf), "%d:%d",
-			info->major, info->minor) < 0) {
-		log_error("dm_pool_alloc failed");
-		goto out_abandon;
+	if (private) {
+		if (!dm_device_get_name(info->major, info->minor,
+					1, buf, PATH_MAX))
+			goto out_abandon;
+	}
+	else {
+		if (dm_snprintf(buf, sizeof(buf), "%d:%d",
+				info->major, info->minor) < 0) {
+			log_error("dm_pool_alloc failed");
+			goto out_abandon;
+		}
 	}
 
 	if (!dm_pool_grow_object(mem, buf, strlen(buf) + 1)) {
@@ -2475,13 +2534,14 @@
 	return dm_report_field_int(rh, field, &num_parent);
 }
 
-static int _dm_deps_disp(struct dm_report *rh, struct dm_pool *mem,
-			 struct dm_report_field *field, const void *data,
-			 void *private)
+static int _dm_deps_disp_common(struct dm_report *rh, struct dm_pool*mem,
+				struct dm_report_field *field, const void *data,
+				void *private, int disp_blk_dev_names)
 {
 	const struct dm_deps *deps = data;
+	char buf[PATH_MAX], *repstr;
+	int major, minor;
 	unsigned i;
-	char buf[DM_MAX_TYPE_NAME], *repstr;
 
 	if (!dm_pool_begin_object(mem, 16)) {
 		log_error("dm_pool_begin_object failed");
@@ -2489,16 +2549,27 @@
 	}
 
 	for (i = 0; i < deps->count; i++) {
-		if (dm_snprintf(buf, sizeof(buf), "%d:%d",
-		       (int) MAJOR(deps->device[i]),
-		       (int) MINOR(deps->device[i])) < 0) {
+		major = (int) MAJOR(deps->device[i]);
+		minor = (int) MINOR(deps->device[i]);
+
+		if (disp_blk_dev_names) {
+			if (!dm_device_get_name(major, minor, 1, buf, PATH_MAX)) {
+				log_error("Could not resolve block device "
+					  "name for %d:%d.", major, minor);
+				goto out_abandon;
+			}
+		}
+		else if (dm_snprintf(buf, sizeof(buf), "%d:%d",
+				     major, minor) < 0) {
 			log_error("dm_snprintf failed");
 			goto out_abandon;
 		}
+
 		if (!dm_pool_grow_object(mem, buf, 0)) {
 			log_error("dm_pool_grow_object failed");
 			goto out_abandon;
 		}
+
 		if (i + 1 < deps->count && !dm_pool_grow_object(mem, ",", 1)) {
 			log_error("dm_pool_grow_object failed");
 			goto out_abandon;
@@ -2519,6 +2590,20 @@
 	return 0;
 }
 
+static int _dm_deps_disp(struct dm_report *rh, struct dm_pool *mem,
+			 struct dm_report_field *field, const void *data,
+			 void *private)
+{
+	return _dm_deps_disp_common(rh, mem, field, data, private, 0);
+}
+
+static int _dm_deps_blk_names_disp(struct dm_report *rh, struct dm_pool *mem,
+				   struct dm_report_field *field,
+				   const void *data, void *private)
+{
+	return _dm_deps_disp_common(rh, mem, field, data, private, 1);
+}
+
 static int _dm_subsystem_disp(struct dm_report *rh,
 			       struct dm_pool *mem __attribute__((unused)),
 			       struct dm_report_field *field, const void *data,
@@ -2603,6 +2688,7 @@
 /* FIXME Next one should be INFO */
 FIELD_F(TASK, NUM, "RAhead", 6, dm_read_ahead, "read_ahead", "Read ahead in sectors.")
 
+FIELD_F(INFO, STR, "BlkDevName", 16, dm_blk_name, "blkdevname", "Name of block device.")
 FIELD_F(INFO, STR, "Stat", 4, dm_info_status, "attr", "(L)ive, (I)nactive, (s)uspended, (r)ead-only, read-(w)rite.")
 FIELD_F(INFO, STR, "Tables", 6, dm_info_table_loaded, "tables_loaded", "Which of the live and inactive table slots are filled.")
 FIELD_F(INFO, STR, "Suspended", 9, dm_info_suspended, "suspended", "Whether the device is suspended.")
@@ -2617,6 +2703,7 @@
 FIELD_O(DEPS, dm_deps, NUM, "#Devs", count, 5, int32, "device_count", "Number of devices used by this one.")
 FIELD_F(TREE, STR, "DevNames", 8, dm_deps_names, "devs_used", "List of names of mapped devices used by this one.")
 FIELD_F(DEPS, STR, "DevNos", 6, dm_deps, "devnos_used", "List of device numbers of devices used by this one.")
+FIELD_F(DEPS, STR, "BlkDevNames", 16, dm_deps_blk_names, "blkdevs_used", "List of names of block devices used by this one.")
 
 FIELD_F(TREE, NUM, "#Refs", 5, dm_tree_parents_count, "device_ref_count", "Number of mapped devices referencing this one.")
 FIELD_F(TREE, STR, "RefNames", 8, dm_tree_parents_names, "names_using_dev", "List of names of mapped devices using this one.")
@@ -2785,9 +2872,9 @@
 	{"reload", "<device> [<table_file>]", 0, 2, 0, _load},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, _rename},
 	{"message", "<device> <sector> <message>", 2, -1, 0, _message},
-	{"ls", "[--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, 0, _ls},
+	{"ls", "[--target <target_type>] [--exec <command>] [-o options] [--tree]", 0, 0, 0, _ls},
 	{"info", "[<device>]", 0, -1, 1, _info},
-	{"deps", "[<device>]", 0, -1, 1, _deps},
+	{"deps", "[-o options] [<device>]", 0, -1, 1, _deps},
 	{"status", "[<device>] [--target <target_type>]", 0, -1, 1, _status},
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, 0, _wait},
@@ -2823,8 +2910,9 @@
 		     "-j <major> -m <minor>\n");
 	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
 	fprintf(out, "Table_file contents may be supplied on stdin.\n");
-	fprintf(out, "Tree options are: ascii, utf, vt100; compact, inverted, notrunc;\n"
-		     "                  [no]device, active, open, rw and uuid.\n");
+	fprintf(out, "Options are: devno, devname, blkdevname.\n");
+	fprintf(out, "Tree specific options are: ascii, utf, vt100; compact, inverted, notrunc;\n"
+		     "                           blkdevname, [no]device, active, open, rw and uuid.\n");
 	fprintf(out, "\n");
 }
 
@@ -2888,6 +2976,8 @@
 			;
 		if (!strncmp(s, "device", len))
 			_tree_switches[TR_DEVICE] = 1;
+		else if (!strncmp(s, "blkdevname", len))
+			_tree_switches[TR_BLKDEVNAME] = 1;
 		else if (!strncmp(s, "nodevice", len))
 			_tree_switches[TR_DEVICE] = 0;
 		else if (!strncmp(s, "status", len))
@@ -3157,6 +3247,50 @@
 	return 1;
 }
 
+static int _process_options(const char *options)
+{
+	const char *s, *end;
+	size_t len;
+
+	/* Tree options are processed separately. */
+	if (_switches[TREE_ARG])
+		return _process_tree_options(_string_args[OPTIONS_ARG]);
+
+	/* Column options are processed separately by _report_init (called later). */
+	if (_switches[COLS_ARG])
+		return 1;
+
+	/* No options specified. */
+	if (!_switches[OPTIONS_ARG])
+		return 1;
+
+	/* Set defaults. */
+	_dev_name_type = DN_DEVNO;
+
+	/* Parse. */
+	for (s = options; s && *s; s++) {
+		len = 0;
+		for (end = s; *end && *end != ','; end++, len++)
+			;
+		if (!strncmp(s, "devno", len))
+			_dev_name_type = DN_DEVNO;
+		else if (!strncmp(s, "blkdevname", len))
+			_dev_name_type = DN_BLK;
+		else if (!strncmp(s, "devname", len))
+			_dev_name_type = DN_MAP;
+		else {
+			fprintf(stderr, "Option not recognised: %s\n", s);
+			return 0;
+		}
+
+		if (!*end)
+			break;
+		s = end;
+	}
+
+	return 1;
+}
+
 static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 {
 	char *base, *namebase, *s;
@@ -3402,7 +3536,7 @@
 		return 0;
 	}
 
-	if (_switches[TREE_ARG] && !_process_tree_options(_string_args[OPTIONS_ARG]))
+	if (!_process_options(_string_args[OPTIONS_ARG]))
 		return 0;
 
 	if (_switches[TABLE_ARG] && _switches[NOTABLE_ARG]) {


