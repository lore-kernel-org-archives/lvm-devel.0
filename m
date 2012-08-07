From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:30 +0000 (UTC)
Subject: master - activation: log target version present
Message-ID: <20120807203030.239F63283@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0650a16a2273f9ce8b224533083055b67cbff892
Commit:        0650a16a2273f9ce8b224533083055b67cbff892
Parent:        7b5ea9a5a89b4eff41520142f719a7d89435f7df
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 18:47:33 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 18:47:33 2012 +0100

activation: log target version present

Log (very verbose) the target version present in target_version.
---
 lib/activate/activate.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3156f01..512adcf 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -514,6 +514,11 @@ int target_version(const char *target_name, uint32_t *maj,
 	} while (last_target != target);
 
       out:
+	if (r)
+		log_very_verbose("Found %s target "
+				 "v%" PRIu32 ".%" PRIu32 ".%" PRIu32 ".",
+				 target_name, *maj, *min, *patchlevel);
+
 	dm_task_destroy(dmt);
 
 	return r;


