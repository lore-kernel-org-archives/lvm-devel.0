From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 11:31:57 -0400
Subject: master - dmsetup: replace (f)printf("\n") with putchar/putc
Message-ID: <201703301531.v2UFVv35006494@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b46fe5843401abff4004a1629152ed1de68fbd9
Commit:        2b46fe5843401abff4004a1629152ed1de68fbd9
Parent:        febda60f3daf8d9e0ff47aa692a90fe4ed36c128
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Mar 30 16:30:50 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 16:30:50 2017 +0100

dmsetup: replace (f)printf("\n") with putchar/putc

---
 tools/dmsetup.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 44ea6f9..5c5c14c 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -978,7 +978,7 @@ static void _display_info_long(struct dm_task *dmt, struct dm_info *info)
 	if ((uuid = dm_task_get_uuid(dmt)) && *uuid)
 		printf("UUID: %s\n", uuid);
 
-	printf("\n");
+	putchar('\n');
 }
 
 static int _display_info(struct dm_task *dmt)
@@ -1612,7 +1612,7 @@ static char _yes_no_prompt(const char *prompt, ...)
 	} while (!ret || c != '\n');
 
 	if (c != '\n')
-		printf("\n");
+		putchar('\n');
 
 	return ret;
 }
@@ -2213,13 +2213,13 @@ static int _status(CMD_ARGS)
 				printf(FMTu64 " " FMTu64 " %s %s",
 				       start, length, target_type, params);
 			}
-			printf("\n");
+			putchar('\n');
 		}
 		matched = 1;
 	} while (next);
 
 	if (multiple_devices && _switches[VERBOSE_ARG] && matched && !ls_only)
-		printf("\n");
+		putchar('\n');
 
 	if (matched && _switches[EXEC_ARG] && _command_to_exec && !_exec_command(name))
 		goto_out;
@@ -2374,10 +2374,10 @@ static int _deps(CMD_ARGS)
 		else
 			printf(" (%d, %d)", major, minor);
 	}
-	printf("\n");
+	putchar('\n');
 
 	if (multiple_devices && _switches[VERBOSE_ARG])
-		printf("\n");
+		putchar('\n');
 
 	r = 1;
 
@@ -5950,7 +5950,7 @@ static void _stats_usage(FILE *out)
 
 	fprintf(out, "\n<device> may be device name or (if only one) -u <uuid> or -j <major> -m <minor>\n");
 	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
-	fprintf(out, "\n");
+	putc('\n', out);
 }
 
 static void _dmsetup_usage(FILE *out)
@@ -5981,7 +5981,7 @@ static void _dmsetup_usage(FILE *out)
 	fprintf(out, "Options are: devno, devname, blkdevname.\n");
 	fprintf(out, "Tree specific options are: ascii, utf, vt100; compact, inverted, notrunc;\n"
 		     "                           blkdevname, [no]device, active, open, rw and uuid.\n");
-	fprintf(out, "\n");
+	putc('\n', out);
 }
 
 static void _losetup_usage(FILE *out)
@@ -7079,7 +7079,7 @@ doit:
 			dm_report_output(_report);
 
 			if (_count > 1 && r) {
-				printf("\n");
+				putchar('\n');
 				fflush(stdout);
 				/* wait for --interval and update timestamps */
 				if (!_do_report_wait()) {


