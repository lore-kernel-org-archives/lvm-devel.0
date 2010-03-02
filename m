From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Mar 2010 13:07:20 +0100
Subject: [PATCH 2/9] Fix autoconf WARNING:
In-Reply-To: <cover.1267529065.git.zkabelac@redhat.com>
References: <cover.1267529065.git.zkabelac@redhat.com>
Message-ID: <acb712a8cadc19ced318461333ab50beab195ddb.1267529065.git.zkabelac@redhat.com>
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


