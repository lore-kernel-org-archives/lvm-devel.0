From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 31 Jul 2015 16:49:34 +0000 (UTC)
Subject: master - dmsetup: Add subcommand parameter.
Message-ID: <20150731164934.0F71860C57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=51f89f2fbdabc3b1800a1fd5ba4c7136ada0f9d3
Commit:        51f89f2fbdabc3b1800a1fd5ba4c7136ada0f9d3
Parent:        e06d188f0d9763195c9e6040ffb26b7203e39df2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 31 17:47:03 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 31 17:47:03 2015 +0100

dmsetup: Add subcommand parameter.

Not yet used.
Allows for dmsetup stats <subcommand> dev1 dev2...
---
 tools/dmsetup.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 2f62d70..10bf3c6 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -188,7 +188,7 @@ static dev_name_t _dev_name_type;
  */
 
 struct command;
-#define CMD_ARGS const struct command *cmd, int argc, char **argv, struct dm_names *names, int multiple_devices
+#define CMD_ARGS const struct command *cmd, const char *subcommand, int argc, char **argv, struct dm_names *names, int multiple_devices
 typedef int (*command_fn) (CMD_ARGS);
 
 struct command {
@@ -1360,7 +1360,7 @@ static int _wait(CMD_ARGS)
 		       (argc > 1) ? (uint32_t) atoi(argv[argc - 1]) : 0, 1);
 }
 
-static int _process_all(const struct command *cmd, int argc, char **argv, int silent,
+static int _process_all(const struct command *cmd, const char *subcommand, int argc, char **argv, int silent,
 			int (*fn) (CMD_ARGS))
 {
 	int r = 1;
@@ -1393,7 +1393,7 @@ static int _process_all(const struct command *cmd, int argc, char **argv, int si
 
 	do {
 		names = (struct dm_names *)((char *) names + next);
-		if (!fn(cmd, argc, argv, names, 1))
+		if (!fn(cmd, subcommand, argc, argv, names, 1))
 			r = 0;
 		next = names->next;
 	} while (next);
@@ -1500,7 +1500,7 @@ static int _remove(CMD_ARGS)
 		 */
 		if (_udev_cookie)
 			log_warn("WARNING: Use of cookie and --force is not compatible.");
-		(void) _error_device(cmd, argc, argv, NULL, 0);
+		(void) _error_device(cmd, NULL, argc, argv, NULL, 0);
 	}
 
 	return _simple(DM_DEVICE_REMOVE, argc > 1 ? argv[1] : NULL, 0, 0);
@@ -1524,17 +1524,17 @@ static int _remove_all(CMD_ARGS)
 		return r;
 
 	_num_devices = 0;
-	r |= _process_all(cmd, argc, argv, 1, _count_devices);
+	r |= _process_all(cmd, NULL, argc, argv, 1, _count_devices);
 
 	/* No devices left? */
 	if (!_num_devices)
 		return r;
 
-	r |= _process_all(cmd, argc, argv, 1, _error_device);
+	r |= _process_all(cmd, NULL, argc, argv, 1, _error_device);
 	r |= _simple(DM_DEVICE_REMOVE_ALL, "", 0, 0) | dm_mknodes(NULL);
 
 	_num_devices = 0;
-	r |= _process_all(cmd, argc, argv, 1, _count_devices);
+	r |= _process_all(cmd, NULL, argc, argv, 1, _count_devices);
 	if (!_num_devices)
 		return r;
 
@@ -1633,7 +1633,7 @@ static int _status(CMD_ARGS)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
-			return _process_all(cmd, argc, argv, 0, _status);
+			return _process_all(cmd, NULL, argc, argv, 0, _status);
 		name = argv[1];
 	}
 
@@ -1772,7 +1772,7 @@ static int _info(CMD_ARGS)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
-			return _process_all(cmd, argc, argv, 0, _info);
+			return _process_all(cmd, NULL, argc, argv, 0, _info);
 		name = argv[1];
 	}
 
@@ -1816,7 +1816,7 @@ static int _deps(CMD_ARGS)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
-			return _process_all(cmd, argc, argv, 0, _deps);
+			return _process_all(cmd, NULL, argc, argv, 0, _deps);
 		name = argv[1];
 	}
 
@@ -2239,7 +2239,7 @@ static int _build_whole_deptree(const struct command *cmd)
 	if (!(_dtree = dm_tree_create()))
 		return 0;
 
-	if (!_process_all(cmd, 0, NULL, 0, _add_dep))
+	if (!_process_all(cmd, NULL, 0, NULL, 0, _add_dep))
 		return 0;
 
 	return 1;
@@ -2954,11 +2954,11 @@ static int _ls(CMD_ARGS)
 {
 	if ((_switches[TARGET_ARG] && _target) ||
 	    (_switches[EXEC_ARG] && _command))
-		return _status(cmd, argc, argv, NULL, 0);
+		return _status(cmd, NULL, argc, argv, NULL, 0);
 	else if ((_switches[TREE_ARG]))
-		return _display_tree(cmd, 0, NULL, NULL, 0);
+		return _display_tree(cmd, NULL, 0, NULL, NULL, 0);
 	else
-		return _process_all(cmd, argc, argv, 0, _display_name);
+		return _process_all(cmd, NULL, argc, argv, 0, _display_name);
 }
 
 static int _mangle(CMD_ARGS)
@@ -2974,7 +2974,7 @@ static int _mangle(CMD_ARGS)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
-			return _process_all(cmd, argc, argv, 0, _mangle);
+			return _process_all(cmd, NULL, argc, argv, 0, _mangle);
 		name = argv[1];
 	}
 
@@ -3877,7 +3877,7 @@ unknown:
 	multiple_devices = (cmd->repeatable_cmd && argc != 2 &&
 			    (argc != 1 || (!_switches[UUID_ARG] && !_switches[MAJOR_ARG])));
 	do {
-		if (!cmd->fn(cmd, argc--, argv++, NULL, multiple_devices)) {
+		if (!cmd->fn(cmd, NULL, argc--, argv++, NULL, multiple_devices)) {
 			fprintf(stderr, "Command failed\n");
 			goto out;
 		}


