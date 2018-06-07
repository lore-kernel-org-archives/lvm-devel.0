From: David Teigland <teigland@sourceware.org>
Date: Thu, 7 Jun 2018 14:43:12 -0400
Subject: 2018-06-01-stable - man lvmlockd: remove unnecessary reference to lvmetad
Message-ID: <201806071843.w57IhC3R010914@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=98eb9e57544df1cbdf27f3186f425299d6a71097
Commit:        98eb9e57544df1cbdf27f3186f425299d6a71097
Parent:        347c807f86a61563e2a39c4b950ad124f9e30d66
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 7 13:42:11 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 7 13:42:11 2018 -0500

man lvmlockd: remove unnecessary reference to lvmetad

it's optional to use it with lvmlockd
---
 man/lvmlockd.8_main |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index 9fe569d..cf4c52e 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -173,9 +173,6 @@ steps.  They can be performed manually or using the system service
 manager.
 
 \[bu]
-start lvmetad
-.br
-\[bu]
 start lvmlockd
 .br
 \[bu]
@@ -202,9 +199,6 @@ stop lock manager
 \[bu]
 stop lvmlockd
 .br
-\[bu]
-stop lvmetad
-.br
 
 .P
 


