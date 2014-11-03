From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:55 +0000 (UTC)
Subject: master - cleanup: use arg_is_set
Message-ID: <20141103132355.3F49960243@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d574072dd8eb11f54c2f9835e49da5b193cdfca7
Commit:        d574072dd8eb11f54c2f9835e49da5b193cdfca7
Parent:        ca9482b276c4a74021d158e4b9c8e8a18dd50e35
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 11:41:03 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:33 2014 +0100

cleanup: use arg_is_set

---
 tools/toollib.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0472597..5906ccb 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -978,13 +978,12 @@ int get_pool_params(struct cmd_context *cmd,
 	*passed_args = 0;
 
 	if (segtype_is_thin_pool(segtype) || segtype_is_thin(segtype)) {
-		if (arg_count(cmd, zero_ARG)) {
+		if (arg_is_set(cmd, zero_ARG)) {
 			*passed_args |= PASS_ARG_ZERO;
 			*zero = arg_int_value(cmd, zero_ARG, 1);
 			log_very_verbose("Setting pool zeroing: %u", *zero);
 		}
-
-		if (arg_count(cmd, discards_ARG)) {
+		if (arg_is_set(cmd, discards_ARG)) {
 			*passed_args |= PASS_ARG_DISCARDS;
 			*discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, 0);
 			log_very_verbose("Setting pool discards: %s",


