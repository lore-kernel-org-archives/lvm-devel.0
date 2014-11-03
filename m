From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:26 +0000 (UTC)
Subject: master - filters: change return code
Message-ID: <20141103132326.07CDF602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dc11dcf11d90f24c8d37988f3029e29cc6a45441
Commit:        dc11dcf11d90f24c8d37988f3029e29cc6a45441
Parent:        c1ee6d4ffc7d520e015a8e44f50392510fb85167
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 20:25:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:32 2014 +0100

filters: change return code

No data for writing should be seen as 'dump' success.
(reduces one <bactrace> in the log) - it has no other
effect.
---
 lib/filters/filter-persistent.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 600fa38..3c1701b 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -193,7 +193,7 @@ static int _persistent_filter_dump(struct dev_filter *f, int merge_existing)
 	if (!dm_hash_get_num_entries(pf->devices)) {
 		log_very_verbose("Internal persistent device cache empty "
 				 "- not writing to %s", pf->file);
-		return 0;
+		return 1;
 	}
 	if (!dev_cache_has_scanned()) {
 		log_very_verbose("Device cache incomplete - not writing "


