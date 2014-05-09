From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:16 +0000 (UTC)
Subject: dev-prajnoha-selout - cleanup: fix compiler warning
Message-ID: <20140509065616.3892860774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1899783aa646cfc7f4851de7231f4f2db65b6986
Commit:        1899783aa646cfc7f4851de7231f4f2db65b6986
Parent:        8b49d61d8337cedddf65c35fb4de83cb01b1cdf4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 6 14:38:38 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 6 14:38:38 2014 +0200

cleanup: fix compiler warning

locking/file_locking.c:162:2: warning: implicit declaration of function ???init_signals???
---
 lib/locking/file_locking.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 37fa0eb..d3794db 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -23,6 +23,7 @@
 #include "lvm-string.h"
 #include "lvm-flock.h"
 #include "lvmcache.h"
+#include "lvm-signal.h"
 
 #include <limits.h>
 #include <unistd.h>


