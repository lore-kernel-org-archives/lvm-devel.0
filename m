From: David Teigland <teigland@sourceware.org>
Date: Fri, 5 May 2017 11:49:43 -0400
Subject: master - man lvmetad: mention repair as a reason for disabling
Message-ID: <201705051549.v45FnhZG032142@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c5fee2ee6e483ee9e56d842f402d2de9dfe5151a
Commit:        c5fee2ee6e483ee9e56d842f402d2de9dfe5151a
Parent:        405a3689bcc40c8782685a739310e337a7c268a9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 5 10:48:58 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 5 10:48:58 2017 -0500

man lvmetad: mention repair as a reason for disabling

lvconvert --repair now also disables lvmetad.
---
 man/lvmetad.8_main |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/man/lvmetad.8_main b/man/lvmetad.8_main
index 31a89cc..ec55171 100644
--- a/man/lvmetad.8_main
+++ b/man/lvmetad.8_main
@@ -53,10 +53,13 @@ metadata.
 In some cases, lvmetad will be temporarily disabled while it continues
 running.  In this state, LVM commands will ignore the lvmetad cache and
 revert to scanning disks.  A warning will also be printed which includes
-the reason why lvmetad is not being used.  The most common reason is the
-existence of duplicate PVs (lvmetad cannot cache data for duplicate PVs.)
-Once duplicates have been resolved, the lvmetad cache is can be updated
-with pvscan --cache and commands will return to using the cache.
+the reason why lvmetad is not being used.  The most common reasons are the
+existence of duplicate PVs (lvmetad cannot cache data for duplicate PVs),
+or an 'lvconvert --repair' command has been run (the lvmetad cache may
+not be reliable while repairs are neeeded.)
+Once duplicates have been resolved, or repairs have been completed,
+the lvmetad cache is can be updated with pvscan --cache and commands
+will return to using the cache.
 
 Use of lvmetad is enabled/disabled by:
 .br


