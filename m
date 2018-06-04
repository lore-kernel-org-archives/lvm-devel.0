From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 4 Jun 2018 07:28:59 -0400
Subject: master - build: More tweaks to python include dirs.
Message-ID: <201806041128.w54BSxhR008267@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=66b10275c5ce7328cd5fb0f00a52de6c76e45481
Commit:        66b10275c5ce7328cd5fb0f00a52de6c76e45481
Parent:        f6eeb218b20685b1bf0f76b24c5697901896bdec
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Jun 4 12:28:17 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Jun 4 12:28:17 2018 +0100

build: More tweaks to python include dirs.

---
 python/setup.py.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/python/setup.py.in b/python/setup.py.in
index c39e4fc..07b79df 100644
--- a/python/setup.py.in
+++ b/python/setup.py.in
@@ -22,7 +22,7 @@ liblvm = Extension('lvm',
                     sources = ['liblvm_python.c'],
                     libraries= ['lvm2app', 'devmapper'],
                     library_dirs= ['@top_builddir@/liblvm', '@top_builddir@/libdm'],
-                    include_dirs= ['@top_builddir@'])
+                    include_dirs= ['@top_builddir@/include', '@top_srcdir@'])
 
 setup (name='lvm',
        version=@LVM_VERSION@,


