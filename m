From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 19 May 2016 20:07:50 +0000 (UTC)
Subject: master - tools: improve error message about VG name and select
Message-ID: <20160519200750.2935B60D80@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ad4ca55543428f909fde8ba03e88d355560fe320
Commit:        ad4ca55543428f909fde8ba03e88d355560fe320
Parent:        6247364caf69cce766efcc79d972f70b175c5938
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 19 15:06:56 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 19 15:06:56 2016 -0500

tools: improve error message about VG name and select

---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 4859ec0..17a29e0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1979,7 +1979,7 @@ static int _resolve_duplicate_vgnames(struct cmd_context *cmd,
 		 * is unknown.
 		 */
 		log_error("Multiple VGs found with the same name: skipping %s", sl->str);
-		log_error("Use the VG UUID with --select vg_uuid=<uuid>");
+		log_error("Use --select vg_uuid=<uuid> in place of the VG name.");
 		dm_list_del(&sl->list);
 		ret = ECMD_FAILED;
 	}


