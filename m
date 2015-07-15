From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Jul 2015 11:11:03 +0000 (UTC)
Subject: master - cleanup: drop unused header file
Message-ID: <20150715111103.DFEBF609E2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64c41062191e3bd487374837ff6d21a077129c98
Commit:        64c41062191e3bd487374837ff6d21a077129c98
Parent:        c45e6e3c78bc6ac4ddd96c764deed211cf1c6f31
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 10 11:16:11 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 15 13:10:22 2015 +0200

cleanup: drop unused header file

---
 lib/raid/raid.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index e9dfbd4..ae70cdd 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -16,7 +16,6 @@
 #include "segtype.h"
 #include "display.h"
 #include "text_export.h"
-#include "text_import.h"
 #include "config.h"
 #include "str_list.h"
 #include "targets.h"


