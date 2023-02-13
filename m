From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:39 +0000 (GMT)
Subject: main - acinclude.m4: add local copy of PKG_CHECK_VAR
Message-ID: <20230213133139.7FB383858436@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f2864b5b1b1174846c3131f6c3962bd3806da72
Commit:        7f2864b5b1b1174846c3131f6c3962bd3806da72
Parent:        8630a19d1e37e2f7e532c75ec26b7d1b071f1f8d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 11 00:26:08 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 14:30:46 2023 +0100

acinclude.m4: add local copy of PKG_CHECK_VAR

Just in case an old distro tries to autoreconf and doesn't
come with newer pkg_ macros.
---
 acinclude.m4 | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/acinclude.m4 b/acinclude.m4
index 4ac611dd2..47fdd59c3 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -62,6 +62,24 @@ AC_DEFUN([AC_TRY_LDFLAGS],
     fi
 ])
 
+
+dnl PKG_CHECK_VAR(VARIABLE, MODULE, CONFIG-VARIABLE,
+dnl [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
+dnl -------------------------------------------
+dnl Since: 0.28
+dnl
+dnl Retrieves the value of the pkg-config variable for the given module.
+AC_DEFUN([PKG_CHECK_VAR],
+[AC_REQUIRE([PKG_PROG_PKG_CONFIG])dnl
+AC_ARG_VAR([$1], [value of $3 for $2, overriding pkg-config])dnl
+
+_PKG_CONFIG([$1], [variable="][$3]["], [$2])
+AS_VAR_COPY([$1], [pkg_cv_][$1])
+
+AS_VAR_IF([$1], [""], [$5], [$4])dnl
+])dnl PKG_CHECK_VAR
+
+
 # ===========================================================================
 #      http://www.gnu.org/software/autoconf-archive/ax_gcc_builtin.html
 # ===========================================================================

