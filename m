From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Mar 2015 23:16:38 +0000 (UTC)
Subject: master - tests: few more warnings for gcc only
Message-ID: <20150311231638.B127260D1B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c6d96efc38b2d1af9e81d96f27f17eea90fe7623
Commit:        c6d96efc38b2d1af9e81d96f27f17eea90fe7623
Parent:        eded54df7ba781afa9da14dd1a79b132aba255eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 12 00:12:15 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 12 00:12:15 2015 +0100

tests: few more warnings for gcc only

g++ doesn't like them.
---
 make.tmpl.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 3a8597a..322e33b 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -148,7 +148,6 @@ WFLAGS +=\
  -Wfloat-equal\
  -Wformat-security\
  -Winline\
- -Wmissing-declarations\
  -Wmissing-format-attribute\
  -Wmissing-include-dirs\
  -Wmissing-noreturn\
@@ -156,14 +155,15 @@ WFLAGS +=\
  -Wredundant-decls\
  -Wshadow\
  -Wundef\
- -Wuninitialized\
  -Wwrite-strings
 
 WCFLAGS +=\
+ -Wmissing-declarations\
  -Wmissing-prototypes\
  -Wnested-externs\
  -Wold-style-definition\
- -Wstrict-prototypes
+ -Wstrict-prototypes\
+ -Wuninitialized
 
 ifeq ("@HAVE_WJUMP@", "yes")
 WCFLAGS += -Wjump-misses-init


