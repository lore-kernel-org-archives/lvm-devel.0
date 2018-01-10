From: David Teigland <teigland@sourceware.org>
Date: Wed, 10 Jan 2018 10:19:03 -0500
Subject: master - man lvmlockd: remove lv resizing comment
Message-ID: <201801101519.w0AFJ3f9030923@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=943b21779770f1cd93e73925e62f108e2efbd6cc
Commit:        943b21779770f1cd93e73925e62f108e2efbd6cc
Parent:        51340888aab5e1b8630c7d8083e621ca0f4e4264
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jan 10 09:15:52 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jan 10 09:17:57 2018 -0600

man lvmlockd: remove lv resizing comment

---
 man/lvmlockd.8_main |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index bb45871..6f982bd 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -862,9 +862,6 @@ vgsplit
 .br
 \[bu]
 vgmerge
-.br
-\[bu]
-resizing an LV that is active in the shared mode on multiple hosts
 
 
 .SS lvmlockd changes from clvmd


