From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 May 2009 17:24:14 +0200
Subject: [PATCH 5/9] Fix lv_is_visible to handle virtual origin.
In-Reply-To: <cover.1242227458.git.mbroz@redhat.com>
References: <cover.1242227458.git.mbroz@redhat.com>
Message-ID: <752ebe47615b39f7347de6e7039ad902f68698a1.1242227458.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Snapshot is visible if its origin is marked visible,
or if the origin is virtual.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/snapshot_manip.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index e186dff..0509fe0 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -30,8 +30,15 @@ int lv_is_cow(const struct logical_volume *lv)
 
 int lv_is_visible(const struct logical_volume *lv)
 {
-	if (lv_is_cow(lv))
-		return lv_is_visible(find_cow(lv)->lv);
+	if (lv->status & SNAPSHOT)
+		return 0;
+
+	if (lv_is_cow(lv)) {
+		if (lv_is_virtual_origin(origin_from_cow(lv)))
+			return 1;
+
+		return lv_is_visible(origin_from_cow(lv));
+	}
 
 	return lv->status & VISIBLE_LV ? 1 : 0;
 }
-- 
1.6.2.4


