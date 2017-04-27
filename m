From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 27 Apr 2017 10:01:00 -0400
Subject: master - pvresize: Missing a message on error path.
Message-ID: <201704271401.v3RE10d4001902@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e3c16af5699c000f1824c42c596fec58d019dfa
Commit:        0e3c16af5699c000f1824c42c596fec58d019dfa
Parent:        33afe2ca76e4bddcfa33aafa2fed28d4ca60e08e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 27 14:59:40 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 27 15:00:41 2017 +0100

pvresize: Missing a message on error path.

---
 lib/metadata/pv_manip.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 6ee4828..a8cd763 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -648,14 +648,18 @@ int pv_resize_single(struct cmd_context *cmd,
 				 pv_name, display_size(cmd, (uint64_t) size));
 			if (!yes && yes_no_prompt("%s: Requested size %s exceeds real size %s. Proceed?  [y/n]: ",
 						  pv_name, display_size(cmd, (uint64_t) new_size),
-						  display_size(cmd, (uint64_t) size)) == 'n')
+						  display_size(cmd, (uint64_t) size)) == 'n') {
+				log_error("Physical Volume %s not resized.", pv_name);
 				goto_out;
+			}
 
 		}  else if (new_size < size)
 			if (!yes && yes_no_prompt("%s: Requested size %s is less than real size %s. Proceed?  [y/n]: ",
 						  pv_name, display_size(cmd, (uint64_t) new_size),
-						  display_size(cmd, (uint64_t) size)) == 'n')
+						  display_size(cmd, (uint64_t) size)) == 'n') {
+				log_error("Physical Volume %s not resized.", pv_name);
 				goto_out;
+			}
 
 		if (new_size == size)
 			log_verbose("%s: Size is already %s (%" PRIu64 " sectors).",


