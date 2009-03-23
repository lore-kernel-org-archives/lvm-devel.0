From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 23 Mar 2009 13:32:14 -0400
Subject: [PATCH] restore log state in check_current_backup
Message-ID: <49C7C79E.10307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This is a patch to restore a log state properly when backup is up-to-date
in check_current_backup function.

Regards,
---
Takahiro Yasui
Hitachi Computer Products (America), Inc.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/format_text/archiver.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: LVM2.02.46-20090316/lib/format_text/archiver.c
===================================================================
--- LVM2.02.46-20090316.orig/lib/format_text/archiver.c
+++ LVM2.02.46-20090316/lib/format_text/archiver.c
@@ -405,8 +405,10 @@ void check_current_backup(struct volume_
 	/* Up-to-date backup exists? */
 	if ((vg_backup = backup_read_vg(vg->cmd, vg->name, path)) &&
 	    (vg->seqno == vg_backup->seqno) &&
-	    (id_equal(&vg->id, &vg_backup->id)))
+	    (id_equal(&vg->id, &vg_backup->id))) {
+		log_suppress(0);
 		return;
+	}
 	log_suppress(0);
 
 	if (vg_backup)


