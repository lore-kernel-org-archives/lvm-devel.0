From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Mar 2013 11:48:34 +0000 (UTC)
Subject: master - config: make DEFAULT_MAX_HISTORY unconditional
Message-ID: <20130306114834.51162A0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f88690221bb23668e0b763d212b58eeaaa4150a4
Commit:        f88690221bb23668e0b763d212b58eeaaa4150a4
Parent:        03b5c51730431ceb38c301293a19882b5829b84d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 6 12:47:23 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 6 12:47:23 2013 +0100

config: make DEFAULT_MAX_HISTORY unconditional

---
 lib/config/defaults.h |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index cad9862..b8d46f1 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -145,9 +145,7 @@
 #define DEFAULT_RAID_REGION_SIZE   512	/* KB */
 #define DEFAULT_INTERVAL 15
 
-#ifdef READLINE_SUPPORT
-#  define DEFAULT_MAX_HISTORY 100
-#endif
+#define DEFAULT_MAX_HISTORY 100
 
 #define DEFAULT_MAX_ERROR_COUNT	NO_DEV_ERROR_COUNT_LIMIT
 


