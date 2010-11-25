From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:29 +0100
Subject: [PATCH 25/29] Check for unlink result
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <6022829a3292ffcc95debee81bda60e0522698e2.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Even if we intentionally wish to silently ignore any error from
unlink in this place - it might be still good idea to put at least
a debug message to get the reason for failure.

Test makes static analyzer happier about checked unlink result.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/archiver.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 3ace628..e0efafb 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -261,7 +261,9 @@ int backup_remove(struct cmd_context *cmd, const char *vg_name)
 	/*
 	 * Let this fail silently.
 	 */
-	unlink(path);
+	if (unlink(path))
+		log_debug("Unlink %s failed: %s", path, strerror(errno));
+
 	return 1;
 }
 
-- 
1.7.3.2


