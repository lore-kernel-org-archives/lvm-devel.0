From: Anton Lundin <glance@ac2.se>
Date: Tue, 16 May 2023 18:05:11 +0200
Subject: [PATCH] Fix header include for out of tree builds
Message-ID: <20230516160511.2053800-1-glance@ac2.se>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The relative include didn't match up for out of tree builds. The
build tree include directory is in the include paths already.

Signed-off-by: Anton Lundin <glance@ac2.se>
---

Now the following works:
$ mkdir lvm2-build
$ cd lvm2-build
$ ../lvm2/configure
$ make

Please keep me on Cc on any related discussions because I'm not
subscribed to the mailinglist.

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
 
-- 
2.30.2

