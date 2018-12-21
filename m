From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:27 -0500
Subject: master - lvmlockd: drop superfluous defines
Message-ID: <201812212046.wBLKkRLD021345@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a3fe6195521a58c93d7158028c7ab62da14d4ddd
Commit:        a3fe6195521a58c93d7158028c7ab62da14d4ddd
Parent:        71af650760c2b75b3c267277f47d8ba235421300
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 11:16:05 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:42:30 2018 +0100

lvmlockd: drop superfluous defines

These defines are automatically granted with _GNU_SOURCE
which is use for whole compilation via configure.h.
---
 daemons/lvmlockd/lvmlockd-core.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 1c58d4d..e643d76 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -8,9 +8,6 @@
  * of the GNU Lesser General Public License v.2.1.
  */
 
-#define _XOPEN_SOURCE 500  /* pthread */
-#define _ISOC99_SOURCE
-
 #include "tools/tool.h"
 
 #include "libdaemon/client/daemon-io.h"


