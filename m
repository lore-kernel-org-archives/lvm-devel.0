From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 7 Nov 2019 11:46:04 -0500
Subject: master - man: adjust 'disks' to 'devices' as used throughout
Message-ID: <201911071646.xA7Gk4qF002403@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e184f77109d973297fa80edaa8dca7447b64b40e
Commit:        e184f77109d973297fa80edaa8dca7447b64b40e
Parent:        8263e62b00959c2bef18dff7821b242aefd5547f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Nov 7 17:45:37 2019 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Nov 7 17:45:37 2019 +0100

man: adjust 'disks' to 'devices' as used throughout

---
 man/lvmraid.7_main |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index c27f1fa..498de90 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -1688,7 +1688,7 @@ raid6_ls_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_ls for N-1 disks with fixed Q-Syndrome N
+Same as raid5_ls for N-1 devices with fixed Q-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover
@@ -1699,7 +1699,7 @@ raid6_la_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_la for N-1 disks with fixed Q-Syndrome N
+Same as raid5_la for N-1 devices with fixed Q-Syndrome N
 .br
 \[bu]
 Used forRAID Takeover
@@ -1710,7 +1710,7 @@ raid6_rs_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_rs for N-1 disks with fixed Q-Syndrome N
+Same as raid5_rs for N-1 devices with fixed Q-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover
@@ -1721,7 +1721,7 @@ raid6_ra_6
 RAID6 N continue
 .br
 \[bu]
-Same as raid5_ra for N-1 disks with fixed Q-Syndrome N
+ame as raid5_ra for N-1 devices with fixed Q-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover


