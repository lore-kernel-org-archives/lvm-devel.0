From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:46 +0000 (GMT)
Subject: main - clang: add explicit test for VG
Message-ID: <20210920132946.2F64C3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d9f3dbd954b04e08a27154376b60fe9aca23b0c
Commit:        0d9f3dbd954b04e08a27154376b60fe9aca23b0c
Parent:        48163e32f100a9567cb28ab89f70488d0a0abc7f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 18 23:16:30 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 10:51:30 2021 +0200

clang: add explicit test for VG

Clang can't figure out connection to 'skip' variable.
---
 tools/toollib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 562cad06a..fa3b2ffe3 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4349,7 +4349,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		if (ret > ret_max)
 			ret_max = ret;
 
-		if (!skip)
+		if (!skip && vg)
 			unlock_vg(cmd, vg, vg->name);
 endvg:
 		if (error_vg)


