From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Nov 2019 09:32:57 -0500
Subject: stable-2.02 - build: autoconf
Message-ID: <40294.119112009325300773@us-mta-346.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9e45ad04b035468bc4ed7a68e654bfa5641f6b2c
Commit:        9e45ad04b035468bc4ed7a68e654bfa5641f6b2c
Parent:        245d7fcd590583166f6cdd78a81bac903fea92eb
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 23 09:22:42 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Nov 20 15:27:42 2019 +0100

build: autoconf

---
 configure |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 4d2fb2f..fe0e8e2 100755
--- a/configure
+++ b/configure
@@ -12688,7 +12688,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	for am_cv_pathless_PYTHON in python python2 python3 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros
@@ -13256,7 +13256,7 @@ if ${am_cv_pathless_PYTHON+:} false; then :
   $as_echo_n "(cached) " >&6
 else
 
-	for am_cv_pathless_PYTHON in python python2 python3 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
+	for am_cv_pathless_PYTHON in python python2 python3 python3.5 python3.4 python3.3 python3.2 python3.1 python3.0 python2.7  python2.6 python2.5 python2.4 python2.3 python2.2 python2.1 python2.0 none; do
 	  test "$am_cv_pathless_PYTHON" = none && break
 	  prog="import sys
 # split strings by '.' and convert to numeric.  Append some zeros



