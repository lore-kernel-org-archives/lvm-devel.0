From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:22 +0200
Subject: [PATCH 10/25] Replicator: new defaults
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <4f18ac45d8b4b04c38d1a6326d618bd3e3a6e784.1281256235.git.zkabelac@redhat.com>
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
index 3d8881c..1c9ce54 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -48,6 +48,14 @@
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
+#define DEFAULT_REPLICATOR_SYNCLOG "disk"
+#define DEFAULT_REPLICATOR_LOG_TYPE "ringbuffer"
+#define DEFAULT_REPLICATOR_LOCAL_SITE_NAME "local"
+#define DEFAULT_REPLICATOR_FALL_BEHIND_IOS 0
+#define DEFAULT_REPLICATOR_FALL_BEHIND_SIZE 0
+#define DEFAULT_REPLICATOR_FALL_BEHIND_TIMEOUT 0
+#define DEFAULT_REPLICATOR_SITE_POLICY (DM_REPLICATOR_ASYNC_WARN)
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
1.7.2.1


