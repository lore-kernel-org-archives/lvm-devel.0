From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:17 +0000 (UTC)
Subject: master - coverity: drop unneeded header
Message-ID: <20160223204117.C3F6B607C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e168a52b07bb9dc659bdcda80fc77031edebbd6
Commit:        2e168a52b07bb9dc659bdcda80fc77031edebbd6
Parent:        6d6e063a0fd132c49490f01949dfa5fa28125a33
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 19:47:35 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:12 2016 +0100

coverity: drop unneeded header

---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index ba4044f..25d1063 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -15,7 +15,6 @@
 #include "lib.h"
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
-#include "defaults.h"
 
 /* FIXME Reformat to 80 char lines. */
 


