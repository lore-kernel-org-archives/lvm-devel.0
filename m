From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jul 2017 16:01:22 -0400
Subject: master - lvmlockd: use DM_UUID_LEN for buffer size
Message-ID: <201707072001.v67K1MFZ015479@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c995e40b6333fb83fc1eda7be0cc4ef43f1eb88e
Commit:        c995e40b6333fb83fc1eda7be0cc4ef43f1eb88e
Parent:        bffae6c9855033a22893b28a79d5e7952504b95e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 7 14:58:35 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 7 15:00:15 2017 -0500

lvmlockd: use DM_UUID_LEN for buffer size

---
 daemons/lvmlockd/lvmlockd-core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index b6f3df9..867e3ca 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -19,6 +19,7 @@
 #include "lvm-version.h"
 #include "lvmetad-client.h"
 #include "lvmlockd-client.h"
+#include "dm-ioctl.h" /* for DM_UUID_LEN */
 
 /* #include <assert.h> */
 #include <errno.h>
@@ -4956,7 +4957,7 @@ out:
 	return rv;
 }
 
-static char _dm_uuid[72];
+static char _dm_uuid[DM_UUID_LEN];
 
 static char *get_dm_uuid(char *dm_name)
 {


