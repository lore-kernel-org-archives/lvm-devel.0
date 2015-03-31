From: okozina <okozina@fedoraproject.org>
Date: Tue, 31 Mar 2015 09:32:10 +0000 (UTC)
Subject: master - polldaemon: proper error check in _poll_vg fn
Message-ID: <20150331093210.1773E60E57@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=663254d7a5d84ef5803875806c461513f581f4e2
Commit:        663254d7a5d84ef5803875806c461513f581f4e2
Parent:        b9e6e66de15ca638ca504a07d6476e571a6197d3
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Mar 31 11:26:53 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Mar 31 11:26:53 2015 +0200

polldaemon: proper error check in _poll_vg fn

could theoretically cause NULL pointer dereference
---
 tools/polldaemon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 5383812..20a18fa 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -191,7 +191,7 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 		    struct volume_group *vg, struct processing_handle *handle)
 {
-	struct daemon_parms *parms = (struct daemon_parms *) handle->custom_handle;
+	struct daemon_parms *parms;
 	struct lv_list *lvl;
 	struct dm_list *sls;
 	struct dm_str_list *sl;
@@ -199,7 +199,7 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 	const char *name;
 	int finished;
 
-	if (!parms) {
+	if (!handle || !(parms = (struct daemon_parms *) handle->custom_handle)) {
 		log_error(INTERNAL_ERROR "Handle is undefined.");
 		return ECMD_FAILED;
 	}


