From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  9 Jun 2023 16:01:53 +0000 (GMT)
Subject: main - cmd_enum: correct inclusion
Message-ID: <20230609160153.7790C3858D3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fcf2057b3824ab461ad43821101d09f2b06dcac8
Commit:        fcf2057b3824ab461ad43821101d09f2b06dcac8
Parent:        74feebdab723c1ea46d4316f8a581750c1d8cda3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 18 21:53:33 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 18:01:16 2023 +0200

cmd_enum: correct inclusion

Ensure we use generated header file for this build from -Iinclude.

Reported-by: Anton Lundin <glance@ac2.se>
---
 lib/commands/cmd_enum.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/commands/cmd_enum.h b/lib/commands/cmd_enum.h
index 9e9902224..9d0937a50 100644
--- a/lib/commands/cmd_enum.h
+++ b/lib/commands/cmd_enum.h
@@ -12,7 +12,7 @@
 
 enum {
 #define cmd(a, b) a ,
-#include "../../include/cmds.h"
+#include "cmds.h"
 #undef cmd
 };
 

