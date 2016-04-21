From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:38 +0000 (UTC)
Subject: master - coverity: drop unused header file
Message-ID: <20160421231838.B4852616D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=edcb3e65c6398d4c4c70812b8209c8400c374099
Commit:        edcb3e65c6398d4c4c70812b8209c8400c374099
Parent:        99e96f3ce9d14e30b7150d3d4614cf9ab810e264
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 20:20:13 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 01:12:34 2016 +0200

coverity: drop unused header file

---
 lib/notify/lvmnotify.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/notify/lvmnotify.c b/lib/notify/lvmnotify.c
index 3bcf5ae..afad93b 100644
--- a/lib/notify/lvmnotify.c
+++ b/lib/notify/lvmnotify.c
@@ -10,7 +10,6 @@
 
 #include "lib.h"
 #include "toolcontext.h"
-#include "metadata.h"
 #include "lvmnotify.h"
 
 #define LVM_DBUS_DESTINATION "com.redhat.lvmdbus1"


