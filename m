From: David Teigland <teigland@sourceware.org>
Date: Tue, 2 Jan 2018 14:36:22 -0500
Subject: master - man lvmlockd: update wording
Message-ID: <201801021936.w02JaMwZ027703@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96801ac0859798c4e478d05e91aaa68b4ce10c91
Commit:        96801ac0859798c4e478d05e91aaa68b4ce10c91
Parent:        3db51e3f0e90e45e6c3734000fa5a5246a1e6c96
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 2 13:10:34 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 2 13:35:58 2018 -0600

man lvmlockd: update wording

---
 man/lvmlockd.8_main |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvmlockd.8_main b/man/lvmlockd.8_main
index fbcdc87..bb45871 100644
--- a/man/lvmlockd.8_main
+++ b/man/lvmlockd.8_main
@@ -15,7 +15,7 @@ coordinate reading and writing of LVM metadata
 validate caching of LVM metadata
 .br
 \[bu]
-prevent concurrent activation of logical volumes
+prevent conflicting activation of logical volumes
 .br
 
 lvmlockd uses an external lock manager to perform basic locking.


