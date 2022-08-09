From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue,  9 Aug 2022 14:18:03 +0000 (GMT)
Subject: main - configure: fix typo
Message-ID: <20220809141803.53753385AC2F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=31f9c4bfab4d859369b0a5365fda44e398a4656b
Commit:        31f9c4bfab4d859369b0a5365fda44e398a4656b
Parent:        9cdd258646d5d9da534568a61133e76f3d5548d7
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Aug 9 16:01:34 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Aug 9 16:17:40 2022 +0200

configure: fix typo

---
 configure.ac | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 6cdf1a7e6..ba02f1f9b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -293,7 +293,7 @@ case "$DEFAULT_USE_DEVICES_FILE" in
 esac
 AC_MSG_RESULT($DEFAULT_USE_DEVICES_FILE)
 AC_DEFINE_UNQUOTED(DEFAULT_USE_DEVICES_FILE, [$DEFAULT_USE_DEVICES_FILE],
-		   [Default for lvm.conf use_devicefile.])
+		   [Default for lvm.conf use_devicesfile.])
 
 AC_MSG_CHECKING(default name mangling)
 AC_ARG_WITH(default-name-mangling,

