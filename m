From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:43:53 -0400
Subject: master - man: Include '_vdata' as reserved name
Message-ID: <201910301543.x9UFhrlJ016591@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=75628a5f4c10c35f37f0a0c68f44e705eb9d1eef
Commit:        75628a5f4c10c35f37f0a0c68f44e705eb9d1eef
Parent:        bafe5d15b1e3c1e31b9c4c32cd875dc5dfe2a2fb
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 3 12:30:18 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

man: Include '_vdata' as reserved name

---
 man/lvm.8_main |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvm.8_main b/man/lvm.8_main
index 3e67b1b..9816f5f 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -274,7 +274,7 @@ not be used as LV or VG names. A VG cannot be called anything that exists in
 An LV cannot be called '.', '..', 'snapshot' or 'pvmove'.
 The LV name may also not contain any of the following strings:
 \fR'_cdata', '_cmeta', '_corig', '_mlog', '_mimage', '_pmspare',
-\fR'_rimage', '_rmeta', '_tdata', '_tmeta' or '_vorigin'.
+\fR'_rimage', '_rmeta', '_tdata', '_tmeta', '_vorigin' or '_vdata'.
 A directory bearing the name of each Volume Group is created under
 \fI/dev\fP when any of its Logical Volumes are activated.
 Each active Logical Volume is accessible from this directory as a symbolic


