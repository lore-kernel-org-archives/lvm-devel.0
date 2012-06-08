From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  8 Jun 2012 22:36:28 +0000 (UTC)
Subject: master - gitignore: Remove redundant test dir entry
Message-ID: <20120608223628.D8971402C@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd5b2974c09a6650211b6f02f0e86ec63d6413d4
Commit:        dd5b2974c09a6650211b6f02f0e86ec63d6413d4
Parent:        f3c20bf7e6e036b8714ddd9ae456046948ca130a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 8 23:34:15 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 8 23:34:15 2012 +0100

gitignore: Remove redundant test dir entry

---
 test/.gitignore |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/.gitignore b/test/.gitignore
index 2351bfc..2450c66 100644
--- a/test/.gitignore
+++ b/test/.gitignore
@@ -1,4 +1,3 @@
 .bin-dir-stamp
-Makefile
 bin
 init.sh


