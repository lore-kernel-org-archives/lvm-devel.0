From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:35 +0000 (UTC)
Subject: master - makefiles: avoid // in datadir usage
Message-ID: <20150422092035.00A5460E46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f8d942268161abcb56700c027f82a87f20f0abf
Commit:        7f8d942268161abcb56700c027f82a87f20f0abf
Parent:        d8874556cde1e0be4ee1d9cf40835d8ee7fe89f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 22 10:59:03 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 10:59:03 2015 +0200

makefiles: avoid // in datadir usage

DESTDIR already comes with '/'
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index ed6b522..5b98ae1 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -79,7 +79,7 @@ usrlibdir = $(DESTDIR)@usrlibdir@
 sbindir = $(DESTDIR)@sbindir@
 usrsbindir = $(DESTDIR)@usrsbindir@
 datarootdir = @datarootdir@
-datadir = $(DESTDIR)/@datadir@
+datadir = $(DESTDIR)@datadir@
 infodir = $(DESTDIR)@infodir@
 mandir = $(DESTDIR)@mandir@
 localedir = $(DESTDIR)@LOCALEDIR@


