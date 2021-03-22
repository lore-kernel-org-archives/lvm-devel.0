From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:51 +0000 (GMT)
Subject: dev-next - lvm: Fix editline compilation
Message-ID: <20210322153951.DE6D93854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b6cff47bdeef4906d675dad71277a706db0b9127
Commit:        b6cff47bdeef4906d675dad71277a706db0b9127
Parent:        d6bc11bf724be4ebfd87dc60a172da2b0e4df8d9
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Mar 22 10:50:42 2021 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Mar 22 11:37:19 2021 +0100

lvm: Fix editline compilation

---
 configure    | 2 +-
 configure.ac | 4 ++--
 tools/lvm.c  | 1 -
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/configure b/configure
index 4c38cbebb..0be9f136c 100755
--- a/configure
+++ b/configure
@@ -13404,7 +13404,7 @@ $as_echo_n "checking whether to enable readline... " >&6; }
 $as_echo "$READLINE" >&6; }
 
 if test "$EDITLINE" = yes; then
-	for ac_header in editline/readline.h editline/history.h
+	for ac_header in editline/readline.h
 do :
   as_ac_Header=`$as_echo "ac_cv_header_$ac_header" | $as_tr_sh`
 ac_fn_c_check_header_mongrel "$LINENO" "$ac_header" "$as_ac_Header" "$ac_includes_default"
diff --git a/configure.ac b/configure.ac
index ee21b879d..b92be0db3 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1420,7 +1420,7 @@ if test "$EDITLINE" == yes; then
 	PKG_CHECK_MODULES([EDITLINE], [libedit], [
 		AC_DEFINE([EDITLINE_SUPPORT], 1,
 			[Define to 1 to include the LVM editline shell.])], AC_MSG_ERROR(
-[libedit could not be found which is required for the --enable-readline option.])
+[libedit could not be found which is required for the --enable-editline option.])
 	)
 fi
 
@@ -1557,7 +1557,7 @@ AC_MSG_CHECKING(whether to enable readline)
 AC_MSG_RESULT($READLINE)
 
 if test "$EDITLINE" = yes; then
-	AC_CHECK_HEADERS(editline/readline.h editline/history.h,,hard_bailout)
+	AC_CHECK_HEADERS(editline/readline.h,,hard_bailout)
 fi
 AC_MSG_CHECKING(whether to enable editline)
 AC_MSG_RESULT($EDITLINE)
diff --git a/tools/lvm.c b/tools/lvm.c
index 79b1210af..cc67e924a 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -33,7 +33,6 @@ int main(int argc, char **argv)
 #    endif
 #  elif defined(EDITLINE_SUPPORT)
 #    include <editline/readline.h>
-#    include <editline/history.h>
 #  endif
 
 static struct cmdline_context *_cmdline;


