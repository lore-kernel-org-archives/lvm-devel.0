From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 26 Oct 2015 21:28:01 +0000 (UTC)
Subject: master - toollib: fix wrong paren placement
Message-ID: <20151026212801.C8BA160FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=44ba862674c995e2ed297714d3aa2b2dbd731ad1
Commit:        44ba862674c995e2ed297714d3aa2b2dbd731ad1
Parent:        6624833839645cbe75af073fd1dd9ab8c78e0d03
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 26 16:27:26 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 26 16:27:26 2015 -0500

toollib: fix wrong paren placement

---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 843a47b..59ba29f 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3119,7 +3119,7 @@ int process_each_pv(struct cmd_context *cmd,
 		return ret;
 	}
 
-	if ((ret = _get_arg_devices(cmd, &arg_pvnames, &arg_devices) != ECMD_PROCESSED))
+	if ((ret = _get_arg_devices(cmd, &arg_pvnames, &arg_devices)) != ECMD_PROCESSED)
 		/* get_arg_devices reports the error for any PV names not found. */
 		ret_max = ECMD_FAILED;
 


