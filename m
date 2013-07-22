From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Jul 2013 10:42:07 +0000 (UTC)
Subject: master - cleanup: remove unused headers
Message-ID: <20130722104207.C5B1660DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea68f085019c3d1a21e8b375bd3eee293d108af4
Commit:        ea68f085019c3d1a21e8b375bd3eee293d108af4
Parent:        6d2604f02651158223ac31fe58e0638b6171171c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 19 15:31:26 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 22 12:41:21 2013 +0200

cleanup: remove unused headers

---
 lib/metadata/thin_manip.c |    1 -
 liblvm/lvm_lv.c           |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 5ac356f..38073ee 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -18,7 +18,6 @@
 #include "metadata.h"
 #include "segtype.h"
 #include "lv_alloc.h"
-#include "archiver.h"
 #include "defaults.h"
 #include "display.h"
 
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index c28d997..27a0f07 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -21,7 +21,6 @@
 #include "activate.h"
 #include "lvm_misc.h"
 #include "lvm2app.h"
-#include "lvm_prop.h"
 
 /* FIXME Improve all the log messages to include context. Which VG/LV as a minimum? */
 


