From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 17:26:25 -0400
Subject: master - pvscan: define command as taking only -aay
Message-ID: <201705032126.v43LQPn7006741@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5de3870662688ca2a81a94f7f0422dea15949566
Commit:        5de3870662688ca2a81a94f7f0422dea15949566
Parent:        b869db30ac9d22fbdf17218d6bdc9356922e397c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 15:46:49 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 15:46:49 2017 -0500

pvscan: define command as taking only -aay

The fact that -an and -ay are not accepted can be
stated in the command definition.
---
 tools/command-lines.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 2d9e48e..7f9c31f 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1417,7 +1417,7 @@ DESC: Display PV information.
 
 pvscan --cache_long
 OO: --ignorelockingfailure, --reportformat ReportFmt, --background,
---activate Active, --major Number, --minor Number
+--activate ay, --major Number, --minor Number
 OP: PV|String ...
 ID: pvscan_cache
 DESC: Populate the lvmetad cache by scanning PVs.


