From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Feb 2018 05:01:47 -0500
Subject: master - python: add devmapper library to linking
Message-ID: <201802091001.w19A1lpd011135@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=34a9e3d3cdde5771e30fbd686b20ffba1647a497
Commit:        34a9e3d3cdde5771e30fbd686b20ffba1647a497
Parent:        7cfe5ab9bc279bb1cea42862a53d83556fb3ed52
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 9 10:21:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 9 11:00:18 2018 +0100

python: add devmapper library to linking

On occasional gcc releases it's better to specify also -ldevmapper
to linking logic for python object.

It's in fact more correct since the liblvm.c code is using
libdevmapper functions - that were linked in only via
liblvm2app library.
---
 python/setup.py.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/python/setup.py.in b/python/setup.py.in
index 6a44482..dac999a 100644
--- a/python/setup.py.in
+++ b/python/setup.py.in
@@ -1,5 +1,5 @@
 #
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2018 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -20,7 +20,7 @@ from distutils.core import setup, Extension
 
 liblvm = Extension('lvm',
                     sources = ['liblvm_python.c'],
-                    libraries= ['lvm2app'],
+                    libraries= ['lvm2app', 'devmapper'],
                     library_dirs= ['@top_builddir@/liblvm'],
                     include_dirs= ['@top_builddir@/include'])
 


