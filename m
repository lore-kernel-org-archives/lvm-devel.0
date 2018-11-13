From: David Teigland <teigland@sourceware.org>
Date: Tue, 13 Nov 2018 18:28:58 -0500
Subject: master - pvscan: background option is not used
Message-ID: <201811132328.wADNSwjR006732@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=819b469880e9f6b18e76d3f1cdbd3e69fe5dab3e
Commit:        819b469880e9f6b18e76d3f1cdbd3e69fe5dab3e
Parent:        cbee4d3d8843e14368f5f68531ef8ab429287077
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 13 17:27:53 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 13 17:27:53 2018 -0600

pvscan: background option is not used

Move this into the list of ignored options so
it doesn't appear in the man page.
---
 tools/command-lines.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index a8e7272..018153a 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1481,9 +1481,10 @@ ID: pvscan_display
 DESC: Display PV information.
 
 pvscan --cache_long
-OO: --ignorelockingfailure, --reportformat ReportFmt, --background,
+OO: --ignorelockingfailure, --reportformat ReportFmt,
 --activate ay, --major Number, --minor Number
 OP: PV|String ...
+IO: --background
 ID: pvscan_cache
 DESC: Autoactivate a VG when all PVs are online.
 


