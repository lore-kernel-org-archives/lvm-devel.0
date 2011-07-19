From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Jul 2011 15:43:58 +0200
Subject: [PATCH 7/7] Spaces
In-Reply-To: <cover.1311082436.git.zkabelac@redhat.com>
References: <cover.1311082436.git.zkabelac@redhat.com>
Message-ID: <daa9eac3b48e54d3367fb0f322176f1f945eaf0c.1311082436.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/vg.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 3d42769..0112517 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -143,10 +143,12 @@ uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_used_count(const struct volume_group *vg);
 uint32_t vg_mda_copies(const struct volume_group *vg);
 int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies);
+
 /*
  * Returns visible LV count - number of LVs from user perspective
  */
 unsigned vg_visible_lvs(const struct volume_group *vg);
+
 /*
  * Count snapshot LVs.
  */
-- 
1.7.6


