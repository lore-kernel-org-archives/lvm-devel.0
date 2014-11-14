From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Nov 2014 17:17:41 +0000 (UTC)
Subject: master - debug: better message for pool zeroing state
Message-ID: <20141114171741.2321760DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b6f921e5cb1877263ef5561d6f96141022ff3c6f
Commit:        b6f921e5cb1877263ef5561d6f96141022ff3c6f
Parent:        38200c2000e5499a6421f477305464f9772b8d57
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 14 16:11:16 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 14 18:12:35 2014 +0100

debug: better message for pool zeroing state

---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 02a1bbf..e6573fb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -980,7 +980,7 @@ int get_pool_params(struct cmd_context *cmd,
 		if (arg_is_set(cmd, zero_ARG)) {
 			*passed_args |= PASS_ARG_ZERO;
 			*zero = arg_int_value(cmd, zero_ARG, 1);
-			log_very_verbose("Setting pool zeroing: %u", *zero);
+			log_very_verbose("%s pool zeroing.", *zero ? "Enabling" : "Disabling");
 		}
 		if (arg_is_set(cmd, discards_ARG)) {
 			*passed_args |= PASS_ARG_DISCARDS;


