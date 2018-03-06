From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:46:06 -0500
Subject: master - lvremove: validate removed component LV is not active
Message-ID: <201803061446.w26Ek6Rp026718@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=73e93ef5e5e42018c701149a51db17e247dbb9a6
Commit:        73e93ef5e5e42018c701149a51db17e247dbb9a6
Parent:        ca9cbd92c40affa5ea5597de2d0ebd18382d9dab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 2 16:32:05 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:42:07 2018 +0100

lvremove: validate removed component LV is not active

This is the 'last' place where a LV is present in metadata.
Any removed device should not be left active in dm table.
So this check is an extra validation protection to capture any
forgotten deactivation (adding 1 extra ioctl into lvremove path)
---
 lib/metadata/lv_manip.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 915a032..ff82b2d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1518,6 +1518,13 @@ int lv_reduce(struct logical_volume *lv, uint32_t extents)
 	if (lv_is_raid(lv) && extents != lv->le_count)
 		extents =_round_to_stripe_boundary(lv->vg, extents,
 						   seg_is_raid1(seg) ? 0 : _raid_stripes_count(seg), 0);
+
+	if ((extents == lv->le_count) && lv_is_component(lv) && lv_is_active(lv)) {
+		/* When LV is removed, make sure it is inactive */
+		log_error(INTERNAL_ERROR "Removing still active LV %s.", display_lvname(lv));
+		return 0;
+	}
+
 	return _lv_reduce(lv, extents, 1);
 }
 


