From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:10:54 -0500
Subject: [PATCH 04/11] Remove handles_missing_pvs assignment after call to create_toolcontext().
In-Reply-To: <1228932661-15662-3-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-4-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This variable is set at the top of create_toolcontext() to 0.
Nothing later in create_toolcontext() changes the value.
In init_lvm(), nothing between create_toolcontext() call and this assignment
changes the value.  Thus, the assignment is redundant.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvmcmdline.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9fcf6fe..75f9c8c 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1105,7 +1105,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
 				 cmd->current_settings.fmt);
-	cmd->handles_missing_pvs = 0;
 
 	return cmd;
 }
-- 
1.5.5.1


