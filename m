From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:47:17 +0100
Subject: [PATCH 24/25] Replicator: update generated lib/misc/configure.h.in
In-Reply-To: <cover.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
Message-ID: <ce9f7214e1a91979d0d78229daa71f0578ad88c1.1268833246.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/misc/configure.h.in |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index b0af63f..8e53fa0 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -416,6 +416,9 @@
 /* Define to 1 to include the LVM readline shell. */
 #undef READLINE_SUPPORT
 
+/* Define to 1 to include built-in support for replicators. */
+#undef REPLICATOR_INTERNAL
+
 /* Define as the return type of signal handlers (`int' or `void'). */
 #undef RETSIGTYPE
 
-- 
1.7.0.1


