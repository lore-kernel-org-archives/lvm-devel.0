From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 14 Oct 2011 16:59:57 +0200
Subject: [PATCH 6/6][devname mangling] Add support for unmangling devnames in "dmsetup ls/deps"
Message-ID: <4E984E6D.8030903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Well, for dmsetup ls/deps, I have no better idea, just to add --unmanglename
switch (I assume it won't a be a good idea to change the existing output format).
So if --unmanglename is define, the name will be unmangled in the output, if not,
it will be kept as it is in the mangled form.

Peter
---
 tools/dmsetup.c |   27 ++++++++++++++++++++++++---
 1 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0339ceb..49d8ebb 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -152,6 +152,7 @@ enum {
 	TREE_ARG,
 	UID_ARG,
 	UNBUFFERED_ARG,
+	UNMANGLENAME_ARG,
 	UNQUOTED_ARG,
 	UUID_ARG,
 	VERBOSE_ARG,
@@ -1786,6 +1787,7 @@ static int _deps(CMD_ARGS)
 	struct dm_task *dmt;
 	struct dm_info info;
 	char *name = NULL;
+	char buf[PATH_MAX];
 
 	if (names)
 		name = names->name;
@@ -1825,6 +1827,10 @@ static int _deps(CMD_ARGS)
 		goto out;
 	}
 
+	if (_switches[UNMANGLENAME_ARG] &&
+	    dm_string_mangle_decode(DM_STRING_MANGLE_HEX, name, buf, PATH_MAX))
+		name = buf;
+
 	if (_switches[VERBOSE_ARG])
 		_display_info(dmt);
 
@@ -1850,7 +1856,14 @@ static int _deps(CMD_ARGS)
 
 static int _display_name(CMD_ARGS)
 {
-	printf("%s\t(%d, %d)\n", names->name,
+	const char *name = names->name;
+	char buf[PATH_MAX];
+
+	if (_switches[UNMANGLENAME_ARG] &&
+	    dm_string_mangle_decode(DM_STRING_MANGLE_HEX, name, buf, PATH_MAX))
+		name = buf;
+
+	printf("%s\t(%d, %d)\n", name,
 	       (int) MAJOR(names->dev), (int) MINOR(names->dev));
 
 	return 1;
@@ -2076,6 +2089,7 @@ static void _display_tree_node(struct dm_tree_node *node, unsigned depth,
 	const char *name;
 	const struct dm_info *info;
 	int first_on_line = 0;
+	char buf[PATH_MAX];
 
 	/* Sub-tree for targets has 2 more depth */
 	if (depth + 2 > MAX_DEPTH)
@@ -2086,6 +2100,10 @@ static void _display_tree_node(struct dm_tree_node *node, unsigned depth,
 	if ((!name || !*name) && !_tree_switches[TR_DEVICE])
 		return;
 
+	if (_switches[UNMANGLENAME_ARG] &&
+	    dm_string_mangle_decode(DM_STRING_MANGLE_HEX, name, buf, PATH_MAX))
+		name = buf;
+
 	/* Indicate whether there are more nodes at this depth */
 	_tree_more[depth] = !last_child;
 	_tree_width[depth] = 0;
@@ -2814,9 +2832,9 @@ static struct command _commands[] = {
 	{"reload", "<device> [<table_file>]", 0, 2, 0, _load},
 	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, 0, _rename},
 	{"message", "<device> <sector> <message>", 2, -1, 0, _message},
-	{"ls", "[--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, 0, _ls},
+	{"ls", "[--target <target_type>] [--exec <command>] [--tree [-o options]] [--unmanglename]", 0, 0, 0, _ls},
 	{"info", "[<device>]", 0, -1, 1, _info},
-	{"deps", "[<device>]", 0, -1, 1, _deps},
+	{"deps", "[<device>] [--unmanglename]", 0, -1, 1, _deps},
 	{"status", "[<device>] [--target <target_type>]", 0, -1, 1, _status},
 	{"table", "[<device>] [--target <target_type>] [--showkeys]", 0, -1, 1, _status},
 	{"wait", "<device> [<event_nr>]", 0, 2, 0, _wait},
@@ -3230,6 +3248,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"uid", 1, &ind, UID_ARG},
 		{"uuid", 1, &ind, UUID_ARG},
 		{"unbuffered", 0, &ind, UNBUFFERED_ARG},
+		{"unmanglename", 0, &ind, UNMANGLENAME_ARG},
 		{"unquoted", 0, &ind, UNQUOTED_ARG},
 		{"verbose", 1, &ind, VERBOSE_ARG},
 		{"verifyudev", 0, &ind, VERIFYUDEV_ARG},
@@ -3387,6 +3406,8 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 			}
 			dm_set_default_name_mangle(_int_args[MANGLENAME_ARG]);
 		}
+		if ((ind == UNMANGLENAME_ARG))
+			_switches[UNMANGLENAME_ARG]++;
 		if ((ind == NAMEPREFIXES_ARG))
 			_switches[NAMEPREFIXES_ARG]++;
 		if ((ind == NOFLUSH_ARG))


