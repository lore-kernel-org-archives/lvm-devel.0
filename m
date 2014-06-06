From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:14 +0000 (UTC)
Subject: dev-prajnoha-report-select - configure: do not exit with error code
Message-ID: <20140606120314.8254F60FA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=46b0cd10fe2405f281651fcfea5f536573fa7cbc
Commit:        46b0cd10fe2405f281651fcfea5f536573fa7cbc
Parent:        c4e0c6127247c421e40d9d387ba89d8cd9899f5f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 18:02:40 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 18:02:40 2014 +0200

configure: do not exit with error code

Since the test is the last command make a test in a form it will be
after its finished 0.
(regression from last configure cleanup)
---
 configure    |    2 +-
 configure.in |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index bedccca..034ee12 100755
--- a/configure
+++ b/configure
@@ -13453,5 +13453,5 @@ $as_echo "$as_me: WARNING: Support for thin provisioning is limited since some t
 test -n "$THIN_CHECK_VERSION_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&5
 $as_echo "$as_me: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&2;}
 
-test "$ODIRECT" != yes && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
+test "$ODIRECT" = yes || { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 $as_echo "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
diff --git a/configure.in b/configure.in
index a1dfee5..12404ba 100644
--- a/configure.in
+++ b/configure.in
@@ -1762,4 +1762,4 @@ test -n "$THIN_CONFIGURE_WARN" && AC_MSG_WARN([Support for thin provisioning is
 
 test -n "$THIN_CHECK_VERSION_WARN" && AC_MSG_WARN([You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning])
 
-test "$ODIRECT" != yes && AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])
+test "$ODIRECT" = yes || AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])


