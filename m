From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 17:40:24 -0400
Subject: master - man lvmlockd: update list of limitations
Message-ID: <201805312140.w4VLeOfw003315@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81f07c3cca417bbf8d290073a20586b47a6d127e
Commit:        81f07c3cca417bbf8d290073a20586b47a6d127e
Parent:        885eb2024ffff6757bba39666a1d334d6d72a066
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 16:38:39 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 16:38:39 2018 -0500

man lvmlockd: update list of limitations

---
 man/lvmlockd.8_main |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 90a07c7..9fe569d 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -843,12 +843,6 @@ to a lockd VG".
 Things that do not yet work in lockd VGs:
 .br
 \[bu]
-creating a new thin pool and a new thin LV in a single command
-.br
-\[bu]
-using lvcreate to create cache pools or cache LVs (use lvconvert)
-.br
-\[bu]
 using external origins for thin LVs
 .br
 \[bu]
@@ -861,10 +855,7 @@ splitting mirrors in sanlock VGs
 pvmove of entire PVs, or under LVs activated with shared locks
 .br
 \[bu]
-vgsplit
-.br
-\[bu]
-vgmerge
+vgsplit and vgmerge (convert to a local VG to do this)
 
 
 .SS lvmlockd changes from clvmd


