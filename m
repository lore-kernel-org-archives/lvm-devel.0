From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:21 +0000 (UTC)
Subject: master - cleanup: drop inclusion of devmap - merge
Message-ID: <20140418145521.26D5A60F48@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=451a168bf8ce913eee5c8c055345413a067569cc
Commit:        451a168bf8ce913eee5c8c055345413a067569cc
Parent:        559c003ee248704e758dec63cf480447d4de6cd7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 12:57:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:50 2014 +0200

cleanup: drop inclusion of devmap - merge

---
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h
index 1960c71..5691c87 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h
@@ -22,11 +22,11 @@
  * liblvm2cmd thread-safe so this can go away.
  */
 
-#include "libdevmapper.h"
-
 #ifndef _DMEVENTD_LVMWRAP_H
 #define _DMEVENTD_LVMWRAP_H
 
+struct dm_pool;
+
 int dmeventd_lvm2_init(void);
 void dmeventd_lvm2_exit(void);
 int dmeventd_lvm2_run(const char *cmdline);


