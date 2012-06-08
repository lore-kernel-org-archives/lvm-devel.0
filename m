From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  8 Jun 2012 20:53:49 +0000 (UTC)
Subject: master - gitignore: add .swp
Message-ID: <20120608205349.577FD2262@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e892557ac646f042b491cd27d1d9d39002ad7ee7
Commit:        e892557ac646f042b491cd27d1d9d39002ad7ee7
Parent:        9f01f1453cef74b4198c1ef1ada3625f49c444a9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 8 21:53:07 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 8 21:53:07 2012 +0100

gitignore: add .swp

---
 .gitignore |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index 806dd3f..aa545b3 100644
--- a/.gitignore
+++ b/.gitignore
@@ -7,6 +7,7 @@
 *.pot
 *.so
 *.so.*
+*.swp
 
 .export.sym
 .exported_symbols_generated


