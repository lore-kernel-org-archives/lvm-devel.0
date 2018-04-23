From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:49:57 -0400
Subject: master - remove unused variable in _pvremove_check_single
Message-ID: <201804231349.w3NDnvOd031752@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c29899b910811d0d1dc5607d200a1e59773eff0c
Commit:        c29899b910811d0d1dc5607d200a1e59773eff0c
Parent:        a1e3398ffcf5def36934eabbb9ea26db221bbe74
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 13 14:28:24 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:46 2018 -0500

remove unused variable in _pvremove_check_single

---
 tools/toollib.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0cc2edd..807e34c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -5279,7 +5279,6 @@ static int _pvremove_check_single(struct cmd_context *cmd,
 	struct pvcreate_params *pp = (struct pvcreate_params *) handle->custom_handle;
 	struct pvcreate_device *pd;
 	struct pvcreate_prompt *prompt;
-	struct label *label;
 	int found = 0;
 
 	if (!pv->dev)


