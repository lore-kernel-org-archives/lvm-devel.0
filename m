From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Apr 2013 10:35:51 +0000 (UTC)
Subject: master - cleanup: type
Message-ID: <20130423103551.9A9BA5BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1445d407949735c8fc17c9c0871d39224ef6d716
Commit:        1445d407949735c8fc17c9c0871d39224ef6d716
Parent:        45eeb70b02df0f196ccd851c23c42fc29d6efb39
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 23 12:35:10 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 23 12:35:10 2013 +0200

cleanup: type

oops another type inserted.
---
 lib/config/config.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 0af57d5..2fd8793 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -65,7 +65,7 @@ struct dm_config_tree *config_file_open(const char *filename, int keep_open)
 		return NULL;
 
 	if (!(cf = dm_pool_zalloc(cft->mem, sizeof(struct config_file)))) {
-		log_error("Failed to allocate condig tree.");
+		log_error("Failed to allocate config tree.");
 		goto fail;
 	}
 


