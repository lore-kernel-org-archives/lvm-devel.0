From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  3 Mar 2010 21:42:49 +0100
Subject: [PATCH 03/15] Fix autoconf WARNING:
In-Reply-To: <cover.1267648294.git.zkabelac@redhat.com>
References: <cover.1267648294.git.zkabelac@redhat.com>
Message-ID: <7ca649f258e39f8e4753f1f3f9b2a284932dd495.1267648294.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use datarootdir and fix warning during configure process:
config.status: WARNING:  'make.tmpl.in' seems to ignore the
--datarootdir setting

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 make.tmpl.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 1cba3f2..61365ec 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -47,6 +47,7 @@ libdir = $(DESTDIR)@libdir@
 usrlibdir = $(DESTDIR)@usrlibdir@
 sbindir = $(DESTDIR)@sbindir@
 usrsbindir = $(DESTDIR)@usrsbindir@
+datarootdir = $(DESTDIR)@datarootdir@
 infodir = $(DESTDIR)@infodir@
 mandir = $(DESTDIR)@mandir@
 localedir = $(DESTDIR)@LOCALEDIR@
-- 
1.7.0


