From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu,  5 Feb 2015 13:40:39 +0000 (UTC)
Subject: master - configure: Add libexecdir/datadir to make.tmpl.in.
Message-ID: <20150205134039.53872602BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d6a92b4d08827c2d3e6c7f57570830ef0b44e8d
Commit:        9d6a92b4d08827c2d3e6c7f57570830ef0b44e8d
Parent:        bf1f22cc997d3883f5ce481fb1ad1c6487fff9b7
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Jun 27 01:24:16 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Feb 5 13:47:16 2015 +0100

configure: Add libexecdir/datadir to make.tmpl.in.

---
 make.tmpl.in |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 2a2107f..3a82731 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -73,10 +73,12 @@ bindir = $(DESTDIR)@bindir@
 confdir = $(DESTDIR)@CONFDIR@/lvm
 includedir = $(DESTDIR)@includedir@
 libdir = $(DESTDIR)@libdir@
+libexecdir = $(DESTDIR)@libexecdir@
 usrlibdir = $(DESTDIR)@usrlibdir@
 sbindir = $(DESTDIR)@sbindir@
 usrsbindir = $(DESTDIR)@usrsbindir@
 datarootdir = @datarootdir@
+datadir = $(DESTDIR)/@datadir@
 infodir = $(DESTDIR)@infodir@
 mandir = $(DESTDIR)@mandir@
 localedir = $(DESTDIR)@LOCALEDIR@


