From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 5 Apr 2017 18:35:29 -0400
Subject: master - man: lvmraid.7 raid6_n_6 fix
Message-ID: <201704052235.v35MZTeS004371@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8d5ada452570e1c9b0c6e0ae0a311870056896a
Commit:        a8d5ada452570e1c9b0c6e0ae0a311870056896a
Parent:        d23cad16c9210f6b01994a5e4c0637584dba80f9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Apr 6 00:35:12 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Apr 6 00:35:12 2017 +0200

man: lvmraid.7 raid6_n_6 fix

---
 man/lvmraid.7_main |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 7a3235b..d000687 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -1554,7 +1554,8 @@ raid6_n_6
 RAID6 last parity devices
 .br
 \[bu]
-Dedicated last parity devices used for striped/raid0 conversions
+Fixed dedicated last devices (P-Syndrome N-1 and Q-Syndrome N)
+with striped data used for striped/raid0 conversions
 \[bu]
 Used for RAID Takeover
 
@@ -1566,17 +1567,6 @@ RAID6 last parity device
 \[bu]
 Dedicated last parity device used for conversions from/to raid5_{ls,rs,la,ra}
 
-raid6_n_6
-.br
-\[bu]
-RAID6 N continue
-.br
-\[bu]
-Fixed P-Syndrome N-1 and Q-Syndrome N with striped data
-.br
-\[bu]
-Used for RAID Takeover
-
 raid6_ls_6
 .br
 \[bu]


