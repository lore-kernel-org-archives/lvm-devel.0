From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:25:30 -0400
Subject: master - poll: add stdout fflush after poll query
Message-ID: <201805121625.w4CGPUQi007762@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6740c78e838b0b2322097de307fb41f1eeb60839
Commit:        6740c78e838b0b2322097de307fb41f1eeb60839
Parent:        09fcc8eaa8eb7fa4fcd7c6611bfbfb83f726ae38
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 7 11:46:09 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 11:30:05 2018 +0200

poll: add stdout fflush after poll query

ATM it's a bit ugly to enforce flushing of 'stdio' here, but works as quick
hot-fix.

log_print*() is using buffered I/O.

But for pooling with typical 1s interval this may take a while before
buffer about continues progress gets flushed.
So ATM fflush().

TODO: either add  log_print*_with_flush() or maybe directly use just
line buffering with log_print() and only log_debug() keep using buffered
I/O mode.
---
 tools/polldaemon.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 020be21..05a4758 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -80,6 +80,8 @@ static int _check_lv_status(struct cmd_context *cmd,
 	}
 
 	progress = parms->poll_fns->poll_progress(cmd, lv, name, parms);
+	fflush(stdout);
+
 	if (progress == PROGRESS_CHECK_FAILED)
 		return_0;
 
@@ -448,6 +450,7 @@ static int _report_progress(struct cmd_context *cmd, struct poll_operation_id *i
 		ret = 0;
 		goto out;
 	}
+	fflush(stdout);
 
 	ret = 1;
 


