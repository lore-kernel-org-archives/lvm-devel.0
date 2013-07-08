From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  8 Jul 2013 17:15:54 +0200
Subject: [PATCH 2/7] thin: report 'e' volume type pool metadata spare
In-Reply-To: <cover.1373296467.git.zkabelac@redhat.com>
References: <cover.1373296467.git.zkabelac@redhat.com>
Message-ID: <ea4ff83a835c35d908a6172058667d6425395612.1373296467.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Reuse m'e'tadata volume type for spar'e' volume as well.
Essentially they are related and there is no big reason
to introduce new flag.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv.c | 1 +
 man/lvs.8.in      | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 0742562..31e0c83 100644
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
index 013740f..965d649 100644
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
-- 
1.8.3.1


