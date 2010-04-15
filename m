From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 15 Apr 2010 11:40:03 +0200
Subject: [PATCH 1/3] Hotfix: $(datarootdir) has already $(DESTDIR)
In-Reply-To: <cover.1271324076.git.zkabelac@redhat.com>
References: <cover.1271324076.git.zkabelac@redhat.com>
Message-ID: <0af6c5acc6bb8d9fa61436ceffb7761edd146e17.1271324076.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

FIXME: We should use DESTDIR only for $(INSTALL) commands to allow
user-override of commonly known variables and still be able
to honor $(DESTDIR).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 make.tmpl.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 87e8505..a6b00fc 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -57,8 +57,8 @@ usrlibdir = $(DESTDIR)@usrlibdir@
 sbindir = $(DESTDIR)@sbindir@
 usrsbindir = $(DESTDIR)@usrsbindir@
 datarootdir = $(DESTDIR)@datarootdir@
-infodir = $(DESTDIR)@infodir@
-mandir = $(DESTDIR)@mandir@
+infodir = $(datarootdir)/info
+mandir = $(datarootdir)/man
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
-- 
1.7.0.1


