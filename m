From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:44 +0000 (UTC)
Subject: master - tests: disable usage of fuser
Message-ID: <20150501130844.5FB2260FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fee09f0964bd64dee982eb615a6853e770ad0a4d
Commit:        fee09f0964bd64dee982eb615a6853e770ad0a4d
Parent:        4ce5b5fdf3e2758adf7e1313c98381071de85056
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 1 13:26:07 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:59 2015 +0200

tests: disable usage of fuser

Seems we captured problems with debug.log overwrite,
so avoid quite expensive usage of fuser tool with each lvm command.
---
 test/lib/lvm-wrapper.sh |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index 5840175..178c45b 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -39,10 +39,10 @@ case "$CMD" in
 esac
 
 # Capture parallel users of debug.log file
-test -z "$(fuser debug.log 2>/dev/null)" || {
-	echo "TEST WARNING: \"debug.log\" is still in use while running $CMD $@" >&2
-	fuser -v debug.log >&2
-}
+#test -z "$(fuser debug.log 2>/dev/null)" || {
+#	echo "TEST WARNING: \"debug.log\" is still in use while running $CMD $@" >&2
+#	fuser -v debug.log >&2
+#}
 
 # the exec is important, because otherwise fatal signals inside "not" go unnoticed
 if test -n "$abs_top_builddir"; then


