From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 25 Jan 2017 15:29:56 +0000 (UTC)
Subject: master - libdm: test for DM_STATS_GROUP_NOT_PRESENT in _stats_group_id_present
Message-ID: <20170125152956.D0C4C614D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c00bb5da3a53152c5f9e0c9d3382afdec1b2455
Commit:        1c00bb5da3a53152c5f9e0c9d3382afdec1b2455
Parent:        ca427a711a33b02264689dcfca4bc5e5d2f9434e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jan 25 15:10:59 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jan 25 15:29:35 2017 +0000

libdm: test for DM_STATS_GROUP_NOT_PRESENT in _stats_group_id_present

If the group_id passed to _stats_group_id_present is equal to the
special value DM_STATS_GROUP_NOT_PRESENT there is no need to perform
any further tests: return false immediately.
---
 libdm/libdm-stats.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 6e79a09..f10c6d6 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -261,6 +261,9 @@ static int _stats_group_id_present(const struct dm_stats *dms, uint64_t id)
 {
 	struct dm_stats_group *group = NULL;
 
+	if (id == DM_STATS_GROUP_NOT_PRESENT)
+		return 0;
+
 	if (!dms || !dms->regions)
 		return_0;
 


