From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 16:05:29 -0400
Subject: master - python: specify libdm path for linking
Message-ID: <201805152005.w4FK5TdE001476@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f8745dc23e8c3e0b2850a0982d251f112d653179
Commit:        f8745dc23e8c3e0b2850a0982d251f112d653179
Parent:        550380c1a48697d6c5bc63b4d63c4b1d772dd14a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 21:54:58 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 22:02:41 2018 +0200

python: specify libdm path for linking

---
 python/setup.py.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/python/setup.py.in b/python/setup.py.in
index dac999a..d09b791 100644
--- a/python/setup.py.in
+++ b/python/setup.py.in
@@ -21,7 +21,7 @@ from distutils.core import setup, Extension
 liblvm = Extension('lvm',
                     sources = ['liblvm_python.c'],
                     libraries= ['lvm2app', 'devmapper'],
-                    library_dirs= ['@top_builddir@/liblvm'],
+                    library_dirs= ['@top_builddir@/liblvm', '@top_builddir@/libdm'],
                     include_dirs= ['@top_builddir@/include'])
 
 setup (name='lvm',


