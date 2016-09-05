From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  5 Sep 2016 16:14:57 +0000 (UTC)
Subject: master - lvmetad: Unused includes.
Message-ID: <20160905161457.8247360CD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e4821a847debe9a7c48b9dd0f218eff030dfce2
Commit:        2e4821a847debe9a7c48b9dd0f218eff030dfce2
Parent:        d7b282c6013c6317e9b092d56652cd4b7e43deef
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 5 17:14:53 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 5 17:14:53 2016 +0100

lvmetad: Unused includes.

---
 lib/cache/lvmetad.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 94cc67d..b3cd1bf 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -24,10 +24,6 @@
 #include "lvm-signal.h"
 #include "lvmlockd.h"
 #include "str_list.h"
-#ifdef UDEV_SYNC_SUPPORT
-#include <libudev.h>
-#include "dev-ext-udev-constants.h"
-#endif
 
 #include <time.h>
 


