From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 16:06:01 +0000 (UTC)
Subject: master - cache: ensure there is no NULL str
Message-ID: <20151109160601.67AD760D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76b42901c08bd66df600f3ad82fc2f179a3abc8a
Commit:        76b42901c08bd66df600f3ad82fc2f179a3abc8a
Parent:        b1215b7f8c60f9484b0d6c032b24ea7e029505b0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 16:56:11 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 17:04:10 2015 +0100

cache: ensure there is no NULL str

Coverity is not smart enough to detect this case could never happen.
---
 lib/metadata/cache_manip.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 12b6d66..449d8df 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -79,7 +79,10 @@ int cache_set_mode(struct lv_segment *seg, const char *str)
 		    find_config_node(cmd, cmd->cft, allocation_cache_pool_cachemode_CFG))
 			id = allocation_cache_pool_cachemode_CFG;
 
-		str = find_config_tree_str(cmd, id, NULL);
+		if (!(str = find_config_tree_str(cmd, id, NULL))) {
+			log_error(INTERNAL_ERROR "Cache mode is not determined.");
+			return 0;
+		}
 	}
 
 	if (!strcmp(str, "writeback"))


