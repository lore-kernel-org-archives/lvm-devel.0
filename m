From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 15 Oct 2020 09:17:18 +0000 (GMT)
Subject: master - gitignore: ignore gcov files
Message-ID: <20201015091718.553EE3857C68@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=616e5b854c23a781372b2d05564959b4ba593069
Commit:        616e5b854c23a781372b2d05564959b4ba593069
Parent:        53db14171c6b516058486b2a80eaa17af32a246b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Oct 15 11:13:13 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Oct 15 11:13:13 2020 +0200

gitignore: ignore gcov files

---
 .gitignore | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/.gitignore b/.gitignore
index cfd5bee1c..97a2a9b4b 100644
--- a/.gitignore
+++ b/.gitignore
@@ -38,6 +38,10 @@ make.tmpl
 
 coverity/coverity_model.xml
 
+# gcov files:
+*.gcda
+*.gcno
+
 tools/man-generator
 tools/man-generator.c
 


