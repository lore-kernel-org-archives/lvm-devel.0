From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:23 +0000 (GMT)
Subject: main - cmdlib_lvm2_init: release cmd on failure path
Message-ID: <20210913103623.E4A7F3858006@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b36ab8a0639e85a5674a83808ccbb526a7191699
Commit:        b36ab8a0639e85a5674a83808ccbb526a7191699
Parent:        cd897e536fb69281d5d8e3e382a3827640913bd1
Author:        Wu Guanghao <wuguanghao3@huawei.com>
AuthorDate:    Mon Aug 30 15:13:00 2021 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cmdlib_lvm2_init: release cmd on failure path

The cmd memory space is allocated by zalloc, and the registration
fails and is not released.

Although this code would be ever triggered just in the case
of some internal (likely compilation) bug.

Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
---
 tools/lvmcmdlib.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 152d176b2..6b326893c 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -33,8 +33,10 @@ void *cmdlib_lvm2_init(unsigned static_compile, unsigned threaded)
 	if (!(cmd = init_lvm(1, 1, threaded)))
 		return NULL;
 
-	if (!lvm_register_commands(cmd, NULL))
+	if (!lvm_register_commands(cmd, NULL)) {
+		free(cmd);
 		return NULL;
+	}
 
 	return (void *) cmd;
 }


