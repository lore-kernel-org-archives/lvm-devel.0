From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:15 +0000 (UTC)
Subject: master - cleanup: drop uneeded header file
Message-ID: <20151022213415.2571460612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1319e04020c3cb77b3a5c5a765606efa0b34b83
Commit:        b1319e04020c3cb77b3a5c5a765606efa0b34b83
Parent:        8be60e6a65baf87b12862e07d24bd794608df2f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 10:40:51 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:46:10 2015 +0200

cleanup: drop uneeded header file

---
 lib/locking/no_locking.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index b1dcb30..613877a 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -19,8 +19,6 @@
 #include "lvm-string.h"
 #include "activate.h"
 
-#include <signal.h>
-
 /*
  * No locking
  */


