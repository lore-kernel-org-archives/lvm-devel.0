From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 21:10:31 +0000 (UTC)
Subject: master - libdm: clear region table in dm_stats_list()
Message-ID: <20161218211031.6287860D37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=009b711834d26610d23d14bd8b7540eb69c836a7
Commit:        009b711834d26610d23d14bd8b7540eb69c836a7
Parent:        8d6ac1c3ba2ee72e9832383609b6ff030d9883ce
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Dec 15 19:03:42 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 20:44:31 2016 +0000

libdm: clear region table in dm_stats_list()

Call _stats_regions_destroy() from dm_stats_list() if dms->regions
is non-NULL. This avoids leaking any pool allocations and ensures
the handle is in a known state: if an error occurs during the list,
dms->regions will be NULL and the handle will appear empty.
---
 libdm/libdm-stats.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 8d202d2..3978244 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1083,6 +1083,9 @@ int dm_stats_list(struct dm_stats *dms, const char *program_id)
 	if (!_stats_set_name_cache(dms))
 		return_0;
 
+	if (dms->regions)
+		_stats_regions_destroy(dms);
+
 	r = dm_snprintf(msg, sizeof(msg), "@stats_list %s", program_id);
 
 	if (r < 0) {


