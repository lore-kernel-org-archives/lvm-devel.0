From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 11 May 2018 06:41:47 -0400
Subject: master - radix-tree: remove some unneccessary includes
Message-ID: <201805111041.w4BAfld2011592@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30a4c7988e790c16cea043b6b6743f0576c80c1e
Commit:        30a4c7988e790c16cea043b6b6743f0576c80c1e
Parent:        0a31fb4aa323e0e8636d9c0b9332d14df86afda5
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 11 09:46:34 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 11 09:46:34 2018 +0100

radix-tree: remove some unneccessary includes

---
 base/data-struct/radix-tree.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/base/data-struct/radix-tree.c b/base/data-struct/radix-tree.c
index f2f53e9..b4b6791 100644
--- a/base/data-struct/radix-tree.c
+++ b/base/data-struct/radix-tree.c
@@ -12,9 +12,6 @@
 
 #include "radix-tree.h"
 
-#include "dm-logging.h"
-#include "log.h"
-
 #include "base/memory/container_of.h"
 #include "base/memory/zalloc.h"
 


