From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:45:17 -0400
Subject: stable-2.02 - cov: clearer condition check
Message-ID: <201906251545.x5PFjHWb013095@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bea252a636ff0de2266c1ce760b3a6047f0ff2f
Commit:        8bea252a636ff0de2266c1ce760b3a6047f0ff2f
Parent:        66665f5e428c2b3d7f4dbcd3e88a872db0381b93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 15:08:10 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:33:47 2019 +0200

cov: clearer condition check

Make the code more obvious.
---
 lib/activate/activate.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b3b8a25..561a965 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2478,7 +2478,12 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 	 * If vg_commit() did not happen, lvmcache_get_saved_vg_latest
 	 * returns the old metadata which we use to resume LVs.
 	 */
-	if (!lv && lvid_s) {
+	if (!lv) {
+		if (!lvid_s) {
+			log_error(INTERNAL_ERROR "Requested resume of unindentified resource!");
+			return 0;
+		}
+
 		lvid = (const union lvid *) lvid_s;
 		vgid = (const char *)lvid->id[0].uuid;
 


