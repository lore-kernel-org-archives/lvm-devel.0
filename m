From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:04:27 -0400
Subject: master - dmsetup: cleanup err usage
Message-ID: <201803131204.w2DC4RAT002478@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f203d4e20601f4fb840df5e3f4f9ea93025a1060
Commit:        f203d4e20601f4fb840df5e3f4f9ea93025a1060
Parent:        3b7834af17ba17f4c478937ac5cb022045bb782b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 9 20:50:43 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

dmsetup: cleanup err usage

Macro err() add '\n'.
---
 tools/dmsetup.c |   62 ++++++++++++++++++++++++++----------------------------
 1 files changed, 30 insertions(+), 32 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a394c3f..f7df581 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  * Copyright (C) 2005-2007 NEC Corporation
  *
  * This file is part of the device-mapper userspace tools.
@@ -103,8 +103,6 @@ extern char *optarg;
 /* FIXME Should be elsewhere */
 #define SECTOR_SHIFT 9L
 
-#define err(msg, x...) fprintf(stderr, msg "\n", ##x)
-
 /* program_id used for dmstats-managed statistics regions */
 #define DM_STATS_PROGRAM_ID "dmstats"
 
@@ -347,7 +345,7 @@ static int _parse_line(struct dm_task *dmt, char *buffer, const char *file,
 
 	if (sscanf(ptr, "%llu %llu %s %n",
 		   &start, &size, ttype, &n) < 3) {
-		err("Invalid format on line %d of table %s", line, file);
+		log_error("Invalid format on line %d of table %s.", line, file);
 		return 0;
 	}
 
@@ -392,7 +390,7 @@ static int _parse_file(struct dm_task *dmt, const char *file)
 	/* OK for empty stdin */
 	if (file) {
 		if (!(fp = fopen(file, "r"))) {
-			err("Couldn't open '%s' for reading", file);
+			log_error("Couldn't open '%s' for reading.", file);
 			return 0;
 		}
 	} else
@@ -401,7 +399,7 @@ static int _parse_file(struct dm_task *dmt, const char *file)
 #ifndef HAVE_GETLINE
 	buffer_size = LINE_SIZE;
 	if (!(buffer = dm_malloc(buffer_size))) {
-		err("Failed to malloc line buffer.");
+		log_error("Failed to malloc line buffer.");
 		return 0;
 	}
 
@@ -1042,7 +1040,7 @@ static int _set_task_device(struct dm_task *dmt, const char *name, int optional)
 		    !dm_task_set_minor(dmt, _int_args[MINOR_ARG]))
 			return_0;
 	} else if (!optional) {
-		fprintf(stderr, "No device specified.\n");
+		log_error("No device specified.");
 		return 0;
 	}
 
@@ -1073,20 +1071,20 @@ static int _load(CMD_ARGS)
 	const char *name = NULL;
 
 	if (_switches[NOTABLE_ARG]) {
-		err("--notable only available when creating new device\n");
+		log_error("--notable only available when creating new device.");
 		return 0;
 	}
 
 	if (!_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
 		if (!argc) {
-			err("Please specify device.\n");
+			log_error("Please specify device.");
 			return 0;
 		}
 		name = argv[0];
 		argc--;
 		argv++;
 	} else if (argc > 1) {
-		err("Too many command line arguments.\n");
+		log_error("Too many command line arguments.");
 		return 0;
 	}
 
@@ -1516,7 +1514,7 @@ static int _message(CMD_ARGS)
 	errno = 0;
 	sector = strtoull(argv[0], &endptr, 10);
 	if (errno || *endptr || endptr == argv[0]) {
-		err("invalid sector");
+		log_error("Invalid sector.");
 		goto out;
 	}
 	if (!dm_task_set_sector(dmt, sector))
@@ -1526,13 +1524,13 @@ static int _message(CMD_ARGS)
 	argv++;
 
 	if (argc <= 0)
-		err("No message supplied.\n");
+		log_error("No message supplied.");
 
 	for (i = 0; i < argc; i++)
 		sz += strlen(argv[i]) + 1;
 
 	if (!(str = dm_zalloc(sz))) {
-		err("message string allocation failed");
+		log_error("Message string allocation failed.");
 		goto out;
 	}
 
@@ -1642,7 +1640,7 @@ static uint32_t _get_cookie_value(const char *str_value)
 	value = strtoul(str_value, &p, 0);
 
 	if (errno || !value || (*p) || (value > UINT32_MAX)) {
-		err("Incorrect cookie value");
+		log_error("Incorrect cookie value.");
 		return 0;
 	}
 
