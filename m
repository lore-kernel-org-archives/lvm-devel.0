From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 4 Aug 2017 14:40:57 -0400
Subject: master - dmsetup: Add --concise to dmsetup create.
Message-ID: <201708041840.v74IevVS028499@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=827be01758ec5adb7b9d5ea75b658092adc65534
Commit:        827be01758ec5adb7b9d5ea75b658092adc65534
Parent:        e6afe9e7820da5d5086dbcf82532bb9d0daafb00
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 4 19:38:34 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 4 19:38:34 2017 +0100

dmsetup: Add --concise to dmsetup create.

Add the new concise format to dmsetup create, either as a single
command-line parameter or from stdin.

Based on patches submitted by
Enric Balletbo i Serra <enric.balletbo@collabora.com>.
---
 WHATS_NEW_DM       |    1 +
 man/dmsetup.8_main |   72 +++++++++++++++-
 tools/dmsetup.c    |  253 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 316 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 514973b..d3cc78c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.143 - 
 =================================
+  Add --concise to dmsetup create for many devices with tables in one command.
   Accept minor number without major in library when it knows dm major number.
   Introduce single-line concise table output format: dmsetup table --concise
 
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index c218f6c..1e778ad 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -36,6 +36,17 @@ dmsetup \(em low level logical volume management
 .
 .HP
 .B dmsetup
+.de CMD_CREATE_CONCISE
+.  ad l
+.  BR create
+.  BR --concise
+.  RI [ concise_device_specification ]
+.  ad b
+..
+.CMD_CREATE_CONCISE
+.
+.HP
+.B dmsetup
 .de CMD_DEPS
 .  ad l
 .  BR deps
@@ -621,6 +632,16 @@ device the node \fI/dev/mapper/device_name\fP is created.
 See below for more information on the table format.
 .
 .HP
+.CMD_CREATE_CONCISE
+.br
+Creates one or more devices from a concise device specification.
+Each device is specified by a comma-separated list: name, uuid, minor number, flags, comma-separated table lines.
+Flags defaults to read-write (rw) or may be read-only (ro).
+Uuid, minor number and flags are optional so those fields may be empty.
+A semi-colon separates specifications of different devices.
+Use a backslash to escape the following character, for example a comma or semi-colon in a name or table. See also CONCISE FORMAT below.
+. 
+.HP
 .CMD_DEPS
 .br
 Outputs a list of devices referenced by the live table for the specified
@@ -828,7 +849,7 @@ displayed always.
 With \fB--concise\fP, the output is presented concisely on a single line.
 Commas then separate the name, uuid, minor device number, flags ('ro' or 'rw')
 and the table (if present). Semi-colons separate devices. Backslashes escape
-any commas, semi-colons or backslashes.
+any commas, semi-colons or backslashes.  See CONCISE FORMAT below.
 .
 .HP
 .CMD_TARGETS
@@ -1001,6 +1022,55 @@ documentation directory for the device-mapper package.)
 .br
 2056320 2875602 linear /dev/hdb 1028160
 .
+.SH CONCISE FORMAT
+.
+A concise representation of one of more devices.
+.sp
+.br
+- A comma separates the fields of each device.
+.br
+- A semi-colon separates devices.
+.TP
+The representation of a device takes the form:
+.sp
+<name>,<uuid>,<minor>,<flags>,<table>[,<table>+][;<dev_name>,<uuid>,<minor>,<flags>,<table>[,<table>+]]
+.TP
+The fields are:
+.
+.TP
+.B name
+The name of the device.
+.TP
+.B uuid
+The UUID of the device (or empty).
+.TP
+.B minor
+The minor number of the device.  If empty, the kernel assigns a suitable minor number.
+.TP
+.B flags
+Supported flags are:
+.sp
+.B ro
+Sets the table being loaded for the device read-only
+.br
+.B rw
+Sets the table being loaded for the device read-write (default)
+.TP
+.B table
+One line of the table. See TABLE FORMAT above.
+.
+.SH EXAMPLES
+.
+# A simple linear read-only device
+.br
+test-linear-small,,,ro,0 2097152 linear /dev/loop0 0, 2097152 2097152 linear /dev/loop1 0
+.br
+.sp
+# Two linear devices
+.br
+test-linear-small,,,,0 2097152 linear /dev/loop0 0;test-linear-large,,,, 0 2097152 linear /dev/loop1 0, 2097152 2097152 linear /dev/loop2 0
+.br
+.
 .SH ENVIRONMENT VARIABLES
 .
 .TP
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e92ba17..0fd2f2c 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -359,6 +359,23 @@ static int _parse_line(struct dm_task *dmt, char *buffer, const char *file,
 	return 1;
 }
 
