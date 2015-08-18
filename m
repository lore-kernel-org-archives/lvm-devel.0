From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:01:47 +0000 (UTC)
Subject: master - cleanup: trace error from lvmcache_update_vgname_and_id
Message-ID: <20150818130147.AAD9D60D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8fd88463e662b769073e7b06d1a5acfd07fbc13
Commit:        a8fd88463e662b769073e7b06d1a5acfd07fbc13
Parent:        3a3e17d603698967e5febb84036923dc7e8da674
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 13:48:53 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 15:00:08 2015 +0200

cleanup: trace error from lvmcache_update_vgname_and_id

Check result value from lvmcache_update_vgname_and_id().
---
 lib/format_text/format-text.c |    5 +++--
 lib/label/label.c             |    3 ++-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 1d7dc3c..4544f26 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -453,8 +453,9 @@ static struct raw_locn *_find_vg_rlocn(struct device_area *dev_area,
 				   "not match expected name %s.", vgname);
 
       bad:
-	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, 0)))
-		lvmcache_update_vgname_and_id(info, &vgsummary_orphan);
+	if ((info = lvmcache_info_from_pvid(dev_area->dev->pvid, 0)) &&
+	    !lvmcache_update_vgname_and_id(info, &vgsummary_orphan))
+		stack;
 
 	return NULL;
 }
diff --git a/lib/label/label.c b/lib/label/label.c
index 4510400..bc3c653 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -105,7 +105,8 @@ static void _update_lvmcache_orphan(struct lvmcache_info *info)
 
         memcpy(&vgsummary_orphan.vgid, lvmcache_fmt(info)->orphan_vg_name, strlen(lvmcache_fmt(info)->orphan_vg_name));
 
-	lvmcache_update_vgname_and_id(info, &vgsummary_orphan);
+	if (!lvmcache_update_vgname_and_id(info, &vgsummary_orphan))
+		stack;
 }
 
 static struct labeller *_find_labeller(struct device *dev, char *buf,


