From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 25 Apr 2018 08:49:44 -0400
Subject: master - [git] Update .gitignore
Message-ID: <201804251249.w3PCnii2028222@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2504257e463bf58d991f8d137923a1a48bf4404
Commit:        f2504257e463bf58d991f8d137923a1a48bf4404
Parent:        d51429254f4e9b17083af0c554aa7045e5ec08bb
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Jan 29 09:40:21 2018 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 23 09:49:37 2018 +0100

[git] Update .gitignore

---
 .gitignore |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/.gitignore b/.gitignore
index a890cee..28846b1 100644
--- a/.gitignore
+++ b/.gitignore
@@ -1,6 +1,7 @@
 *.5
 *.7
 *.8
+*.8_gen
 *.a
 *.d
 *.o
@@ -30,3 +31,7 @@ make.tmpl
 /cscope.out
 /tags
 /tmp/
+
+
+tools/man-generator
+tools/man-generator.c


