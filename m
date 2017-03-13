From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 13 Mar 2017 12:48:58 -0400
Subject: master - raid: check more cautious on region size changes
Message-ID: <201703131648.v2DGmwkc009786@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f2c942000b9e59105441eeaea7233b6c9c4f493
Commit:        5f2c942000b9e59105441eeaea7233b6c9c4f493
Parent:        77a7ed065f09f5c9e3e50622de07717a5db2249a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Mar 13 17:46:56 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Mar 13 17:46:56 2017 +0100

raid: check more cautious on region size changes

Add additional checks to avoid calling _region_size_change_requested()
with bogus actual arguments.
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e6d269e..b2ea241 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5810,7 +5810,7 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, con
 		return_0;
 
 	/* CLI validation provides the check but be caucious... */
-	if (seg_is_any_raid0(seg))
+	if (!lv_is_raid(lv) || !seg || seg_is_any_raid0(seg))
 		return_0;
 
 	if (region_size == seg->region_size) {


