From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 19 Mar 2009 11:39:29 -0400
Subject: [PATCH] Fix memory allocation size and error message in backup_init
Message-ID: <49C26731.4020608@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch fixes the memory allocation size and the error message
in backup_init function.

Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/format_text/archiver.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: LVM2.02.46-20090316/lib/format_text/archiver.c
===================================================================
--- LVM2.02.46-20090316.orig/lib/format_text/archiver.c
+++ LVM2.02.46-20090316/lib/format_text/archiver.c
@@ -154,8 +154,8 @@ int backup_init(struct cmd_context *cmd,
 		int enabled)
 {
 	if (!(cmd->backup_params = dm_pool_zalloc(cmd->libmem,
-					       sizeof(*cmd->archive_params)))) {
-		log_error("archive_params alloc failed");
+					       sizeof(*cmd->backup_params)))) {
+		log_error("backup_params alloc failed");
 		return 0;
 	}
 


