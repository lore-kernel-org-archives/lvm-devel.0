From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 7 Nov 2019 11:47:47 -0500
Subject: stable-2.02 - man: adjust 'disks' to 'devices' as used throughout
Message-ID: <201911071647.xA7GllEd002796@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ffd959d2c0c1a5108e91efa77ac06d185fd8edb6
Commit:        ffd959d2c0c1a5108e91efa77ac06d185fd8edb6
Parent:        343d80a7fe883d84aaa27f0a6960a20fa20ce790
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Nov 7 17:47:35 2019 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Nov 7 17:47:35 2019 +0100

man: adjust 'disks' to 'devices' as used throughout

---
 man/lvmraid.7_main |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index c27f1fa..151771b 100644
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
+Same as raid5_ra for N-1 devices with fixed Q-Syndrome N
 .br
 \[bu]
 Used for RAID Takeover


