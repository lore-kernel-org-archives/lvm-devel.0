From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 28 Feb 2017 17:29:35 -0500
Subject: master - lvconvert: add missing reshape_len initialization
Message-ID: <201702282229.v1SMTZFa019130@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a064303fe1a14e205a50abc5a54e38467fcb455
Commit:        7a064303fe1a14e205a50abc5a54e38467fcb455
Parent:        964114950ce3ce0539a47b966494868285679ef8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Feb 28 23:29:03 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Feb 28 23:29:03 2017 +0100

lvconvert: add missing reshape_len initialization

An initialization was missing when converting striped to raid0(_meta)
causing unitialized reshape_len in the new component LVs first segment.

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b8447a0..6cc1c12 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4166,6 +4166,10 @@ static struct lv_segment *_convert_striped_to_raid0(struct logical_volume *lv,
 	if (alloc_metadata_devs && !_raid0_add_or_remove_metadata_lvs(lv, 0, allocate_pvs, NULL))
 		return NULL;
 
+	/* Initialize reshape len properly after adding the image component list */
+	if (!_lv_set_reshape_len(lv, 0))
+		return_0;
+
 	if (update_and_reload && !lv_update_and_reload(lv))
 		return NULL;
 


