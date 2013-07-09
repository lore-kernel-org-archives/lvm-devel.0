From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  9 Jul 2013 01:43:00 +0000 (UTC)
Subject: master - tools: remove metadata.h from pvresize/vgck
Message-ID: <20130709014300.506536134F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1280a3c7ed52e7af303c65a367f3d4fda941dfaa
Commit:        1280a3c7ed52e7af303c65a367f3d4fda941dfaa
Parent:        8adddbf101b362884d62ba066cc72b5ded016f37
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 9 02:41:56 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 9 02:41:56 2013 +0100

tools: remove metadata.h from pvresize/vgck

---
 tools/pvresize.c |    1 -
 tools/vgck.c     |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/tools/pvresize.c b/tools/pvresize.c
index a5f81f8..8004700 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -15,7 +15,6 @@
  */
 
 #include "tools.h"
-#include "metadata.h"
 #include "metadata-exported.h"
 
 struct pvresize_params {
diff --git a/tools/vgck.c b/tools/vgck.c
index 2a009db..eb0ecaf 100644
--- a/tools/vgck.c
+++ b/tools/vgck.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "metadata.h"
 
 static int vgck_single(struct cmd_context *cmd __attribute__((unused)),
 		       const char *vg_name,


