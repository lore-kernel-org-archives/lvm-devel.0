From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 25 Jun 2013 13:56:02 +0200
Subject: [PATCH 2/6] thin: report spare as 'e' volume type
In-Reply-To: <cover.1372161214.git.zkabelac@redhat.com>
References: <cover.1372161214.git.zkabelac@redhat.com>
Message-ID: <8c55fe11cf59a205d4309d49ac618bf9e755c0df.1372161214.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Reuse m'e'tadata volume type as  spar'e'
since essentially they are related and there is no big reason
to introduce new flag - but of course we may use some other letters.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 6215e1a..b95d0a3 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -547,6 +547,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
 	else if (lv_is_thin_pool_metadata(lv) ||
+		 lv_is_spare(lv) ||
 		 (lv->status & RAID_META))
 		repstr[0] = 'e';
 	else if (lv->status & RAID)
-- 
1.8.2.1


