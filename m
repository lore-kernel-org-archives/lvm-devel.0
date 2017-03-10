From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 07:17:57 -0500
Subject: master - dmsetup: always initialise 'mode' in filemap create functions
Message-ID: <201703101217.v2ACHvsI025336@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a0f597727d2b52aa9bf607544087ce97a81dee2
Commit:        6a0f597727d2b52aa9bf607544087ce97a81dee2
Parent:        146b2582b05b3b4b0f25296620ed2c2ca9e0f467
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 12:04:02 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 12:17:25 2017 +0000

dmsetup: always initialise 'mode' in filemap create functions

Older compilers cannot tell that the 'mode' variable is only
used in branches in which it is assigned:

dmsetup.c:5651: warning: "mode" may be used uninitialized in this function
dmsetup.c:5023: warning: "mode" may be used uninitialized in this function

Avoid this by always assigning the variable a value.
---
 tools/dmsetup.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index eaeb1ce..945557f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5004,6 +5004,8 @@ static int _stats_check_filemap_switches(void)
 
 static dm_filemapd_mode_t _stats_get_filemapd_mode(void)
 {
+	if (_switches[NOMONITOR_ARG] || _switches[NOGROUP_ARG])
+		return DM_FILEMAPD_FOLLOW_NONE;
 	if (!_switches[FOLLOW_ARG])
 		return DM_FILEMAPD_FOLLOW_INODE;
 	return dm_filemapd_mode_from_string(_string_args[FOLLOW_ARG]);
@@ -5073,9 +5075,9 @@ static int _stats_create_file(CMD_ARGS)
 	precise = _int_args[PRECISE_ARG];
 	group = !_switches[NOGROUP_ARG];
 
-	if (!_switches[NOMONITOR_ARG] && group)
-		if ((mode = _stats_get_filemapd_mode()) == -1)
-			goto bad;
+	mode = _stats_get_filemapd_mode();
+	if (!_switches[NOMONITOR_ARG] && (mode == DM_FILEMAPD_FOLLOW_NONE))
+		goto bad;
 
 	if (!(dms = dm_stats_create(DM_STATS_PROGRAM_ID)))
 		goto_bad;
@@ -5681,9 +5683,9 @@ static int _stats_update_file(CMD_ARGS)
 
 	group_id = (uint64_t) _int_args[GROUP_ID_ARG];
 
-	if (!_switches[NOMONITOR_ARG])
-		if ((mode = _stats_get_filemapd_mode()) < 0)
-			goto bad;
+	mode = _stats_get_filemapd_mode();
+	if (!_switches[NOMONITOR_ARG] && (mode == DM_FILEMAPD_FOLLOW_NONE))
+		goto bad;
 
 	if (_switches[PROGRAM_ID_ARG])
 		program_id = _string_args[PROGRAM_ID_ARG];


