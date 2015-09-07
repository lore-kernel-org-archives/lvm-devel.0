From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  7 Sep 2015 19:15:03 +0000 (UTC)
Subject: master - libdm: fix display of nsec suffixes in histogram strings
Message-ID: <20150907191503.2D8CE61655@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=daa94eb792ee76a507dcafe74c5ceda9707a370f
Commit:        daa94eb792ee76a507dcafe74c5ceda9707a370f
Parent:        5f990473e46b97e4642744798429c02f7ddc0763
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 7 20:11:28 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 7 20:14:53 2015 +0100

libdm: fix display of nsec suffixes in histogram strings

---
 libdm/libdm-stats.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 4e5210d..f239f01 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2148,6 +2148,7 @@ void dm_histogram_bounds_destroy(struct dm_histogram *bounds)
  */
 static void _scale_bound_value_to_suffix(uint64_t *bound, const char **suffix)
 {
+	*suffix = "ns";
 	if (!(*bound % NSEC_PER_SEC)) {
 		*bound /= NSEC_PER_SEC;
 		*suffix = "s";


