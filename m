From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Oct 2012 08:59:51 +0000 (UTC)
Subject: master - lvmetad: initialize cft value
Message-ID: <20121012085952.0C72E172E@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c4dcbf67a3d19bf4a91b4b72e3e230583a8ee2da
Commit:        c4dcbf67a3d19bf4a91b4b72e3e230583a8ee2da
Parent:        28776b9526784fc3dd2ab94a4151613771c4dfda
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 12 10:35:01 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 12 10:59:10 2012 +0200

lvmetad: initialize cft value

the error should not test garbage value.
---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 8540273..9a5c8b9 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -663,7 +663,7 @@ static int vg_remove_if_missing(lvmetad_state *s, const char *vgid)
 static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid,
 			   struct dm_config_node *metadata, int64_t *oldseq)
 {
-	struct dm_config_tree *cft;
+	struct dm_config_tree *cft = NULL;
 	struct dm_config_tree *old;
 	int retval = 0;
 	int seq;


