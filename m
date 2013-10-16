From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 16 Oct 2013 10:48:14 +0000 (UTC)
Subject: master - thin: missed check for thin_pool in last update
Message-ID: <20131016104814.3EE8F610A1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd3a2f13f1680228fe9ddd5fa1b1c5900cf8dc96
Commit:        dd3a2f13f1680228fe9ddd5fa1b1c5900cf8dc96
Parent:        73971e1e7b1164f4f7c677afc17aabbd09e11252
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 16 12:47:30 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 16 12:47:30 2013 +0200

thin: missed check for thin_pool in last update

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index eaac565..a6c1187 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2327,7 +2327,7 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (pool_is_active(pool_lv)) {
+	if (lv_is_thin_pool(pool_lv) && pool_is_active(pool_lv)) {
 		/* If any thin volume is also active - abort here */
 		log_error("Cannot convert pool %s/%s with active thin volumes.",
 			  pool_lv->vg->name, pool_lv->name);