@@ -2087,7 +2085,7 @@ static int _wait(CMD_ARGS)
 
 	if (!_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
 		if (!argc) {
-			err("No device specified.");
+			log_error("No device specified.");
 			return 0;
 		}
 		name = argv[0];
@@ -2191,8 +2189,8 @@ static int _error_device(CMD_ARGS)
 	name = names ? names->name : argv[0];
 
 	if (!name || !*name) {
-		err("No device specified.");
-		return_0;
+		log_error("No device specified.");
+		return 0;
 	}
 		
 	size = _get_device_size(name);
@@ -2342,7 +2340,7 @@ static int _exec_command(const char *name)
 		}
 
 		if (argc == ARGS_MAX) {
-			err("Too many args to --exec\n");
+			log_error("Too many args to --exec.");
 			argc = -1;
 			return 0;
 		}
@@ -2453,8 +2451,8 @@ static int _status(CMD_ARGS)
 		goto_out;
 
 	if (!info.exists) {
-		fprintf(stderr, "Device does not exist.\n");
-		goto_out;
+		log_error("Device does not exist.");
+		goto out;
 	}
 
 	if (!name)
@@ -4777,7 +4775,7 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 			opt_fields = _string_args[OPTIONS_ARG] + 1;
 			len = strlen(options) + strlen(opt_fields) + 2;
 			if (!(tmpopts = dm_malloc(len))) {
-				err("Failed to allocate option string.");
+				log_error("Failed to allocate option string.");
 				return 0;
 			}
 			if (dm_snprintf(tmpopts, len, "%s,%s",
@@ -4793,7 +4791,7 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 		keys = _string_args[SORT_ARG];
 		buffered = 1;
 		if (cmd && (!strcmp(cmd->name, "status") || !strcmp(cmd->name, "table"))) {
-			err("--sort is not yet supported with status and table");
+			log_error("--sort is not yet supported with status and table.");
 			goto out;
 		}
 	}
@@ -4834,7 +4832,7 @@ static int _report_init(const struct command *cmd, const char *subcommand)
 	if ((_report_type & DR_TREE) && cmd) {
 		r = _build_whole_deptree(cmd);
 		if  (!_dtree) {
-			err("Internal device dependency tree creation failed.");
+			log_error("Internal device dependency tree creation failed.");
 			goto out;
 		}
 	}
@@ -5027,7 +5025,7 @@ static int _stats_clear(CMD_ARGS)
 	}
 
 	if (!_switches[REGION_ID_ARG] && !_switches[ALL_REGIONS_ARG]) {
-		err("Please specify a --regionid or use --allregions.");
+		log_error("Please specify a --regionid or use --allregions.");
 		return 0;
 	}
 
@@ -5350,7 +5348,7 @@ static int _stats_create_file(CMD_ARGS)
 	dm_filemapd_mode_t mode;
 
 	if (names) {
-		err("Device names are not compatibile with --filemap.");
+		log_error("Device names are not compatibile with --filemap.");
 		return 0;
 	}
 
@@ -5626,12 +5624,12 @@ static int _stats_delete(CMD_ARGS)
 	}
 
 	if (_switches[REGION_ID_ARG] && _switches[GROUP_ID_ARG]) {
-		err("Please use one of --regionid and --groupid.");
+		log_error("Please use one of --regionid and --groupid.");
 		return 0;
 	}
 
 	if (!_switches[REGION_ID_ARG] && !allregions && !_switches[GROUP_ID_ARG]) {
-		err("Please specify a --regionid or --groupid, or use --allregions.");
+		log_error("Please specify a --regionid or --groupid, or use --allregions.");
 		return 0;
 	}
 
@@ -5737,7 +5735,7 @@ static int _stats_print(CMD_ARGS)
 	}
 
 	if (!_switches[REGION_ID_ARG] && !allregions) {
-		err("Please specify a --regionid or use --allregions.");
+		log_error("Please specify a --regionid or use --allregions.");
 		return 0;
 	}
 
@@ -5867,7 +5865,7 @@ static int _stats_group(CMD_ARGS)
 	}
 
 	if (!_switches[REGIONS_ARG]) {
-		err("Group requires --regions.");
+		log_error("Group requires --regions.");
 		return 0;
 	}
 
@@ -5928,7 +5926,7 @@ static int _stats_ungroup(CMD_ARGS)
 	}
 
 	if (!_switches[GROUP_ID_ARG]) {
-		err("Please specify group id.");
+		log_error("Please specify group id.");
 		return 0;
 	}
 
@@ -5981,7 +5979,7 @@ static int _stats_update_file(CMD_ARGS)
 
 
 	if (names) {
-		err("Device names are not compatibile with update_filemap.");
+		log_error("Device names are not compatibile with update_filemap.");
 		return 0;
 	}
 
@@ -5995,7 +5993,7 @@ static int _stats_update_file(CMD_ARGS)
 	}
 
 	if (!_switches[GROUP_ID_ARG]) {
-		err("--groupid is required to update a filemap group.");
+		log_error("--groupid is required to update a filemap group.");
 		return 0;
 	}
 


