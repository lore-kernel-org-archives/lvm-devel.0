From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Jul 2011 17:08:20 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20110708170820.9482.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-07-08 17:08:19

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Remove dev name prefix from dmsetup line output if exactly one dev requested.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.478&r2=1.479
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.164&r2=1.165

--- LVM2/WHATS_NEW_DM	2011/07/02 01:17:09	1.478
+++ LVM2/WHATS_NEW_DM	2011/07/08 17:08:19	1.479
@@ -1,5 +1,6 @@
 Version 1.02.65 - 
 ==================================
+  Remove dev name prefix from dmsetup line output if exactly one dev requested.
   Report internal error if suspending a device using an already-suspended dev.
   Add dmsetup --checks and dm_task_enable_checks framework to validate ioctls.
   Add age_in_minutes parameter to dmsetup udevcomplete_all.
--- LVM2/tools/dmsetup.c	2011/07/01 14:09:20	1.164
+++ LVM2/tools/dmsetup.c	2011/07/08 17:08:19	1.165
@@ -1413,10 +1413,7 @@
 	uint64_t size;
 	int r = 0;
 
-	if (names)
-		name = names->name;
-	else
-		name = argv[1];
+	name = names ? names->name : argv[1];
 
 	size = _get_device_size(name);
 
@@ -1592,8 +1589,7 @@
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, argc, argv, 0, _status);
-		if (multiple_devices)
-			name = argv[1];
+		name = argv[1];
 	}
 
 	if (!strcmp(cmd->name, "table"))
@@ -1729,8 +1725,7 @@
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, argc, argv, 0, _info);
-		if (multiple_devices)
-			name = argv[1];
+		name = argv[1];
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_INFO)))
@@ -1772,8 +1767,7 @@
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG])
 			return _process_all(cmd, argc, argv, 0, _deps);
-		if (multiple_devices)
-			name = argv[1];
+		name = argv[1];
 	}
 
 	if (!(dmt = dm_task_create(DM_DEVICE_DEPS)))
@@ -3482,7 +3476,7 @@
 	#endif
 
       doit:
-	multiple_devices = (argc > 1);
+	multiple_devices = (argc != 2 && cmd->repeatable_cmd);
 	do {
 		if (!cmd->fn(cmd, argc--, argv++, NULL, multiple_devices)) {
 			fprintf(stderr, "Command failed\n");


