From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 13 Oct 2012 17:22:12 +0000 (UTC)
Subject: master - cleanup: drop unused assignment
Message-ID: <20121013172212.2652D22CC@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9effc6ab316db0f3f7122019ccdc546972ea1e94
Commit:        9effc6ab316db0f3f7122019ccdc546972ea1e94
Parent:        88c547d1ca83426f4de5371baac885f5500b5487
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 13 19:17:10 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 13 19:17:10 2012 +0200

cleanup: drop unused assignment

Since 'n' is later reassigned and unused between, drop it's first
assign.
---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 9a5c8b9..1992467 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1113,7 +1113,7 @@ static int init(daemon_state *s)
 static int fini(daemon_state *s)
 {
 	lvmetad_state *ls = s->private;
-	struct dm_hash_node *n = dm_hash_get_first(ls->vgid_to_metadata);
+	struct dm_hash_node *n;
 
 	DEBUG(s, "fini");
 


