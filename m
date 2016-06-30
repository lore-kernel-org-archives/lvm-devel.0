From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Jun 2016 22:46:11 +0000 (UTC)
Subject: master - cleanup: warns from older gcc
Message-ID: <20160630224611.5E883611AA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37a33d7414b85e4ce69a2ab6727522faba8a86eb
Commit:        37a33d7414b85e4ce69a2ab6727522faba8a86eb
Parent:        3fd458488649c27f18f1ddb993ba9360f259d47b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 27 11:13:43 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 1 00:44:48 2016 +0200

cleanup: warns from older gcc

---
 lib/cache/lvmcache.c  |    3 +--
 lib/display/display.c |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 9d89b80..6ce778d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2137,7 +2137,6 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
 	char uuid[64] __attribute__((aligned(8)));
 	struct lvmcache_vgsummary vgsummary = { 0 };
-	const struct format_type *fmt = labeller->fmt;
 	struct lvmcache_info *info;
 	struct lvmcache_info *info_lookup;
 	struct device_list *devl;
@@ -2178,7 +2177,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 
 			if (!_found_duplicate_pvs && lvmetad_used()) {
 				log_warn("WARNING: Disabling lvmetad cache which does not support duplicate PVs."); 
-				lvmetad_set_disabled(fmt->cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
+				lvmetad_set_disabled(labeller->fmt->cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
 			}
 			_found_duplicate_pvs = 1;
 
diff --git a/lib/display/display.c b/lib/display/display.c
index 19421e7..f8dd338 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -843,7 +843,7 @@ char yes_no_prompt(const char *prompt, ...)
 	static const char _no[] = "no";
 	const char *answer = NULL;
 	int c = silent_mode() ? EOF : 0;
-	int i, ret = 0, sig = 0;
+	int i = 0, ret = 0, sig = 0;
 	char buf[12];
 	va_list ap;
 


