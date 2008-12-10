From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:10:59 -0500
Subject: [PATCH 09/11] Remove redundant init_msg_prefix() and init_cmd_name().
In-Reply-To: <1228932661-15662-8-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-7-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-8-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-9-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is very obvious - _init_logging() makes the identical init_msg_prefix()
and init_cmd_name() calls with cmd->default_settings so these calls are
clearly redundant after calling create_toolcontext().

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvmcmdline.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index f4c2a63..de98940 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1094,9 +1094,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
 
-	init_msg_prefix(cmd->default_settings.msg_prefix);
-	init_cmd_name(cmd->default_settings.cmd_name);
-
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
 				 cmd->current_settings.fmt);
 
-- 
1.5.5.1


