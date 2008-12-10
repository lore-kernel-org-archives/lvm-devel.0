From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:11:01 -0500
Subject: [PATCH 11/11] Move initialization of cmd->fmt into init_formats().
In-Reply-To: <1228932661-15662-10-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-7-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-8-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-9-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

init_formats() sets up the command formats, and currently sets cmd->fmt_backup
but does not set cmd->fmt to a default value.  This seems incorrect so we
set it to cmd->default_settings.fmt before returning.

The call we remove here may set cmd->fmt based on a command line setting.
But it is safe to remove this, because the only caller of init_lvm() that
cares about the cmdline override is the cmdline tools (clvmd does not care),
called from lvm2_main().  After lvm2_main() calls init_lvm(), it later calls
lvm_run_command().  In lvm_run_command(), we have a call to _apply_settings(),
which has the identical assignment of cmd->fmt that this patch removes.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/commands/toolcontext.c |    1 +
 tools/lvmcmdline.c         |    3 ---
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 186a816..e66972c 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -787,6 +787,7 @@ static int _init_formats(struct cmd_context *cmd)
 			return 1;
 		}
 	}
+	cmd->fmt = cmd->default_settings.fmt;
 
 	log_error("_init_formats: Default format (%s) not found", format);
 	return 0;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 162be2d..5e02057 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1093,9 +1093,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 
 	init_full_scan_done(0);
 
-	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
-				 cmd->current_settings.fmt);
-
 	return cmd;
 }
 
-- 
1.5.5.1


