From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:26 +0000 (UTC)
Subject: master - libdm: ensure vars are initialized
Message-ID: <20151109092826.C94F260CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6c140e200177ef527c8943fbe0a94e2e6bd8b3f
Commit:        f6c140e200177ef527c8943fbe0a94e2e6bd8b3f
Parent:        b1c4017743060a25a6a263244d9d0e18c09acda5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 8 17:21:22 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

libdm: ensure vars are initialized

Coverity found potential error path, where code could
have used some unset variables.
---
 libdm/libdm-stats.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index d3ae1f2..43479d9 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -822,7 +822,7 @@ static int _stats_parse_region(struct dm_stats *dms, const char *resp,
 	struct dm_pool *mem = dms->mem;
 	struct dm_stats_counters cur;
 	FILE *stats_rows = NULL;
-	uint64_t start, len;
+	uint64_t start = 0, len = 0;
 	char row[256];
 	int r;
 
@@ -2305,6 +2305,10 @@ const char *dm_histogram_to_string(const struct dm_histogram *dmh, int bin,
 		} else if (bounds)
 			len = dm_snprintf(buf, sizeof(buf), "%s%s", bounds_buf,
 					  sep);
+		else {
+			*buf = '\0';
+			len = 0;
+		}
 
 		if (len < 0)
 			goto_bad;


