From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  4 Sep 2015 10:48:36 +0000 (UTC)
Subject: master - libdm: fix uninitialized variable warnings on older gcc
Message-ID: <20150904104836.97B7D6105C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cdca2782d2b43c20d552d64359ac0ce80d24af5f
Commit:        cdca2782d2b43c20d552d64359ac0ce80d24af5f
Parent:        cebbb0feafb97516377388eb1747e3207c4f0596
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Sep 4 11:40:19 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Sep 4 11:46:48 2015 +0100

libdm: fix uninitialized variable warnings on older gcc

Older versions of gcc aren't able to track the assignments of
local variables as well as the latest versions leading to spurious
warnings like:

libdm-stats.c:2183: warning: "len" may be used uninitialized in this
function
libdm-stats.c:2177: warning: "minwidth" may be used uninitialized in
this function

Both of these variables are in fact assigned in all possible paths
through the function and later compilers do not produce these
warnings.

There's no reason to not initialize these variables though and
it makes the function slightly easier to follow.

Also fix one use of 'unsigned' for a nr_bins value.
---
 libdm/libdm-stats.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 90f2e1d..736aae5 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -419,7 +419,7 @@ static int _stats_parse_histogram_spec(struct dm_stats *dms,
 	struct dm_pool *mem = dms->hist_mem;
 	struct dm_histogram_bin cur;
 	struct dm_histogram hist;
-	unsigned nr_bins = 1;
+	int nr_bins = 1;
 	const char *c, *v;
 	char *p;
 
@@ -2180,7 +2180,7 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 	struct dm_pool *mem = dmh->dms->hist_mem;
 	char buf[64], bounds_buf[64];
 	const char *sep = "";
-	ssize_t len;
+	ssize_t len = 0;
 
 	bounds = flags & DM_HISTOGRAM_BOUNDS_MASK;
 	values = flags & DM_HISTOGRAM_VALUES;
@@ -2191,6 +2191,8 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 	} else
 		start = last = bin;
 
+	minwidth = width;
+
 	if (width < 0 || !values)
 		width = minwidth = 0; /* no padding */
 	else if (flags & DM_HISTOGRAM_PERCENT)


