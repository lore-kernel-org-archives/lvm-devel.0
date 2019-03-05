From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:07 -0500
Subject: stable-2.02 - cov: dmstats check for failing malloc
Message-ID: <201903051353.x25Dr7DP006658@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c115d92287e86d153f2f09d7f8aea8065098f91c
Commit:        c115d92287e86d153f2f09d7f8aea8065098f91c
Parent:        ece117ee102684dc5380d30b73e4b992689eb85f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 5 12:13:08 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:13:08 2019 +0100

cov: dmstats check for failing malloc

Add missing check for allocation success.

Backported from: 9b7121226258f7dfe759cc1f8625cbfb80fec161
---
 tools/dmsetup.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0b5b808..5b1a12e 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5216,7 +5216,10 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 	if (!segments || (info.target_count == 1))
 		region_ids = &region_id;
 	else
-		region_ids = dm_malloc(info.target_count * sizeof(*region_ids));
+		if (!(region_ids = dm_malloc(info.target_count * sizeof(*region_ids)))) {
+			log_error("Failed to allocated region IDs.");
+			goto out;
+		}
 
 	do {
 		uint64_t segment_start, segment_len;


