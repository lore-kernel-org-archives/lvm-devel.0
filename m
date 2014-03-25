From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:43 +0000 (UTC)
Subject: master - cleanup: use trigraph
Message-ID: <20140325102343.3BEAC60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a6f05e42085c0d3e8bc4b5352b57ab9b4434e02
Commit:        4a6f05e42085c0d3e8bc4b5352b57ab9b4434e02
Parent:        db71739f429f9bd12c93c6686292399f007ce4a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 24 10:01:44 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:58 2014 +0100

cleanup: use trigraph

---
 lib/activate/activate.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 9d404e5..ff13fe4 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -45,10 +45,7 @@ int lvm1_present(struct cmd_context *cmd)
 		return 0;
 	}
 
-	if (path_exists(path))
-		return 1;
-	else
-		return 0;
+	return (path_exists(path)) ? 1 : 0;
 }
 
 int list_segment_modules(struct dm_pool *mem, const struct lv_segment *seg,


