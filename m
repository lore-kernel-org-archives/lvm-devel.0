From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 10 May 2018 10:16:33 -0400
Subject: master - label/lv_manip: squash some warnings
Message-ID: <201805101416.w4AEGXeV023334@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39ce38eb8868e367fa796ddb12b1020647d14c63
Commit:        39ce38eb8868e367fa796ddb12b1020647d14c63
Parent:        3c0f5bdd089e5990c4d57ea7bee5e6d9a24d5d54
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Thu May 10 15:14:39 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Thu May 10 15:14:39 2018 +0100

label/lv_manip: squash some warnings

---
 lib/label/label.c       |    4 ----
 lib/metadata/lv_manip.c |    1 +
 2 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index dcd92ce..cf45c1f 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -963,8 +963,6 @@ bool dev_write_bytes(struct device *dev, uint64_t start, size_t len, void *data)
 
 bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 {
-	int ret;
-
 	if (test_mode())
 		return true;
 
@@ -999,8 +997,6 @@ bool dev_write_zeros(struct device *dev, uint64_t start, size_t len)
 
 bool dev_set_bytes(struct device *dev, uint64_t start, size_t len, uint8_t val)
 {
-	int ret;
-
 	if (test_mode())
 		return true;
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 84953bb..8c76a38 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -30,6 +30,7 @@
 #include "lvm-exec.h"
 #include "memlock.h"
 #include "lvmlockd.h"
+#include "label.h"
 
 typedef enum {
 	PREFERRED,


