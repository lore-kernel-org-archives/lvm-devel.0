From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:01:49 +0000 (UTC)
Subject: master - debug: vgdisplay trace failing result code
Message-ID: <20150818130149.C840B60D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b19380998739b9971d27845a70a78511c2335cb0
Commit:        b19380998739b9971d27845a70a78511c2335cb0
Parent:        a8fd88463e662b769073e7b06d1a5acfd07fbc13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 11:46:13 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 15:00:08 2015 +0200

debug: vgdisplay trace failing result code

Add stack on error path.
---
 tools/vgdisplay.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 5e5ceda..0127e7c 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -22,7 +22,8 @@ static int vgdisplay_single(struct cmd_context *cmd, const char *vg_name,
 	if (arg_count(cmd, activevolumegroups_ARG) && !lvs_in_vg_activated(vg))
 		return ECMD_PROCESSED;
 
-	vg_check_status(vg, EXPORTED_VG);
+	if (!vg_check_status(vg, EXPORTED_VG))
+		stack;
 
 	if (arg_count(cmd, colon_ARG)) {
 		vgdisplay_colons(vg);


