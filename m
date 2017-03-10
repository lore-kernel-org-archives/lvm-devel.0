From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 08:15:55 -0500
Subject: master - tools: add generated headers to .gitignore
Message-ID: <201703101315.v2ADFtmp008083@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f7ac54bc4434922327b92c92aeb3498fb204479
Commit:        1f7ac54bc4434922327b92c92aeb3498fb204479
Parent:        6a0f597727d2b52aa9bf607544087ce97a81dee2
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 13:13:41 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 13:13:41 2017 +0000

tools: add generated headers to .gitignore

---
 tools/.gitignore |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/.gitignore b/tools/.gitignore
index 2e7b332..ec529c3 100644
--- a/tools/.gitignore
+++ b/tools/.gitignore
@@ -2,3 +2,6 @@
 dmsetup
 dmstats
 lvm
+cmds.h
+command-count.h
+command-lines-input.h


