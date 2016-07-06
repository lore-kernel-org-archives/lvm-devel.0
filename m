From: Gleb Fotengauer-Malinovskiy <glebfm@altlinux.org>
Date: Wed, 6 Jul 2016 17:30:15 +0300
Subject: [PATCH] toolcontext: define _init_single_segtype only if libdl is enabled
Message-ID: <20160706143009.GA3700@glebfm.cloud.tilaa.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fixes regression introduced in dd1d42d5d07194dc7bef8776830c8216ce64f42b.
---
 lib/commands/toolcontext.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index d3bd5bc..a6788fd 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1445,6 +1445,7 @@ int lvm_register_segtype(struct segtype_library *seglib,
 	return 1;
 }
 
+#ifdef HAVE_LIBDL
 static int _init_single_segtype(struct cmd_context *cmd,
 				struct segtype_library *seglib)
 {
@@ -1462,6 +1463,7 @@ static int _init_single_segtype(struct cmd_context *cmd,
 
 	return lvm_register_segtype(seglib, segtype);
 }
+#endif
 
 static int _init_segtypes(struct cmd_context *cmd)
 {
-- 
glebfm


