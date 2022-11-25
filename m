From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Nov 2022 15:43:02 +0000 (GMT)
Subject: main - dmsetup: fix udev event handling for create
Message-ID: <20221125154302.76789384F482@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5042375de3fd7146906614bffbcc960349c2b20
Commit:        a5042375de3fd7146906614bffbcc960349c2b20
Parent:        ae916f77c92c1765c76fbb849a2eaeb5e0724768
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 25 15:45:47 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 25 16:41:53 2022 +0100

dmsetup: fix udev event handling for create

With newer kernels (>5.13)  DM_CREATE no longer generates
uevent for DM devices without table.
There are even no sysfs block device entries in such case,
although device has asigned major:minor and it is being listed
by 'dmsetup info'.

So this patch calculates amount of 'table' lines and in case
no table line comes from cmdline or stdin - waiting on cookie
is avoided generically instead of disabling just case with
option --notable - which then also skipped handling of an
option --addnodeoncreate (which is however historical and
should be avoided)

As a result there should be no leaking udev cookies and endlessly
waiting commands like this:

dmsetup create mytestdev  </dev/null
---
 WHATS_NEW_DM             |  1 +
 libdm/dm-tools/dmsetup.c | 14 +++++++++-----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1067312d3..71eee439f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.189 - 
 =====================================
+  Improve 'dmsetup create' without given table line with new kernels.
 
 Version 1.02.187 - 10th November 2022
 =====================================
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 42eeead68..ea03d66c8 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -274,6 +274,7 @@ static char _disp_units = 's';
 const char *_program_id = DM_STATS_PROGRAM_ID; /* program_id used for reports. */
 static uint64_t _statstype = 0; /* stats objects to report */
 static int _concise_output_produced = 0; /* Was any concise output already printed? */
+static int _added_target = 0;		/* Count added target (no target -> no event) */
 struct command;
 static const struct command *_selection_cmd = NULL; /* Command to run against each device select with -S */
 
@@ -357,6 +358,8 @@ static int _parse_line(struct dm_task *dmt, char *buffer, const char *file,
 	if (!dm_task_add_target(dmt, start, size, ttype, ptr))
 		return_0;
 
+	_added_target++;
+
 	return 1;
 }
 
@@ -1175,9 +1178,6 @@ static int _create_one_device(const char *name, const char *file)
 				    _read_ahead_flags))
 		goto_out;
 
-	if (_switches[NOTABLE_ARG])
-		dm_udev_set_sync_support(0);
-
 	if (_switches[NOUDEVRULES_ARG])
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
@@ -1194,8 +1194,12 @@ static int _create_one_device(const char *name, const char *file)
 	if (_udev_only)
 		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
-	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
-	    !_task_run(dmt))
+	if (_switches[NOTABLE_ARG] || !_added_target)
+		cookie = 0; // ADD event -> no udev event handling
+	else if (!dm_task_set_cookie(dmt, &cookie, udev_flags))
+		goto_out;
+
+	if (!_task_run(dmt))
 		goto_out;
 
 	r = 1;

