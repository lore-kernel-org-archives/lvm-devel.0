From: David Teigland <teigland@sourceware.org>
Date: Tue, 19 Sep 2017 10:20:34 -0400
Subject: master - toollib: fix parentheses in assignment + comparison
Message-ID: <201709191420.v8JEKYif023743@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5407327bc6fff77dabb6dd55150832373ba163a7
Commit:        5407327bc6fff77dabb6dd55150832373ba163a7
Parent:        200793edc681ac956e9341af6b5f20dc4e3f9ee8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 19 09:19:24 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 19 09:19:24 2017 -0500

toollib: fix parentheses in assignment + comparison

---
 tools/toollib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 1799bc9..bf3e9d6 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4464,7 +4464,7 @@ int process_each_pv(struct cmd_context *cmd,
 	 * from all VGs are processed first, removing them from all_devices.  Then
 	 * any devs remaining in all_devices are processed.
 	 */
-	if ((ret = _get_all_devices(cmd, &all_devices) != ECMD_PROCESSED)) {
+	if ((ret = _get_all_devices(cmd, &all_devices)) != ECMD_PROCESSED) {
 		ret_max = ret;
 		goto_out;
 	}


