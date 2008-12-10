From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:10:58 -0500
Subject: [PATCH 08/11] Remove redundant set_activation() call after create_toolcontext() calls.
In-Reply-To: <1228932661-15662-7-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-7-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-8-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Very similar argument to removal of init_debug() and other calls.

create_toolcontext() calls _process_config() which sets
cmd->default_settings.activation, then calls
set_activation(cmd->default_settings.activation).  Later, create_toolcontext()
sets cmd->current_settings = cmd->default_settings.  So these calls
set_activation(cmd->current_settings.activation) are redundant.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    1 -
 tools/lvmcmdline.c            |    2 --
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 3673803..8225df6 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -732,7 +732,6 @@ int init_lvm(int using_gulm)
 	/* Use LOG_DAEMON for syslog messages instead of LOG_USER */
 	init_syslog(LOG_DAEMON);
 	openlog("clvmd", LOG_PID, LOG_DAEMON);
-	set_activation(cmd->current_settings.activation);
 	cmd->cmd_line = (char *)"clvmd";
 
 	/* Check lvm.conf is setup for cluster-LVM */
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 2c6c60d..f4c2a63 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1097,8 +1097,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	init_msg_prefix(cmd->default_settings.msg_prefix);
 	init_cmd_name(cmd->default_settings.cmd_name);
 
-	set_activation(cmd->current_settings.activation);
-
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
 				 cmd->current_settings.fmt);
 
-- 
1.5.5.1


