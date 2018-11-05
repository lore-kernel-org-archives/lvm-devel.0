From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 5 Nov 2018 11:27:27 -0500
Subject: master - cov: hide intentionaly ptr arithmetic report
Message-ID: <201811051627.wA5GRR1A005429@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a91ac41b93eff0f3ebd3af3319e8bbcb1fe8d00f
Commit:        a91ac41b93eff0f3ebd3af3319e8bbcb1fe8d00f
Parent:        9238b972c543a83fbd553cc44a916608809cfc53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 2 22:29:43 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 3 16:10:32 2018 +0100

cov: hide intentionaly ptr arithmetic report

Only single region count is ever replaced with on-stack uint64_t.
---
 libdm/dm-tools/dmsetup.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 93714ac..4b14a23 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -5245,6 +5245,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			 */
 			this_start = (segments) ? segment_start : start;
 			this_len = (segments) ? segment_len : this_len;
+			/* coverity[ptr_arith] intentional */
 			if (!(r = dm_stats_create_region(dms, &region_ids[count],
 							 this_start, this_len, step,
 							 precise, bounds,