+/* Parse multiple lines of table */
+static int _parse_table_lines(struct dm_task *dmt)
+{
+	char *pos = _table, *next_pos;
+	int line = 0;
+
+	do {
+		/* Identify and terminate each line */
+		if ((next_pos = strchr(_table, '\n')))
+			*next_pos++ = '\0';
+		if (!_parse_line(dmt, pos, "", ++line))
+			return_0;
+	} while ((pos = next_pos));
+
+	return 1;
+}
+
 static int _parse_file(struct dm_task *dmt, const char *file)
 {
 	char *buffer = NULL;
@@ -366,9 +383,9 @@ static int _parse_file(struct dm_task *dmt, const char *file)
 	FILE *fp;
 	int r = 0, line = 0;
 
-	/* one-line table on cmdline */
+	/* Table on cmdline or from stdin with --concise */
 	if (_table)
-		return _parse_line(dmt, _table, "", ++line);
+		return _parse_table_lines(dmt);
 
 	/* OK for empty stdin */
 	if (file) {
@@ -1098,21 +1115,17 @@ out:
 	return r;
 }
 
-static int _create(CMD_ARGS)
+static int _create_one_device(const char *name, const char *file)
 {
 	int r = 0;
 	struct dm_task *dmt;
-	const char *file = NULL;
 	uint32_t cookie = 0;
 	uint16_t udev_flags = 0;
 
-	if (argc == 2)
-		file = argv[1];
-
 	if (!(dmt = dm_task_create(DM_DEVICE_CREATE)))
 		return_0;
 
-	if (!dm_task_set_name(dmt, argv[0]))
+	if (!dm_task_set_name(dmt, name))
 		goto_out;
 
 	if (_switches[UUID_ARG] && !dm_task_set_uuid(dmt, _uuid))
@@ -1187,6 +1200,221 @@ out:
 	return r;
 }
 
+#define DEFAULT_BUF_SIZE 4096
+
+static char *_slurp_stdin(void)
+{
+	char *buf, *pos;
+	size_t bufsize = DEFAULT_BUF_SIZE;
+	size_t total = 0;
+	ssize_t n = 0;
+
+	if (!(buf = dm_malloc(bufsize))) {
+		log_error("Buffer memory allocation failed.");
+		return NULL;
+	}
+
+	pos = buf;
+	do  {
+		do
+			n = read(STDIN_FILENO, pos, (size_t) bufsize - total - 1);
+		while ((n < 0) && ((errno == EINTR) || (errno == EAGAIN)));
+
+		if (n < 0) {
+			log_error("Read from stdin aborted: %s", strerror(errno));
+			dm_free(buf);
+			return NULL;
+		}
+
+		if (!n)
+			break;
+
+		total += n;
+		pos += n;
+		if (total == bufsize - 1) {
+			bufsize *= 2;
+			if (!(buf = dm_realloc(buf, bufsize))) {
+				log_error("Buffer memory extension to %" PRIsize_t " bytes failed.", bufsize);
+				return NULL;
+			}
+		}
+	} while (1);
+
+	buf[total] = '\0';
+
+	return buf;
+}
+
+static int _create_concise(const struct command *cmd, int argc, char **argv)
+{
+	char *concise_format;
+	char *c, *n;
+	char *fields[5] = { NULL };	/* name,uuid,minor,flags,table */
+	int f = 0;
+
+	if (_switches[TABLE_ARG] || _switches[MINOR_ARG] || _switches[UUID_ARG] ||
+	    _switches[NOTABLE_ARG] || _switches[INACTIVE_ARG]){
+		log_error("--concise is incompatible with --[no]table, --minor, --uuid and --inactive.");
+		return 0;
+	}
+
+	if (argc)
+		concise_format = argv[0];
+	else if (!(concise_format = _slurp_stdin()))
+		return_0;
+
+	/* Work through input string c, parsing into sets of 5 fields. */
+	/* Strip out any characters quoted by backslashes in-place. */
+	/* Read characters from c and prepare them in situ for final processing at n */
+	c = n = fields[f] = concise_format;
+
+	while (*c) {
+		/* Quoted character?  Skip past quote. */
+		if (*c == '\\') {
+			if (!*(++c)) {
+				log_error("Backslash must be followed by another character@end of string.");
+				*n = '\0';
+				log_error("Parsed %d fields: name: %s uuid: %s minor: %s flags: %s table: %s",
+					  f + 1, fields[0], fields[1], fields[2], fields[3], fields[4]);
+				goto out;
+			}
+
+			/* Don't interpret next character */
+			*n++ = *c++;
+
+			continue;
+		} 
+
+		/* Comma marking end of field? */
+		if (*c == ',' && f < 4) {
+			/* Terminate string */
+			*n++ = '\0', c++;
+
+			/* Store start of next field */
+			fields[++f] = n;
+
+			/* Skip any whitespace after field-separating commas */
+			while(isspace(*c))
+				c++;
+
+			continue;
+		} 
+
+		/* Comma marking end of a table line? */
+		if (*c == ',' && f >= 4) {
+			/* Replace comma with newline to match standard table input format */
+			*n++ = '\n', c++;
+
+			continue;
+		} 
+
+		/* Semi-colon marking end of device? */
+		if (*c == ';' || *(c + 1) == '\0') {
+			/* End of input? */
+			if (*c != ';')
+				/* Copy final character */
+				*n++ = *c;
+
+			/* Terminate string */
+			*n++ = '\0', c++;
+
+			if (f != 4) {
+				log_error("Five comma-separated fields are required for each device");
+				log_error("Parsed %d fields: name: %s uuid: %s minor: %s flags: %s table: %s",
+					  f + 1, fields[0], fields[1], fields[2], fields[3], fields[4]);
+				goto out;
+			}
+
+			/* Set up parameters the same way as when specified directly on command line */
+			if (*fields[1]) {
+				_switches[UUID_ARG] = 1;
+				_uuid = fields[1];
+			}
+
+			if (*fields[2]) {
+				_switches[MINOR_ARG] = 1;
+				_int_args[MINOR_ARG] = atoi(fields[2]);
+			}
+
+			if (!strcmp(fields[3], "ro"))
+				_switches[READ_ONLY] = 1;
+			else if (*fields[3] && strcmp(fields[3], "rw")) {
+				log_error("Invalid flags parameter '%s' must be 'ro' or 'rw' or empty.", fields[3]);
+				_uuid = NULL;
+				goto out;
+			}
+
+			_table = fields[4];
+
+			/* Create the device */
+			if (!_create_one_device(fields[0], NULL)) {
+				_uuid = _table = NULL;
+				goto out;
+			}
+
+			/* Clear parameters ready for any further devices */
+			_switches[UUID_ARG] = 0;
+			_switches[MINOR_ARG] = 0;
+			_switches[READ_ONLY] = 0;
+			_uuid = _table = NULL;
+
+			f = 0;
+			fields[0] = n;
+			fields[1] = fields[2] = fields[3] = fields[4] = NULL;
+
+			/* Skip any whitespace after semi-colons */
+			while(isspace(*c))
+				c++;
+
+			continue;
+		} 
+
+		/* Normal character */
+		*n++ = *c++;
+	}
+
+	if (fields[0] != n) {
+		*n = '\0';
+		log_error("Incomplete entry: five comma-separated fields are required for each device");
+		log_error("Parsed %d fields: name: %s uuid: %s minor: %s flags: %s table: %s",
+			  f + 1, fields[0], fields[1], fields[2], fields[3], fields[4]);
+		goto out;
+	}
+
+	return 1;
+
+out:
+	if (!argc)
+		dm_free(concise_format);
+
+	return 0;
+}
+
+static int _create(CMD_ARGS)
+{
+	const char *name;
+	const char *file = NULL;
+
+	if (_switches[CONCISE_ARG]) {
+		if (argc > 1) {
+			log_error("dmsetup create --concise takes at most one argument");
+			return 0;
+		}
+		return _create_concise(cmd, argc, argv);
+	}
+
+	if (!argc) {
+		log_error("Please provide a name for the new device.");
+		return 0;
+	}
+
+	name = argv[0];
+	if (argc == 2)
+		file = argv[1];
+
+	return _create_one_device(name, file);
+}
+
 static int _do_rename(const char *name, const char *new_name, const char *new_uuid) {
 	int r = 0;
 	struct dm_task *dmt;
@@ -2148,6 +2376,7 @@ static int _status(CMD_ARGS)
 		name = names->name;
 	else {
 		if (!argc && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
+			/* FIXME Respect deps in concise mode, so they are correctly ordered for recreation */
 			return _process_all(cmd, NULL, argc, argv, 0, _status);
 		name = argv[0];
 	}
@@ -5930,7 +6159,8 @@ static struct command _dmsetup_commands[] = {
 	  "\t    [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
 	  "\t    [-u|uuid <uuid>] [--addnodeonresume|--addnodeoncreate]\n"
 	  "\t    [--readahead {[+]<sectors>|auto|none}]\n"
-	  "\t    [-n|--notable|--table {<table>|<table_file>}]", 1, 2, 0, 0, _create},
+	  "\t    [-n|--notable|--table {<table>|<table_file>}]\n"
+	  "\tcreate --concise [<concise_device_spec_list>]", 0, 2, 0, 0, _create},
 	{"remove", "[--deferred] [-f|--force] [--retry] <device>...", 0, -1, 1, 0, _remove},
 	{"remove_all", "[-f|--force]", 0, 0, 0, 0, _remove_all},
 	{"suspend", "[--noflush] [--nolockfs] <device>...", 0, -1, 1, 0, _suspend},
@@ -6022,6 +6252,11 @@ static void _dmsetup_usage(FILE *out)
 		     "-j <major> -m <minor>\n");
 	fprintf(out, "<mangling_mode> is one of 'none', 'auto' and 'hex'.\n");
 	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
+	fprintf(out, "<concise_device_specification> has single-device entries separated by semi-colons:\n"
+		     "    <name>,<uuid>,<minor>,<flags>,<table>\n"
+		     "        where <flags> is 'ro' or 'rw' (the default) and any of <uuid>, <minor>\n"
+		     "        and <flags> may be empty. Separate extra table lines with commas.\n"
+		     "    E.g.: dev1,,,,0 100 linear 253:1 0,100 100 error;dev2,,,ro,0 1 error\n");
 	fprintf(out, "Table_file contents may be supplied on stdin.\n");
 	fprintf(out, "Options are: devno, devname, blkdevname.\n");
 	fprintf(out, "Tree specific options are: ascii, utf, vt100; compact, inverted, notrunc;\n"


