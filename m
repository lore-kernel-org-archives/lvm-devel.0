From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:04:01 -0400
Subject: master - dmsetup: stderr to log_error
Message-ID: <201803131204.w2DC417m002345@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f5db7cf41203a12ab5a5973459e1a621e4df17b
Commit:        5f5db7cf41203a12ab5a5973459e1a621e4df17b
Parent:        f203d4e20601f4fb840df5e3f4f9ea93025a1060
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 12 11:40:30 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

dmsetup: stderr to log_error

---
 tools/dmsetup.c |   68 ++++++++++++++++++++++++++----------------------------
 1 files changed, 33 insertions(+), 35 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f7df581..336d4c0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -420,7 +420,7 @@ out:
 	free(buffer);
 #endif
 	if (file && fclose(fp))
-		fprintf(stderr, "%s: fclose failed: %s", file, strerror(errno));
+		log_sys_debug("fclose", file);
 
 	return r;
 }
@@ -2283,7 +2283,7 @@ static int _remove_all(CMD_ARGS)
 	if (!_num_devices)
 		return r;
 
-	fprintf(stderr, "Unable to remove %d device(s).\n", _num_devices);
+	log_error("Unable to remove %d device(s).", _num_devices);
 
 	return r;
 }
@@ -6505,7 +6505,7 @@ static int _process_tree_options(const char *options)
 		else if (!strncmp(s, "notrunc", len))
 			_tree_switches[TR_TRUNCATE] = 0;
 		else {
-			fprintf(stderr, "Tree options not recognised: %s\n", s);
+			log_error("Tree options not recognised: %s.", s);
 			return 0;
 		}
 		if (!*end)
