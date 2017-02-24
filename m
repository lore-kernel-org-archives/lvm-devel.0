From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:26 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063226.1FF4360AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f79bd30a8be0d189c417a76d1ca6b64f70a8832e
Commit:        f79bd30a8be0d189c417a76d1ca6b64f70a8832e
Parent:        1784cc990e6941e93cfcf1204526cec75d287a89
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 04:00:17 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Change:
- allow raid_rimage_extents() to calculate raid10
- remove an __unused__ attribute

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 40bc45e..c465bd4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1135,8 +1135,7 @@ uint32_t raid_rimage_extents(const struct segment_type *segtype,
 	uint64_t r;
 
 	if (!extents ||
-	    segtype_is_mirror(segtype) ||
-	    segtype_is_raid1(segtype))
+	    segtype_is_striped_raid(segtype))
 		return extents;
 
 	r = extents;
@@ -1576,7 +1575,6 @@ static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum al
 	return 1;
 }
 
-__attribute__ ((__unused__))
 static int _lv_free_reshape_space(struct logical_volume *lv)
 {
 	return _lv_free_reshape_space_with_status(lv, NULL);


