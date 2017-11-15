From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:43 -0500
Subject: master - pvmove: return pvmove itself
Message-ID: <201711151309.vAFD9htS001952@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cc854c0617034613b0335e43eaabf4e4ff2a26bd
Commit:        cc854c0617034613b0335e43eaabf4e4ff2a26bd
Parent:        919744375e21856ee6511f5f7185c3773d60da0b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 14 20:44:32 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 11:51:53 2017 +0100

pvmove: return pvmove itself

When find_pvmove_lv_in_lv() get already a 'pvmoving' LV - return it.
---
 lib/metadata/mirror.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 238ce37..c89408c 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1512,6 +1512,9 @@ const struct logical_volume *find_pvmove_lv_in_lv(const struct logical_volume *l
 	const struct lv_segment *seg;
 	uint32_t s;
 
+	if (lv_is_pvmove(lv))
+		return lv;
+
 	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)


