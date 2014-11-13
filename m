From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Nov 2014 12:16:18 +0000 (UTC)
Subject: master - cleanu: drop duplicate const
Message-ID: <20141113121618.1ACE260ED9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3e29903590b596bfead1d84f91a32362d8e640f
Commit:        c3e29903590b596bfead1d84f91a32362d8e640f
Parent:        8cb79dad0bc8b02ad57a4ffaa137e40c3cb8daaf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 13 13:15:58 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 13 13:15:58 2014 +0100

cleanu: drop duplicate const

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 047e929..32abde7 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -3028,7 +3028,7 @@ static int _clean_tree(struct dev_manager *dm, struct dm_tree_node *root, const
 static int _tree_action(struct dev_manager *dm, const struct logical_volume *lv,
 			struct lv_activate_opts *laopts, action_t action)
 {
-	static const char const _action_names[][24] = {
+	static const char _action_names[][24] = {
 		"PRELOAD", "ACTIVATE", "DEACTIVATE", "SUSPEND", "SUSPEND_WITH_LOCKFS", "CLEAN"
 	};
 	const size_t DLID_SIZE = ID_LEN + sizeof(UUID_PREFIX) - 1;


