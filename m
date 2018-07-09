From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:44 -0400
Subject: master - vdo: component activation of VDO data LV
Message-ID: <201807091334.w69DYi2o030673@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aff69ecf396a858d684cd3e54baea131e229f5a2
Commit:        aff69ecf396a858d684cd3e54baea131e229f5a2
Parent:        4b7a57c9ed5187e32394a983e08be3b4a0b19079
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 3 11:05:50 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

vdo: component activation of VDO data LV

Allow component activation of VDO data LV.
---
 lib/metadata/metadata-exported.h |    1 +
 lib/misc/lvm-string.c            |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4a9f2e0..f5b540a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -267,6 +267,7 @@
 #define lv_is_component(lv) (lv_is_cache_origin(lv) || ((lv)->status & (\
 	CACHE_POOL_DATA |\
 	CACHE_POOL_METADATA |\
+	LV_VDO_POOL_DATA |\
 	MIRROR_IMAGE |\
 	MIRROR_LOG |\
 	RAID_IMAGE |\
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 689a6b5..901243c 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -162,7 +162,8 @@ static const char *_lvname_has_reserved_component_string(const char *lvname)
 		"_rimage",
 		"_rmeta",
 		"_tdata",
-		"_tmeta"
+		"_tmeta",
+		"_vdata"
 	};
 	unsigned i;
 


