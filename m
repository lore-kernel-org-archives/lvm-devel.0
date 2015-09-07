From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  7 Sep 2015 10:53:21 +0000 (UTC)
Subject: master - libdm: check dm_pool_begin_object() return value.
Message-ID: <20150907105321.6518060093@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e75b4bc2df7ce9bf3b3644fb0e6d9d52467adb8e
Commit:        e75b4bc2df7ce9bf3b3644fb0e6d9d52467adb8e
Parent:        36b09fd1471ecbae84b22075b46fada2bd8761ee
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Sep 7 11:52:54 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Sep 7 11:52:54 2015 +0100

libdm: check dm_pool_begin_object() return value.

---
 libdm/libdm-stats.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 5616370..0655ac5 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -717,7 +717,8 @@ static int _stats_parse_histogram(struct dm_pool *mem, char *hist_str,
 
 	c = hist_str;
 
-	dm_pool_begin_object(mem, sizeof(cur));
+	if (!dm_pool_begin_object(mem, sizeof(cur)))
+		return_0;
 
 	hist.nr_bins = nr_bins;
 


