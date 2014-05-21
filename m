From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 22:56:01 +0000 (UTC)
Subject: master - vgcfgrestore: return invalid cmd line
Message-ID: <20140521225601.837FE609E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ac7d2deb4270504dbae369b0b1bf14cb25a1b38
Commit:        3ac7d2deb4270504dbae369b0b1bf14cb25a1b38
Parent:        9c4953df1b5b2e2e509f6f89598a733d5d580f2b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 23:11:15 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 23:14:41 2014 +0200

vgcfgrestore: return invalid cmd line

When error is detected on command line options, return '3'.
---
 tools/vgcfgrestore.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 36396c3..07c5c20 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -23,11 +23,11 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
 		if (!validate_name(vg_name)) {
 			log_error("Volume group name \"%s\" is invalid", vg_name);
-			return ECMD_FAILED;
+			return EINVALID_CMD_LINE;
 		}
 	} else if (!(arg_count(cmd, list_ARG) && arg_count(cmd, file_ARG))) {
 		log_error("Please specify a *single* volume group to restore.");
-		return ECMD_FAILED;
+		return EINVALID_CMD_LINE;
 	}
 
 	/*


