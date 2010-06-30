From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Tue, 29 Jun 2010 20:19:14 -0400
Subject: [PATCH] Fix read-only warning for partial volume
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228864C1@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A partial VG was activated in read-only mode before the following
patch was merged. With the patch, a partial VG became to be activated
in read/write mode even with "--partial" option.

https://www.redhat.com/archives/lvm-devel/2008-September/msg00022.html
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

However, vgchange and lvchange command still tell that a volume group
is activated in read-only mode and users might be confused.

  Partial mode. Incomplete volume groups will be activated read-only.

This patch deletes the second sentence.


Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
---
 tools/lvmcmdline.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: LVM2-2.02.69-20100629/tools/lvmcmdline.c
===================================================================
--- LVM2-2.02.69-20100629.orig/tools/lvmcmdline.c
+++ LVM2-2.02.69-20100629/tools/lvmcmdline.c
@@ -817,8 +817,7 @@ static int _get_settings(struct cmd_cont
 
 	if (arg_count(cmd, partial_ARG)) {
 		cmd->partial_activation = 1;
-		log_print("Partial mode. Incomplete volume groups will "
-			  "be activated read-only.");
+		log_print("Running in partial mode.");
 	}
 
 	if (arg_count(cmd, ignorelockingfailure_ARG) || arg_count(cmd, sysinit_ARG))

-- 
Takahiro Yasui
Hitachi Data Systems


