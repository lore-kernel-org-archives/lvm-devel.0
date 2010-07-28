From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:53 +0200
Subject: [PATCH 07/14] Fix constness warning
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <6b08ce4471a16790ad353ce69a2a97f67c480c1c.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/archive.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 3bc14bf..95ac49d 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -50,7 +50,7 @@
 struct archive_file {
 	struct dm_list list;
 
-	char *path;
+	const char *path;
 	uint32_t index;
 };
 
@@ -353,7 +353,7 @@ int archive_list_file(struct cmd_context *cmd, const char *file)
 {
 	struct archive_file af;
 
-	af.path = (char *)file;
+	af.path = file;
 
 	if (!path_exists(af.path)) {
 		log_error("Archive file %s not found.", af.path);
-- 
1.7.2


