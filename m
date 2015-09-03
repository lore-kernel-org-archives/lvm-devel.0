From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  3 Sep 2015 15:39:02 +0000 (UTC)
Subject: master - vgrename: add missing trace on error path
Message-ID: <20150903153902.2E7EF602E8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a73a5012aece3d0f7fd03a270cfe5067c1fafc8
Commit:        0a73a5012aece3d0f7fd03a270cfe5067c1fafc8
Parent:        96dc03b33782cf0e33f5fdf57cd8eb475e4bd7c9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 3 10:38:16 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 3 10:38:16 2015 -0500

vgrename: add missing trace on error path

---
 tools/vgrename.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tools/vgrename.c b/tools/vgrename.c
index 620345b..316228a 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -149,8 +149,10 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	if (!drop_cached_metadata(vg))
 		stack;
 
-	if (!lockd_rename_vg_before(cmd, vg))
+	if (!lockd_rename_vg_before(cmd, vg)) {
+		stack;
 		goto error;
+	}
 
 	/* Change the volume group name */
 	vg_rename(cmd, vg, vg_name_new);


