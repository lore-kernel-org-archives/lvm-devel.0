From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 07 Nov 2011 13:49:47 +0100
Subject: [PATCH 2/2] dev names: Add "--names" switch to dmsetup to show names instead of major:minor pairs for deps and ls commands
Message-ID: <4EB7D3EB.6000102@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This makes it a little bit more user-friendly for admins
if they read the output so they don't need to look for
the names themselves.

(there's also an RFE filed here: https://bugzilla.redhat.com/show_bug.cgi?id=731785).

An example with mirror volume:

[0] rawhide/~ # dmsetup deps
vg-lvol0: 3 dependencies	: (253, 2) (253, 1) (253, 0)
vg-lvol0_mimage_1: 1 dependencies	: (8, 16)
vg-lvol0_mimage_0: 1 dependencies	: (8, 0)
vg-lvol0_mlog: 1 dependencies	: (8, 128)

[0] rawhide/~ # dmsetup deps --names
vg-lvol0: 3 dependencies	: (vg-lvol0_mimage_1) (vg-lvol0_mimage_0) (vg-lvol0_mlog)
vg-lvol0_mimage_1: 1 dependencies	: (sdb)
vg-lvol0_mimage_0: 1 dependencies	: (sda)
vg-lvol0_mlog: 1 dependencies	: (sdi)


[0] rawhide/~ # dmsetup ls
vg-lvol0	(253, 3)
vg-lvol0_mimage_1	(253, 2)
vg-lvol0_mimage_0	(253, 1)
vg-lvol0_mlog	(253, 0)

[0] rawhide/~ # dmsetup ls --names
vg-lvol0	(dm-3)
vg-lvol0_mimage_1	(dm-2)
vg-lvol0_mimage_0	(dm-1)
vg-lvol0_mlog	(dm-0)


[0] rawhide/~ # dmsetup ls --tree
vg-lvol0 (253:3)
 ??vg-lvol0_mimage_1 (253:2)
 ?  ?? (8:16)
 ??vg-lvol0_mimage_0 (253:1)
 ?  ?? (8:0)
 ??vg-lvol0_mlog (253:0)
    ?? (8:128)
[0] rawhide/~ # dmsetup ls --tree --names

vg-lvol0 (dm-3)
 ??vg-lvol0_mimage_1 (dm-2)
 ?  ?? (sdb)
 ??vg-lvol0_mimage_0 (dm-1)
 ?  ?? (sda)
 ??vg-lvol0_mlog (dm-0)
    ?? (sdi)


Peter
---
 tools/dmsetup.c |   51 +++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 39 insertions(+), 12 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index f35c8a5..0430772 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -130,6 +130,7 @@ enum {
 	MINOR_ARG,
 	MODE_ARG,
 	NAMEPREFIXES_ARG,
+	NAMES_ARG,
 	NOFLUSH_ARG,
 	NOHEADINGS_ARG,
 	NOLOCKFS_ARG,
@@ -1767,6 +1768,7 @@ static int _deps(CMD_ARGS)
 	struct dm_task *dmt;
 	struct dm_info info;
 	char *name = NULL;
+	char dev_name[PATH_MAX];
 
 	if (names)
 		name = names->name;
@@ -1813,10 +1815,17 @@ static int _deps(CMD_ARGS)
 		printf("%s: ", name);
 	printf("%d dependencies\t:", deps->count);
 
-	for (i = 0; i < deps->count; i++)
-		printf(" (%d, %d)",
-		       (int) MAJOR(deps->device[i]),
-		       (int) MINOR(deps->device[i]));
+	for (i = 0; i < deps->count; i++) {
+		if (_switches[NAMES_ARG] &&
+		    dm_device_get_name((uint32_t) MAJOR(deps->device[i]),
+				       (uint32_t) MINOR(deps->device[i]),
+				       0, dev_name, PATH_MAX))
+			printf(" (%s)", dev_name);
+		else
+			printf(" (%d, %d)",
+			       (int) MAJOR(deps->device[i]),
+			       (int) MINOR(deps->device[i]));
+	}
 	printf("\n");
 
 	if (multiple_devices && _switches[VERBOSE_ARG])
@@ -1831,8 +1840,16 @@ static int _deps(CMD_ARGS)
 
 static int _display_name(CMD_ARGS)
 {
-	printf("%s\t(%d, %d)\n", names->name,
-	       (int) MAJOR(names->dev), (int) MINOR(names->dev));
+	char dev_name[PATH_MAX];
+
+	if (_switches[NAMES_ARG] &&
+	    dm_device_get_name((uint32_t) MAJOR(names->dev),
+			       (uint32_t) MINOR(names->dev),
+			       1,dev_name, PATH_MAX))
+		printf("%s\t(%s)\n", names->name, dev_name);
+	else
+		printf("%s\t(%d, %d)\n", names->name,
+		       (int) MAJOR(names->dev), (int) MINOR(names->dev));
 
 	return 1;
 }
@@ -2057,6 +2074,7 @@ static void _display_tree_node(struct dm_tree_node *node, unsigned depth,
 	const char *name;
 	const struct dm_info *info;
 	int first_on_line = 0;
+	char dev_name[PATH_MAX];
 
 	/* Sub-tree for targets has 2 more depth */
 	if (depth + 2 > MAX_DEPTH)
@@ -2091,9 +2109,15 @@ static void _display_tree_node(struct dm_tree_node *node, unsigned depth,
 
 	if (_tree_switches[TR_DEVICE]) {
 		_out_string(name ? " (" : "(");
-		(void) _out_int(info->major);
-		_out_char(':');
-		(void) _out_int(info->minor);
+		if (_switches[NAMES_ARG] &&
+		    dm_device_get_name(info->major, info->minor,
+				       1, dev_name, PATH_MAX))
+			_out_string(dev_name);
+		else {
+			(void) _out_int(info->major);
+			_out_char(':');
+			(void) _out_int(info->minor);
+		}
 		_out_char(')');
 	}
 
@@ -2780,9 +2804,9 @@ static struct command _commands[] = {
 	{"reload", "<device> [<table_file>]", 0, 2, 0, _load},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, _rename},
 	{"message", "<device> <sector> <message>", 2, -1, 0, _message},
-	{"ls", "[--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, 0, _ls},
+	{"ls", "[--names] [--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, 0, _ls},
 	{"info", "[<device>]", 0, -1, 1, _info},
-	{"deps", "[<device>]", 0, -1, 1, _deps},
+	{"deps", "[--names] [<device>]", 0, -1, 1, _deps},
 	{"status", "[<device>] [--target <target_type>]", 0, -1, 1, _status},
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, 0, _wait},
@@ -2806,7 +2830,7 @@ static void _usage(FILE *out)
 
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
-		"        [--checks] [-v|--verbose [-v|--verbose ...]]\n"
+		"        [--checks] [--names] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
@@ -3172,6 +3196,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"minor", 1, &ind, MINOR_ARG},
 		{"mode", 1, &ind, MODE_ARG},
 		{"nameprefixes", 0, &ind, NAMEPREFIXES_ARG},
+		{"names", 0, &ind, NAMES_ARG},
 		{"noflush", 0, &ind, NOFLUSH_ARG},
 		{"noheadings", 0, &ind, NOHEADINGS_ARG},
 		{"nolockfs", 0, &ind, NOLOCKFS_ARG},
@@ -3339,6 +3364,8 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 			_switches[INACTIVE_ARG]++;
 		if ((ind == NAMEPREFIXES_ARG))
 			_switches[NAMEPREFIXES_ARG]++;
+		if ((ind == NAMES_ARG))
+			_switches[NAMES_ARG]++;
 		if ((ind == NOFLUSH_ARG))
 			_switches[NOFLUSH_ARG]++;
 		if ((ind == NOHEADINGS_ARG))


