From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 11:55:11 +0100
Subject: [PATCH 07/29] Test success from dm_poll_create
In-Reply-To: <cover.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
Message-ID: <750a494b506778c00d7093ea00a89fa863d826b5.1290682013.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add testing for NULL return value from dm_poll_create.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/config/config.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index c10c78e..4ecec94 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -511,7 +511,10 @@ int write_config_node(const struct config_node *cn, putline_fn putline, void *ba
 {
 	struct output_line outline;
 	outline.fp = NULL;
-	outline.mem = dm_pool_create("config_line", 1024);
+	if (!(outline.mem = dm_pool_create("config_line", 1024))) {
+		log_error("Failed to allocate config_line pool.");
+		return 0;
+	}
 	outline.putline = putline;
 	outline.putline_baton = baton;
 	if (!_write_config(cn, 0, &outline, 0)) {
@@ -538,7 +541,10 @@ int write_config_file(struct config_tree *cft, const char *file,
 		return 0;
 	}
 
-	outline.mem = dm_pool_create("config_line", 1024);
+	if (!(outline.mem = dm_pool_create("config_line", 1024))) {
+		log_error("Failed to allocate config_line pool.");
+		return 0;
+	}
 
 	log_verbose("Dumping configuration to %s", file);
 	if (!argc) {
-- 
1.7.3.2


