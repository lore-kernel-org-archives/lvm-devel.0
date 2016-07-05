From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 19:48:12 +0000 (UTC)
Subject: master - libdm: cast walk flags to uint64_t when logging.
Message-ID: <20160705194812.7A56060F55@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d4f48af9f18b9407c065cdc035cf8e397e08ac0
Commit:        4d4f48af9f18b9407c065cdc035cf8e397e08ac0
Parent:        f1dd0258f1cb27e62d1133ba41c75bca04a7b174
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 20:45:24 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 20:45:24 2016 +0100

libdm: cast walk flags to uint64_t when logging.

Walk flags are ULL constants; cast the result to a uint64_t before
logging with a FMTx64 format specifier to avoid a compiler warning:

  warning: format ???%lx??? expects argument of type ???long unsigned int???,
  but argument 5 has type ???long long unsigned int???
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 83c4d50..07503a5 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1399,7 +1399,7 @@ int dm_stats_walk_init(struct dm_stats *dms, uint64_t flags)
 
 	if (flags & ~DM_STATS_WALK_MASK) {
 		log_error("Unknown value in walk flags: 0x" FMTx64,
-			  flags & ~DM_STATS_WALK_MASK);
+			  (uint64_t) (flags & ~DM_STATS_WALK_MASK));
 		return 0;
 	}
 	dms->walk_flags = flags;


