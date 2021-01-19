From: David Teigland <teigland@sourceware.org>
Date: Tue, 19 Jan 2021 17:28:20 +0000 (GMT)
Subject: main - pvck: fix warning and exit code for non-4k mda1 offset
Message-ID: <20210119172820.C188E3851C2B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74adbec77f77cd725bbac7ab3f3fb964d8b1e1f0
Commit:        74adbec77f77cd725bbac7ab3f3fb964d8b1e1f0
Parent:        2ec29d0677a5f92728873b5b1e303478cd71a3e4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 19 11:21:20 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 19 11:21:20 2021 -0600

pvck: fix warning and exit code for non-4k mda1 offset

Print a warning if mda1 is not 4k, 8k or 64k.
Don't exit with an error for any unexpected mda1 offset.
---
 tools/pvck.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index c36e18216..88350de8c 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1140,9 +1140,13 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 			*mda1_offset = xlate64(dlocn->offset);
 			*mda1_size = xlate64(dlocn->size);
 
-			if (*mda1_offset != 4096) {
-				log_print("CHECK: pv_header.disk_locn[%d].offset expected 4096 # for first mda", di);
-				bad++;
+			/*
+			 * mda1 offset is page size from machine that created it,
+			 * warn if it's not one of the expected page sizes.
+			 */
+			if ((*mda1_offset != 4096) && (*mda1_offset != 8192) && (*mda1_offset != 65536)) {
+				log_print("WARNING: pv_header.disk_locn[%d].offset %llu is unexpected # for first mda",
+					  di, (unsigned long long)*mda1_offset);
 			}
 		} else {
 			*mda2_offset = xlate64(dlocn->offset);


