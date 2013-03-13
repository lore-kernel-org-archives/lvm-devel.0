From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Mar 2013 14:15:41 +0000 (UTC)
Subject: master - cleanup: indent
Message-ID: <20130313141541.C4D0FA0D6D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=293a06c39a45bcdcaabb2fa95e46f39466ef627f
Commit:        293a06c39a45bcdcaabb2fa95e46f39466ef627f
Parent:        521a0a3323507e1d07568d3047283975e66ca193
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 24 19:37:01 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 13 15:13:42 2013 +0100

cleanup: indent

---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8aa49fc..b8ee2f3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1307,7 +1307,7 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, struct logical_volume *l
 }
 
 static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
-			       struct logical_volume *lv, const char *layer)
+			     struct logical_volume *lv, const char *layer)
 {
 	char *dlid, *name;
 	struct dm_info info, info2;


