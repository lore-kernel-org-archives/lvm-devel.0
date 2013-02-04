From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon,  4 Feb 2013 23:11:54 +0000 (UTC)
Subject: master - clean-up: Another functiont that can use 'lv_layer'
Message-ID: <20130204231155.0ADAFA0C29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5cd9c3563a77f65b039923833ee13f3e22a959f
Commit:        f5cd9c3563a77f65b039923833ee13f3e22a959f
Parent:        a4870c79cad46e6063862d7cc828a2bbef9251c3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Feb 4 17:10:16 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Feb 4 17:10:16 2013 -0600

clean-up:  Another functiont that can use 'lv_layer'

lib/activate/dev_manager.c:dev_manager_raid_status() can also use
the new 'lv_layer' function.
---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1916d3e..e8f449c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1031,7 +1031,7 @@ int dev_manager_raid_status(struct dev_manager *dm,
 	uint64_t start, length;
 	char *type = NULL;
 	char *params = NULL;
-	const char *layer = (lv_is_origin(lv)) ? "real" : NULL;
+	const char *layer = lv_layer(lv);
 
 	/* Build dlid for the thin pool layer */
 	if (!(dlid = build_dm_uuid(dm->mem, lv->lvid.s, layer)))


