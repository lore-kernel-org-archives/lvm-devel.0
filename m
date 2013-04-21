From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 21 Apr 2013 21:16:49 +0000 (UTC)
Subject: master - thin: fix resource leak in err path
Message-ID: <20130421211649.A2B7311FE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2b76a6f022920abd59072decfa7d3d76eeda913
Commit:        a2b76a6f022920abd59072decfa7d3d76eeda913
Parent:        17a691505467cd5a73059fe5ca22fe50dafd345a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 12:19:25 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:10:30 2013 +0200

thin: fix resource leak in err path

If the devices list could not have been obtained, FILE* was leaked.
---
 WHATS_NEW                                     |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b016b8e..5d4c7a7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix memleak in dmeventd thin plugin in device list obtaining err path.
   Add explicit message about unsupported pvmove for thin/thinpool volumes.
   Fix lvmetad error path in lvmetad_vg_lookup() for null vgname.
   Fix clvmd _cluster_request() return code in memory fail path.
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index ba72c4a..95ab27a 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -246,7 +246,7 @@ static void _umount(struct dm_task *dmt, const char *device)
 {
 	static const char mountinfo[] = "/proc/self/mountinfo";
 	static const size_t MINORS = 4096;
-	FILE *minfo;
+	FILE *minfo = NULL;
 	char buffer[4096];
 	char target[PATH_MAX];
 	struct dm_info info;
@@ -288,10 +288,10 @@ static void _umount(struct dm_task *dmt, const char *device)
 		}
 	}
 
-	if (fclose(minfo))
+out:
+	if (minfo && fclose(minfo))
 		syslog(LOG_ERR, "Failed to close %s\n", mountinfo);
 
-out:
 	if (minors)
 		dm_bitset_destroy(minors);
 	dmeventd_lvm2_lock();


