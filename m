From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 26 Oct 2017 12:49:06 -0400
Subject: master - dmsetup: Add unknown device error to dmsetup status.
Message-ID: <201710261649.v9QGn6Bn019687@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b0f6829f63d36b473f6670a41ac7521ff82674d
Commit:        4b0f6829f63d36b473f6670a41ac7521ff82674d
Parent:        fdcc709ed0e5051f471ee64ac51f6c8e2ed941fc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Oct 26 17:47:13 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Oct 26 17:47:13 2017 +0100

dmsetup: Add unknown device error to dmsetup status.

Treat status the same way as info if provided device name doesn't exist.
---
 WHATS_NEW_DM    |    1 +
 tools/dmsetup.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b0dd01b..6475fbd 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.145 - 
 ===================================
+  Issue a specific error with dmsetup status if device is unknown.
   Fix RT_LIBS reference in generated libdevmapper.pc for pkg-config
 
 Version 1.02.144 - 6th October 2017
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 661910f..53097b3 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2431,9 +2431,14 @@ static int _status(CMD_ARGS)
 	if (!_task_run(dmt))
 		goto_out;
 
-	if (!dm_task_get_info(dmt, &info) || !info.exists)
+	if (!dm_task_get_info(dmt, &info))
 		goto_out;
 
+	if (!info.exists) {
+		fprintf(stderr, "Device does not exist.\n");
+		goto_out;
+	}
+
 	if (!name)
 		name = dm_task_get_name(dmt);
 


