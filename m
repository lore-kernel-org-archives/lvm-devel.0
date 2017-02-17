From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Feb 2017 12:25:38 +0000 (UTC)
Subject: master - cleanup: add comment for longer macro
Message-ID: <20170217122538.68CBB60E97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46d6c7d3ad0f5a4151960202635f3805dc0e3f15
Commit:        46d6c7d3ad0f5a4151960202635f3805dc0e3f15
Parent:        772834e40aef44a8f7bc884050e1b88087073706
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 17 11:51:24 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 13:20:55 2017 +0100

cleanup: add comment for longer macro

---
 tools/command.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index b202878..5342ba2 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -145,11 +145,11 @@ enum {
 #undef lvt
 };
 
-#else
+#else  /* MAN_PAGE_GENERATOR */
 
 #include "tools.h"
 
-#endif
+#endif /* MAN_PAGE_GENERATOR */
 
 #include "command.h"       /* defines struct command */
 #include "command-count.h" /* defines COMMAND_COUNT */


