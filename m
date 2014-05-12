From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 12 May 2014 14:25:52 +0000 (UTC)
Subject: master - cleanup: drop unused header
Message-ID: <20140512142552.CF9A66106E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c07fb7678ecb7ecf54e9acc4c2f3ef6138cec90f
Commit:        c07fb7678ecb7ecf54e9acc4c2f3ef6138cec90f
Parent:        506ade802b6e7f8c2afb027cd969bbb105afabd1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 9 17:10:26 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 12 16:24:40 2014 +0200

cleanup: drop unused header

---
 lib/locking/file_locking.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 10431ab..d332101 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -22,7 +22,6 @@
 #include "lvm-string.h"
 #include "lvm-flock.h"
 #include "lvmcache.h"
-#include "lvm-signal.h"
 
 #include <limits.h>
 #include <unistd.h>


