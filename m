From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Jan 2022 14:10:37 +0000 (GMT)
Subject: main - gcc: increate buffer sizes
Message-ID: <20220126141037.056423850431@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=62f11b0b0b0e4e6aebec5857406b2d4b22406378
Commit:        62f11b0b0b0e4e6aebec5857406b2d4b22406378
Parent:        cf68bf7b6c5668dcaf16310e84636a79164bd8ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 20 15:27:29 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 26 15:09:58 2022 +0100

gcc: increate buffer sizes

Make all possible string buffers to fit so they are not shortened in the
middle.
---
 daemons/cmirrord/cluster.c   | 2 +-
 daemons/cmirrord/functions.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 5de43c534..ef997baf4 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -108,7 +108,7 @@ static SaVersionT version = { 'B', 1, 1 };
 #endif
 
 #define DEBUGGING_HISTORY 100
-#define DEBUGGING_BUFLEN 128
+#define DEBUGGING_BUFLEN 270
 #define LOG_SPRINT(cc, f, arg...) do {				\
 		cc->idx++;					\
 		cc->idx = cc->idx % DEBUGGING_HISTORY;		\
diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
index 6c8c386a7..18251ec4d 100644
--- a/daemons/cmirrord/functions.c
+++ b/daemons/cmirrord/functions.c
@@ -34,7 +34,7 @@
 #define LOG_OFFSET 2
 
 #define RESYNC_HISTORY 50
-#define RESYNC_BUFLEN 128
+#define RESYNC_BUFLEN 270
 //static char resync_history[RESYNC_HISTORY][128];
 //static int idx = 0;
 #define LOG_SPRINT(_lc, f, arg...) do {					\


