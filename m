From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 16:49:25 +0000 (UTC)
Subject: master - lvmetad: disable if command uses lvm1
Message-ID: <20160419164925.023E26108B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a17610899f6dc5d5e5acf5f0a4b427f2cdfeea8
Commit:        2a17610899f6dc5d5e5acf5f0a4b427f2cdfeea8
Parent:        1e380864e5b6e0773ddf48189b6563c3033e6354
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 6 15:57:09 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 09:41:18 2016 -0500

lvmetad: disable if command uses lvm1

Alternatively, a command could return an error saying
that lvm1 and lvmetad are not compatible.
---
 tools/lvmcmdline.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 404c835..dd89a7b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -22,6 +22,7 @@
 
 #include "stub.h"
 #include "last-path-component.h"
+#include "format1.h"
 
 #include <signal.h>
 #include <sys/stat.h>
@@ -1601,6 +1602,13 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
+	if (!strcmp(cmd->fmt->name, FMT_LVM1_NAME) && lvmetad_used()) {
+		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
+		lvmetad_set_disabled(cmd, "LVM1");
+		log_warn("WARNING: Not using lvmetad because lvm1 format is used.");
+		lvmetad_set_active(cmd, 0);
+	}
+
 	if (cmd->metadata_read_only &&
 	    !(cmd->command->flags & PERMITTED_READ_ONLY)) {
 		log_error("%s: Command not permitted while global/metadata_read_only "


