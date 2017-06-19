From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 19 Jun 2017 15:09:24 -0400
Subject: master - lvconvert: disable conversion of RAID LV under snapshot
Message-ID: <201706191909.v5JJ9OwB031785@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f342e803ba3c32890a2b08736fa94bdd541d5e9c
Commit:        f342e803ba3c32890a2b08736fa94bdd541d5e9c
Parent:        fb46175ce7550fd6c9f40e6d8eec337fc2693e80
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jun 19 21:08:52 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jun 19 21:08:52 2017 +0200

lvconvert: disable conversion of RAID LV under snapshot

Disable until we have a proper fix for reshape space allocation,
switching it to begin/end of rimages and activation.

Related: rhbz1439399
---
 lib/metadata/raid_manip.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6abf482..0a08ca9 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6312,6 +6312,12 @@ int lv_raid_convert(struct logical_volume *lv,
 					 new_stripes, new_stripe_size_supplied))
 		return _log_possible_conversion_types(lv, new_segtype);
 
+	/* BZ1439399 */
+	if (lv_is_origin(lv)) {
+		log_error("Can't convert %s under snapshot.", display_lvname(lv));
+		return 0;
+	}
+
 	/*
 	 * reshape of capable raid type requested
 	 */


