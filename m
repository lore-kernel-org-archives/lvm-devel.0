From: Till Maas <opensource@till.name>
Date: Thu, 15 Sep 2016 21:13:10 +0200
Subject: [PATCH] Fix sources filename in setup.py
Message-ID: <20160915191310.GM316@genius.invalid>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Till Maas <opensource@till.name>
---
 python/setup.py.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/python/setup.py.in b/python/setup.py.in
index 6a44482..46c650a 100644
--- a/python/setup.py.in
+++ b/python/setup.py.in
@@ -19,7 +19,7 @@
 from distutils.core import setup, Extension
 
 liblvm = Extension('lvm',
-                    sources = ['liblvm_python.c'],
+                    sources = ['liblvm.c'],
                     libraries= ['lvm2app'],
                     library_dirs= ['@top_builddir@/liblvm'],
                     include_dirs= ['@top_builddir@/include'])
-- 
2.7.4


