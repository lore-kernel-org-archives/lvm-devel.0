From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 4 Jun 2018 07:00:46 -0400
Subject: master - build: Get python dir building without the include/ dir
Message-ID: <201806041100.w54B0ktD004537@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=891f8dc19d7b9c5a72971200fad2b29b13e43bfa
Commit:        891f8dc19d7b9c5a72971200fad2b29b13e43bfa
Parent:        21a5be2364574de43e2afe55a250ccced02df008
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Jun 4 11:59:13 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Jun 4 11:59:13 2018 +0100

build: Get python dir building without the include/ dir

---
 python/setup.py.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/python/setup.py.in b/python/setup.py.in
index d09b791..c39e4fc 100644
--- a/python/setup.py.in
+++ b/python/setup.py.in
@@ -22,7 +22,7 @@ liblvm = Extension('lvm',
                     sources = ['liblvm_python.c'],
                     libraries= ['lvm2app', 'devmapper'],
                     library_dirs= ['@top_builddir@/liblvm', '@top_builddir@/libdm'],
-                    include_dirs= ['@top_builddir@/include'])
+                    include_dirs= ['@top_builddir@'])
 
 setup (name='lvm',
        version=@LVM_VERSION@,


