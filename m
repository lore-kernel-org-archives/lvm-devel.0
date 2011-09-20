From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 20 Sep 2011 14:56:08 +0200
Subject: [PATCH 2/7][retry remove] Add "--retry" option to dmsetup to enable "retry remove" logic
Message-ID: <4E788D68.2050705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 tools/dmsetup.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index fbdbc6a..f35c8a5 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -140,6 +140,7 @@ enum {
 	NOUDEVSYNC_ARG,
 	OPTIONS_ARG,
 	READAHEAD_ARG,
+	RETRY_ARG,
 	ROWS_ARG,
 	SEPARATOR_ARG,
 	SETUUID_ARG,
@@ -1279,6 +1280,9 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, udev_flags))
 		goto out;
 
+	if (_switches[RETRY_ARG] && task == DM_DEVICE_REMOVE)
+		dm_task_retry_remove(dmt);
+
 	r = dm_task_run(dmt);
 
       out:
@@ -2805,7 +2809,7 @@ static void _usage(FILE *out)
 		"        [--checks] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
-		"        [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
+		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
@@ -3178,6 +3182,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
+		{"retry", 0, &ind, RETRY_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
 		{"separator", 1, &ind, SEPARATOR_ARG},
 		{"setuuid", 0, &ind, SETUUID_ARG},
@@ -3362,6 +3367,8 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 				}
 			}
 		}
+		if ((ind == RETRY_ARG))
+			_switches[RETRY_ARG]++;
 		if ((ind == ROWS_ARG))
 			_switches[ROWS_ARG]++;
 		if ((ind == SETUUID_ARG))


