From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 08:15:55 -0500
Subject: master - man: add man-generator and build artefacts to .gitignore
Message-ID: <201703101315.v2ADFtQg029075@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=59e57be54f9b4c9e83ec1ede480285965a7411eb
Commit:        59e57be54f9b4c9e83ec1ede480285965a7411eb
Parent:        1f7ac54bc4434922327b92c92aeb3498fb204479
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 13:14:02 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 13:14:02 2017 +0000

man: add man-generator and build artefacts to .gitignore

---
 man/.gitignore |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/man/.gitignore b/man/.gitignore
new file mode 100644
index 0000000..4165b16
--- /dev/null
+++ b/man/.gitignore
@@ -0,0 +1,2 @@
+*.gen
+man-generator


