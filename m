From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 21:37:08 +0000 (GMT)
Subject: main - makefiles: use proper install prefix for python dbus
Message-ID: <20211014213708.8B7A43858419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=32cb1c4cdde64ea8f2e0a9ff77ae95e9821904de
Commit:        32cb1c4cdde64ea8f2e0a9ff77ae95e9821904de
Parent:        af0ce203e9f78e307bfb9524dc8377ebbc53e8f1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 21:39:14 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 14 23:34:11 2021 +0200

makefiles: use proper install prefix for python dbus

For non-standard prefix dir use correct installation path
(so the python files are not installed into user's system).
---
 make.tmpl.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 200ea2e05..1e6393a7b 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -121,7 +121,7 @@ systemd_generator_dir = $(DESTDIR)$(SYSTEMD_GENERATOR_DIR)
 systemd_dir = $(DESTDIR)@systemdutildir@
 tmpfiles_dir = $(DESTDIR)@tmpfilesdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
-pythonprefix = $(DESTDIR)$(prefix)
+PYTHON_PREFIX = $(DESTDIR)$(prefix)
 
 # N.B. No $(DESTDIR) prefix here.
 python2dir = @PYTHON2DIR@


