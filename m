From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:52 +0000 (UTC)
Subject: master - cleanup: typo update
Message-ID: <20141006133352.0166660DB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9d50e4533193d75057bb2444eb899d33598968a
Commit:        d9d50e4533193d75057bb2444eb899d33598968a
Parent:        916a68585e5078ff3f3190a9f77bee2f7b9b30a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 30 21:01:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:23:08 2014 +0200

cleanup: typo update

---
 lib/metadata/cache_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 895eaff..0a6daf6 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -315,8 +315,8 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	 *
 	 * FIXME:
 	 * fix _add_dev() to support this case better
-	 * since the should be handled interanlly by resume_lv()
-	 * which should autoremove any orhpans
+	 * since that should be handled internally by resume_lv()
+	 * which should autoremove any orphans
 	 */
 	if (!_cleanup_orphan_lv(corigin_lv))  /* _corig */
 		return_0;


