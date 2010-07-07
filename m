From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  7 Jul 2010 14:29:35 +0200
Subject: [PATCH 5/6] Better alligned debug message - memlock
In-Reply-To: <cover.1278505444.git.zkabelac@redhat.com>
References: <cover.1278505444.git.zkabelac@redhat.com>
Message-ID: <7279c49cc495586ad959774a958cc00241c8586a.1278505444.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/mm/memlock.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index bc18c0d..de1f777 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -137,7 +137,8 @@ static int _maps_line(struct cmd_context *cmd, lvmlock_t lock,
 
 	/* Select readable maps */
 	if (fr != 'r') {
-		log_debug("mlock area unreadable '%s': Skipping.", line);
+		log_debug("m%slock area unreadable %s : Skipping.",
+			  (lock == LVM_MLOCK) ? "" : "un", line);
 		return 1;
 	}
 
@@ -171,8 +172,8 @@ static int _maps_line(struct cmd_context *cmd, lvmlock_t lock,
 	}
 
 	*mstats += sz;
-	log_debug("%s %10ldKiB %12lx - %12lx %c%c%c%c %s",
-		  (lock == LVM_MLOCK) ? "mlock" : "munlock",
+	log_debug("m%slock %10ldKiB %12lx - %12lx %c%c%c%c%s",
+		  (lock == LVM_MLOCK) ? "" : "un",
 		  ((long)sz + 1023) / 1024, from, to, fr, fw, fx, fp, line + pos);
 
 	if (lock == LVM_MLOCK) {
-- 
1.7.1.1