@@ -6594,9 +6594,9 @@ static int _loop_table(char *table, size_t tlen, char *file,
 	sectors = size >> SECTOR_SHIFT;
 
 	if (_switches[VERBOSE_ARG])
-		fprintf(stderr, LOSETUP_CMD_NAME ": set loop size to %llukB "
-			"(%llu sectors)\n", (long long unsigned) sectors >> 1,
-			(long long unsigned) sectors);
+		log_error(LOSETUP_CMD_NAME ": set loop size to %llukB (%llu sectors).",
+			  (long long unsigned) sectors >> 1,
+			  (long long unsigned) sectors);
 
 #ifdef HAVE_SYS_STATVFS_H
 	if (fstatvfs(fd, &fsbuf))
@@ -6607,14 +6607,14 @@ static int _loop_table(char *table, size_t tlen, char *file,
 #endif
 
 	if (close(fd))
-		log_sys_error("close", file);
+		log_sys_debug("close", file);
 
 	if (dm_snprintf(table, tlen, "%llu %llu loop %s %llu\n", 0ULL,
 			(long long unsigned)sectors, file, (long long unsigned)off) < 0)
 		return_0;
 
 	if (_switches[VERBOSE_ARG] > 1)
-		fprintf(stderr, "Table: %s\n", table);
+		log_error("Table: %s", table);
 
 	return 1;
 
@@ -6664,33 +6664,32 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	*argcp -= optind ;
 
 	if (encrypt_loop){
-		fprintf(stderr, "%s: Sorry, cryptoloop is not yet implemented "
-				"in this version.\n", base);
+		log_error("%s: Sorry, cryptoloop is not yet implemented "
+			  "in this version.", base);
 		return 0;
 	}
 
 	if (show_all) {
-		fprintf(stderr, "%s: Sorry, show all is not yet implemented "
-				"in this version.\n", base);
+		log_error("%s: Sorry, show all is not yet implemented "
+			  "in this version.", base);
 		return 0;
 	}
 
 	if (find) {
-		fprintf(stderr, "%s: Sorry, find is not yet implemented "
-				"in this version.\n", base);
+		log_error("%s: Sorry, find is not yet implemented "
+			  "in this version.", base);
 		if (!*argcp)
 			return 0;
 	}
 
 	if (!*argcp) {
-		fprintf(stderr, "%s: Please specify loop_device.\n", base);
+		log_error("%s: Please specify loop_device.", base);
 		_usage(stderr);
 		return 0;
 	}
 
 	if (!(device_name = _parse_loop_device_name((*argvp)[0], dev_dir))) {
-		fprintf(stderr, "%s: Could not parse loop_device %s\n",
-			base, (*argvp)[0]);
+		log_error("%s: Could not parse loop_device %s", base, (*argvp)[0]);
 		_usage(stderr);
 		return 0;
 	}
@@ -6705,7 +6704,7 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	}
 
 	if (*argcp != 2) {
-		fprintf(stderr, "%s: Too few arguments\n", base);
+		log_error("%s: Too few arguments.", base);
 		_usage(stderr);
 		dm_free(device_name);
 		return 0;
@@ -6713,8 +6712,8 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 
 	/* FIXME move these to make them available to native dmsetup */
 	if (!(loop_file = _get_abspath((*argvp)[(find) ? 0 : 1]))) {
-		fprintf(stderr, "%s: Could not parse loop file name %s\n",
-			base, (*argvp)[1]);
+		log_error("%s: Could not parse loop file name %s.",
+			  base, (*argvp)[1]);
 		_usage(stderr);
 		dm_free(device_name);
 		return 0;
@@ -6723,7 +6722,7 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	_table = dm_malloc(LOOP_TABLE_SIZE);
 	if (!_table ||
 	    !_loop_table(_table, (size_t) LOOP_TABLE_SIZE, loop_file, device_name, offset)) {
-		fprintf(stderr, "Could not build device-mapper table for %s\n", (*argvp)[0]);
+		log_error("Could not build device-mapper table for %s.", (*argvp)[0]);
 		dm_free(device_name);
 		return 0;
 	}
@@ -6768,7 +6767,7 @@ static int _process_options(const char *options)
 		else if (!strncmp(s, "devname", len))
 			_dev_name_type = DN_MAP;
 		else {
-			fprintf(stderr, "Option not recognised: %s\n", s);
+			log_error("Option not recognised: %s.", s);
 			return 0;
 		}
 
@@ -6881,7 +6880,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 	_read_ahead_flags = 0;
 
 	if (!(namebase = strdup((*argvp)[0]))) {
-		fprintf(stderr, "Failed to duplicate name.\n");
+		log_error("Failed to duplicate name.");
 		return 0;
 	}
 
@@ -7216,18 +7215,17 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 
 	if ((_switches[MAJOR_ARG] && !_switches[MINOR_ARG]) ||
 	    (!_switches[MAJOR_ARG] && _switches[MINOR_ARG])) {
-		fprintf(stderr, "Please specify both major number and "
-				"minor number.\n");
+		log_error("Please specify both major number and minor number.");
 		return 0;
 	}
 
 	if (_switches[TABLE_ARG] && _switches[NOTABLE_ARG]) {
-		fprintf(stderr, "--table and --notable are incompatible.\n");
+		log_error("--table and --notable are incompatible.");
 		return 0;
 	}
 
 	if (_switches[ADD_NODE_ON_RESUME_ARG] && _switches[ADD_NODE_ON_CREATE_ARG]) {
-		fprintf(stderr, "--addnodeonresume and --addnodeoncreate are incompatible.\n");
+		log_error("--addnodeonresume and --addnodeoncreate are incompatible.");
 		return 0;
 	}
 
@@ -7257,7 +7255,7 @@ static int _perform_command_for_all_repeatable_args(CMD_ARGS)
 {
 	do {
 		if (!cmd->fn(cmd, subcommand, argc, argv++, NULL, multiple_devices)) {
-			fprintf(stderr, "Command failed\n");
+			log_error("Command failed.");
 			return 0;
 		}
 	} while (cmd->repeatable_cmd && argc-- > 1);
@@ -7280,17 +7278,17 @@ int main(int argc, char **argv)
 
 	(void) setlocale(LC_ALL, "");
 
-	dev_dir = getenv (DM_DEV_DIR_ENV_VAR_NAME);
+	dev_dir = getenv(DM_DEV_DIR_ENV_VAR_NAME);
 	if (dev_dir && *dev_dir) {
 		if (!dm_set_dev_dir(dev_dir)) {
-			fprintf(stderr, "Invalid DM_DEV_DIR environment variable value.\n");
+			log_error("Invalid DM_DEV_DIR environment variable value.");
 			goto out;
 		}
 	} else
 		dev_dir = DEFAULT_DM_DEV_DIR;
 
 	if (!_process_switches(&argc, &argv, dev_dir)) {
-		fprintf(stderr, "Couldn't process command line.\n");
+		log_error("Couldn't process command line.");
 		goto out;
 	}
 
@@ -7327,14 +7325,14 @@ int main(int argc, char **argv)
 
 	if (!(cmd = _find_dmsetup_command(_command))) {
 unknown:
-		fprintf(stderr, "Unknown command\n");
+		log_error("Unknown command.");
 		_usage(stderr);
 		goto out;
 	}
 
 	if (argc < cmd->min_args ||
 	    (cmd->max_args >= 0 && argc > cmd->max_args)) {
-		fprintf(stderr, "Incorrect number of arguments\n");
+		log_error("Incorrect number of arguments.");
 		_usage(stderr);
 		goto out;
 	}
@@ -7354,7 +7352,7 @@ unknown:
 		dm_set_name_mangling_mode(DM_STRING_MANGLING_NONE);
 
 	if (!_process_options(_string_args[OPTIONS_ARG])) {
-		fprintf(stderr, "Couldn't process command line.\n");
+		log_error("Couldn't process command line.");
 		goto out;
 	}
 
@@ -7380,7 +7378,7 @@ unknown:
 		_selection_cmd = cmd;
 		_switches[COLS_ARG] = 1;
 		if (!(cmd = _find_dmsetup_command("info"))) {
-			fprintf(stderr, "Internal error finding dmsetup info command struct.\n");
+			log_error(INTERNAL_ERROR "finding dmsetup info command struct.");
 			goto out;
 		}
 	}


