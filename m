From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:49 +0000 (GMT)
Subject: main - python: variable without destdir
Message-ID: <20220907130449.6D84C385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85b436642baa4b957f70cf7e94355ee328fc8c02
Commit:        85b436642baa4b957f70cf7e94355ee328fc8c02
Parent:        e757965222607a21a240139d1696780c389b798d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 6 16:09:39 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 14:58:01 2022 +0200

python: variable without destdir

PYTHON_PREFIX without $(DESTDIR)
---
 make.tmpl.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index cccda10d6..427fee596 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -128,7 +128,7 @@ systemd_generator_dir = $(DESTDIR)$(SYSTEMD_GENERATOR_DIR)
 systemd_dir = $(DESTDIR)@systemdutildir@
 tmpfiles_dir = $(DESTDIR)@tmpfilesdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
-PYTHON_PREFIX = $(DESTDIR)$(prefix)
+PYTHON_PREFIX = $(prefix)
 
 # N.B. No $(DESTDIR) prefix here.
 python2dir = @PYTHON2DIR@

