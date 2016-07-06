From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  6 Jul 2016 09:01:37 +0000 (UTC)
Subject: master - dmstats: simplify nr_areas calculation (CWE-561)
Message-ID: <20160706090137.84ADA60787@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1faa208067df2989c716fff40568f3948392b186
Commit:        1faa208067df2989c716fff40568f3948392b186
Parent:        21b946dfb75c893827ce5caafd16cb09be4fbeeb
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jul 4 19:25:40 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jul 6 09:59:45 2016 +0100

dmstats: simplify nr_areas calculation (CWE-561)

Eliminate dead conditional (step cannot be zero).

Fixes commit 988ca74.
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4d9bb07..b675625 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4745,7 +4745,7 @@ static uint64_t _nr_areas_from_step(uint64_t len, int64_t step)
 		return (uint64_t)(-step);
 
 	/* --areasize - cast step to unsigned as it cannot be -ve here. */
-	return (len / (step ? : len)) + !!(len % (uint64_t) step);
+	return (len / step) + !!(len % (uint64_t) step);
 }
 
 /*


