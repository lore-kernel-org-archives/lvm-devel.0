From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 11 Dec 2016 13:33:02 +0000 (UTC)
Subject: master - test: add results/ to .gitignore
Message-ID: <20161211133302.2F0EF60362@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9f9ce52ecb0de3b33b1d0e2294a1b13c744e655
Commit:        b9f9ce52ecb0de3b33b1d0e2294a1b13c744e655
Parent:        14c20ae217ecb42e77f1775ae9185a08e74ea2d3
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Dec 10 18:00:25 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Dec 10 18:00:25 2016 +0000

test: add results/ to .gitignore

---
 test/.gitignore |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/.gitignore b/test/.gitignore
index 2450c66..5b377c7 100644
--- a/test/.gitignore
+++ b/test/.gitignore
@@ -1,3 +1,4 @@
 .bin-dir-stamp
 bin
 init.sh
+results/


