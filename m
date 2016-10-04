From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  4 Oct 2016 21:26:24 +0000 (UTC)
Subject: master - toollib: clean up coverity issue
Message-ID: <20161004212624.25CD460E8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf5d0a2651e199bf7f2b737ebcfd5bbe17878d0f
Commit:        bf5d0a2651e199bf7f2b737ebcfd5bbe17878d0f
Parent:        c900cf7ed40e541fa8b2eeeb084c1061382e0b1e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 4 16:25:32 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 4 16:25:32 2016 -0500

toollib: clean up coverity issue

in processing duplicate pvs.
---
 tools/toollib.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 9127d85..9763362 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3264,9 +3264,12 @@ static int _process_duplicate_pvs(struct cmd_context *cmd,
 		 * Don't pass dev to lvmcache_info_from_pvid because we looking
 		 * for the chosen/preferred dev for this pvid.
 		 */
-		info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0);
-		if (info)
-			vgname = lvmcache_vgname_from_info(info);
+		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, NULL, 0))) {
+			log_error(INTERNAL_ERROR "No info for pvid");
+			return_ECMD_FAILED;
+		}
+
+		vgname = lvmcache_vgname_from_info(info);
 		if (vgname)
 			vgid = lvmcache_vgid_from_vgname(cmd, vgname);
 		if (vgid)


