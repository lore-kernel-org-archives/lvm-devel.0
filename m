From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Jul 2013 16:26:50 +0000 (UTC)
Subject: master - thin: report 'e' volume type pool metadata spare
Message-ID: <20130718162650.3269660DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=915cc5a2faf67dd3438651b80414f2a054016749
Commit:        915cc5a2faf67dd3438651b80414f2a054016749
Parent:        460d0254ebc7df514081997a12238a88e8b203c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 17 19:42:52 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 18 18:22:44 2013 +0200

thin: report 'e' volume type pool metadata spare

Reuse m'e'tadata volume type for spar'e' volume as well.
Essentially they are related and there is no big reason
to introduce new flag.
---
 lib/metadata/lv.c |    1 +
 man/lvs.8.in      |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4d3a259..db71cf0 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -547,6 +547,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
 	else if (lv_is_thin_pool_metadata(lv) ||
+		 lv_is_pool_metadata_spare(lv) ||
 		 (lv->status & RAID_META))
 		repstr[0] = 'e';
 	else if (lv->status & RAID)
diff --git a/man/lvs.8.in b/man/lvs.8.in
index 5df6b47..4da4370 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -135,7 +135,7 @@ Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin,
 (s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
 mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,
 under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, raid or
-thin pool m(e)tadata
+thin pool m(e)tadata or pool metadata spare.
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
 volume


