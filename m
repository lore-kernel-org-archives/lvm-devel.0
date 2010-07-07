From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:34:44 +0200
Subject: [PATCH 10/22] Replicator: new defaults
In-Reply-To: <cover.1278505885.git.zkabelac@redhat.com>
References: <cover.1278505885.git.zkabelac@redhat.com>
Message-ID: <01b84b50f6c7f1175147f332d0a2c1d63b6bab22.1278505885.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/defaults.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 3d8881c..fc5649e 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -48,6 +48,14 @@
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
+#define DEFAULT_REPLICATOR_SYNCLOG "disk"
+#define DEFAULT_REPLICATOR_LOG_TYPE "ringbuffer"
+#define DEFAULT_REPLICATOR_LOCAL_SITE_NAME "local"
+#define DEFAULT_REPLICATOR_FALL_BEHIND_DATA 0
+#define DEFAULT_REPLICATOR_FALL_BEHIND_IOS 0
+#define DEFAULT_REPLICATOR_FALL_BEHIND_TIMEOUT 0
+#define DEFAULT_REPLICATOR_ASYNC_MODE (DM_REPLICATOR_ASYNC_WARN)
+
 #define DEFAULT_UMASK 0077
 
 #ifdef LVM1_FALLBACK
@@ -106,6 +114,7 @@
 
 #define DEFAULT_STRIPE_FILLER "error"
 #define DEFAULT_MIRROR_REGION_SIZE 512	/* KB */
+#define DEFAULT_REPLICATOR_REGION_SIZE 512	/* KB */
 #define DEFAULT_INTERVAL 15
 
 #ifdef READLINE_SUPPORT
-- 
1.7.1.1


