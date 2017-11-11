From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Nov 2017 19:03:12 -0500
Subject: master - cleanup: remove stack tracing for ok path
Message-ID: <201711110003.vAB03CcN009565@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ac7fde67b10c2bdfa37d1cf3f2ce48033f27baf
Commit:        1ac7fde67b10c2bdfa37d1cf3f2ce48033f27baf
Parent:        b9ac1c12d0966714a918154e97864faf0a916170
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 10 13:41:45 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 11 00:56:10 2017 +0100

cleanup: remove stack tracing for ok path

---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 3b89568..2898525 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4337,7 +4337,7 @@ endvg:
 		/* Quit early when possible. */
 		if (!process_all_pvs && dm_list_empty(arg_tags) && dm_list_empty(arg_devices)) {
 			do_report_ret_code = 0;
-			goto_out;
+			goto out;
 		}
 
 		log_set_report_object_name_and_id(NULL, NULL);


