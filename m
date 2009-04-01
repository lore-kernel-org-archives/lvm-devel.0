From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 01 Apr 2009 17:12:52 -0400
Subject: [PATCH] fix error message _init_backup
Message-ID: <49D3D8D4.6090707@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This is a patch to fix an error message in _init_backup function.

Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/commands/toolcontext.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: LVM2.02.46-cvs-20090324/lib/commands/toolcontext.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/commands/toolcontext.c
+++ LVM2.02.46-cvs-20090324/lib/commands/toolcontext.c
@@ -955,7 +955,7 @@ static int _init_backup(struct cmd_conte
 
 	if (!archive_init(cmd, dir, days, min,
 			  cmd->default_settings.archive)) {
-		log_debug("backup_init failed.");
+		log_debug("archive_init failed.");
 		return 0;
 	}
 


