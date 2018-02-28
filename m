From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:43 -0500
Subject: master - cleanup: unused header file
Message-ID: <201802282022.w1SKMh0n009855@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=805bf6ec740845de0de55d3706220d84f3ad6edb
Commit:        805bf6ec740845de0de55d3706220d84f3ad6edb
Parent:        6ba94fdd816a70f084ea86ec0a3ff2243daae158
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 25 16:18:11 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:15:55 2018 +0100

cleanup: unused header file

---
 lib/label/label.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index ae3a2c1..32fad82 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -18,7 +18,6 @@
 #include "crc.h"
 #include "xlate.h"
 #include "lvmcache.h"
-#include "lvmetad.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>


