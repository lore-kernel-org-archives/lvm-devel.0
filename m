From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 11:29:07 +0000 (UTC)
Subject: master - cleanup: update comment
Message-ID: <20151109112907.6F9196092B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4c9b390ca9cb1cb847c714f9b08558e9a405ea5
Commit:        e4c9b390ca9cb1cb847c714f9b08558e9a405ea5
Parent:        84a954686903b705eb0733a1bc02a7ac66728779
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 10:41:17 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 12:21:17 2015 +0100

cleanup: update comment

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4e4a025..68a8ac0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4058,7 +4058,7 @@ out:
 /*
  * Minimal LV renaming function.
  * Metadata transaction should be made by caller.
- * Assumes new_name is allocated from cmd->mem pool.
+ * Assumes new_name is allocated from lv->vgmem pool.
  */
 static int _rename_single_lv(struct logical_volume *lv, char *new_name)
 {


