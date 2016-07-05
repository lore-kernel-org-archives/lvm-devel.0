From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:34:37 +0000 (UTC)
Subject: master - libdm: fix histogram pool user-after-free (CWE-825)
Message-ID: <20160705183437.5F69860E42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7145d666fc269f3c808a420883910013e3ed3746
Commit:        7145d666fc269f3c808a420883910013e3ed3746
Parent:        f3afd1bd133e896a8e23a3ecf35940983b0429bc
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Jul 4 18:20:09 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:49 2016 +0100

libdm: fix histogram pool user-after-free (CWE-825)

---
 libdm/libdm-stats.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index f1c0560..3d53755 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -158,8 +158,8 @@ struct dm_stats *dm_stats_create(const char *program_id)
 		dms->program_id = dm_strdup(program_id);
 
 	if (!dms->program_id) {
-		dm_pool_destroy(dms->hist_mem);
-		goto_bad;
+		log_error("Could not allocate memory for program_id");
+		goto bad;
 	}
 
 	dms->major = -1;


