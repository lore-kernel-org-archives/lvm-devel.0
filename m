From: David Teigland <teigland@sourceware.org>
Date: Thu, 7 Jun 2018 14:44:20 -0400
Subject: master - man lvmlockd: remove unnecessary reference to lvmetad
Message-ID: <201806071844.w57IiK8Q010963@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c7c7017f0c12ebab4e1aef9d9a9fabd4ec2adfe3
Commit:        c7c7017f0c12ebab4e1aef9d9a9fabd4ec2adfe3
Parent:        60db97ae1d934e0475ec8c5752237ae5965a62d4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 7 13:42:11 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 7 13:44:05 2018 -0500

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
 


