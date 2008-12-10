From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 10 Dec 2008 13:11:00 -0500
Subject: [PATCH 10/11] Remove redundant init_mirror_in_sync() call in init_lvm().
In-Reply-To: <1228932661-15662-9-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-7-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-8-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-9-git-send-email-dwysocha@redhat.com>
Message-ID: <1228932661-15662-10-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

_mirror_in_sync is statically initialized to 0 in lvm-globals.c,
so no need to set it in init_lvm().  Only other callers that may
set this are later in execution.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvmcmdline.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index de98940..162be2d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1092,7 +1092,6 @@ struct cmd_context *init_lvm(unsigned is_static)
 		return_NULL;
 
 	init_full_scan_done(0);
-	init_mirror_in_sync(0);
 
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
 				 cmd->current_settings.fmt);
-- 
1.5.5.1


