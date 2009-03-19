From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 19 Mar 2009 11:52:21 -0400
Subject: [PATCH] remove old backup file after renaming vg
Message-ID: <49C26A35.105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This patch removes an old backup file after renaming vg
by the vgrename command.

Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.



Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 tools/vgrename.c |    1 +
 1 file changed, 1 insertion(+)

Index: LVM2.02.46-20090316/tools/vgrename.c
===================================================================
--- LVM2.02.46-20090316.orig/tools/vgrename.c
+++ LVM2.02.46-20090316/tools/vgrename.c
@@ -149,6 +149,7 @@ static int vg_rename_path(struct cmd_con
 /******* FIXME Rename any active LVs! *****/
 
 	backup(vg);
+	backup_remove(cmd, vg_name_old);
 
 	unlock_vg(cmd, vg_name_new);
 	unlock_vg(cmd, vg_name_old);


