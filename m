From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Nov 2017 04:50:01 -0500
Subject: master - cleanup: reuse existing macro
Message-ID: <201711270950.vAR9o1Av023004@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02e934c444d2e292123fa3caff3197b84671d340
Commit:        02e934c444d2e292123fa3caff3197b84671d340
Parent:        efa17cae24190d1178a9dac1473b8757c412292c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 27 10:20:24 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 27 10:34:30 2017 +0100

cleanup: reuse existing macro

Use existing macro to detect striped raid segment.
---
 lib/metadata/segtype.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index c00cee6..61a6580 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -163,7 +163,7 @@ struct dev_manager;
 	((segtype_is_striped(segtype) || segtype_is_mirror(segtype) || \
 	  segtype_is_cache(segtype) || segtype_is_cache_pool(segtype) || \
 	  segtype_is_thin(segtype) || segtype_is_snapshot(segtype) || \
-	  (segtype_is_raid(segtype) && !segtype_is_raid1(segtype))) ? 1 : 0)
+	  (segtype_is_striped_raid(segtype))) ? 1 : 0)
 
 #define seg_is_striped_target(seg)	segtype_is_striped_target((seg)->segtype)
 #define seg_is_cache(seg)	segtype_is_cache((seg)->segtype)


