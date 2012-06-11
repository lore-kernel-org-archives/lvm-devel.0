From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 11 Jun 2012 15:17:36 +0000 (UTC)
Subject: master - gitignore: Ignore files ending in ~
Message-ID: <20120611151736.4DECD524C@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2955f13ecc5cd654b7b332e7d8e03c481ec67ea5
Commit:        2955f13ecc5cd654b7b332e7d8e03c481ec67ea5
Parent:        05fb5158635ef47f5c9083f2f4cc1871d0de1d0a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jun 11 16:13:02 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jun 11 16:13:02 2012 +0100

gitignore: Ignore files ending in ~

---
 .gitignore |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index aa545b3..52663d4 100644
--- a/.gitignore
+++ b/.gitignore
@@ -8,6 +8,7 @@
 *.so
 *.so.*
 *.swp
+*~
 
 .export.sym
 .exported_symbols_generated


