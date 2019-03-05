From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:28 -0500
Subject: stable-2.02 - cov: hide intentionaly ptr arithmetic report
Message-ID: <201903051353.x25DrSMM006731@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e4bb94a93e9cda695717093024800f637aead51c
Commit:        e4bb94a93e9cda695717093024800f637aead51c
Parent:        93ac80037aefb1f57c7996db3ccfe440b6bc8308
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 2 22:29:43 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:17:18 2019 +0100

cov: hide intentionaly ptr arithmetic report

Only single region count is ever replaced with on-stack uint64_t.

(cherry picked from commit a91ac41b93eff0f3ebd3af3319e8bbcb1fe8d00f)
---
 tools/dmsetup.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5b1a12e..a6610a9 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5241,6 +5241,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 			 */
 			this_start = (segments) ? segment_start : start;
 			this_len = (segments) ? segment_len : this_len;
+			/* coverity[ptr_arith] intentional */
 			if (!(r = dm_stats_create_region(dms, &region_ids[count],
 							 this_start, this_len, step,
 							 precise, bounds,


