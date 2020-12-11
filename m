From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 11 Dec 2020 11:16:39 +0000 (GMT)
Subject: main - configure: update
Message-ID: <20201211111639.8A0AE384400F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23ef67776210ad6c55f4dd7475b806337140c513
Commit:        23ef67776210ad6c55f4dd7475b806337140c513
Parent:        5dbe2fdd9dd783c2911a5375d6fdec86118af280
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Dec 11 12:16:16 2020 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Dec 11 12:16:16 2020 +0100

configure: update

---
 aclocal.m4 | 10 ++++++----
 configure  |  2 +-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/aclocal.m4 b/aclocal.m4
index 3e0fbd38d..7524c8313 100644
--- a/aclocal.m4
+++ b/aclocal.m4
@@ -496,12 +496,14 @@ AC_DEFUN([AM_PATH_PYTHON],
     m4_default([$3], [AC_MSG_ERROR([no suitable Python interpreter found])])
   else
 
-  dnl Query Python for its version number.  Getting [:3] seems to be
-  dnl the best way to do this; it's what "site.py" does in the standard
-  dnl library.
+  dnl Query Python for its version number.  Although site.py simply uses
+  dnl sys.version[:3], printing that failed with Python 3.10, since the
+  dnl trailing zero was eliminated. So now we output just the major
+  dnl and minor version numbers, as numbers. Apparently the tertiary
+  dnl version is not of interest.
 
   AC_CACHE_CHECK([for $am_display_PYTHON version], [am_cv_python_version],
-    [am_cv_python_version=`$PYTHON -c "import sys; sys.stdout.write(sys.version[[:3]])"`])
+    [am_cv_python_version=`$PYTHON -c "import sys; print('%u.%u' % sys.version_info[[:2]])"`])
   AC_SUBST([PYTHON_VERSION], [$am_cv_python_version])
 
   dnl Use the values of $prefix and $exec_prefix for the corresponding
diff --git a/configure b/configure
index 29d19f249..4c38cbebb 100755
--- a/configure
+++ b/configure
@@ -11962,7 +11962,7 @@ $as_echo_n "checking for $am_display_PYTHON version... " >&6; }
 if ${am_cv_python_version+:} false; then :
   $as_echo_n "(cached) " >&6
 else
-  am_cv_python_version=`$PYTHON -c "import sys; sys.stdout.write(sys.version[:3])"`
+  am_cv_python_version=`$PYTHON -c "import sys; print('%u.%u' % sys.version_info[:2])"`
 fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $am_cv_python_version" >&5
 $as_echo "$am_cv_python_version" >&6; }


