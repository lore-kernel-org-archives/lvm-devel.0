From: David Teigland <teigland@fedoraproject.org>
Date: Wed,  9 Mar 2016 19:38:23 +0000 (UTC)
Subject: master - remove unused define
Message-ID: <20160309193823.EFB4160FCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f01ee3035cf5ede72a8653fd1dca2987db29475
Commit:        8f01ee3035cf5ede72a8653fd1dca2987db29475
Parent:        18291fd01639939812779e63de0d64a4224729ad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 9 13:38:04 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 9 13:38:04 2016 -0600

remove unused define

---
 lib/config/defaults.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 51fd01d..a6806cd 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -235,6 +235,4 @@
 #define DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD 100
 #define DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT 20
 
-#define DEFAULT_CY_LOCK_TYPE "sanlock"
-
 #endif				/* _LVM_DEFAULTS_H */


