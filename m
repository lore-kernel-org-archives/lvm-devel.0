From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Feb 2017 09:14:49 +0000 (UTC)
Subject: master - cleanup: use proper printf specifier
Message-ID: <20170213091449.B5E5F60E6F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=717d0c6b94c81730582eb3000d77f585eeca6569
Commit:        717d0c6b94c81730582eb3000d77f585eeca6569
Parent:        b185a3e3334e72c3aae6791ec4cb8768d55e0b9b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 17:43:52 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 10:06:18 2017 +0100

cleanup: use proper printf specifier

---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 34e117e..8589db3 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4557,7 +4557,7 @@ static int _stats_unmap_regions(struct dm_stats *dms, uint64_t group_id,
 		log_error("Could not finalize region extent table.");
 		goto out;
 	}
-	log_very_verbose("Kept %ld of %ld old extents",
+	log_very_verbose("Kept " FMTi64 " of " FMTi64 " old extents",
 			 nr_kept, nr_old);
 	log_very_verbose("Found " FMTu64 " new extents",
 			 *count - nr_kept);


