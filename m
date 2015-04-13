From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 13 Apr 2015 14:39:34 +0000 (UTC)
Subject: master - tests: log parallel debug.log usage as problem
Message-ID: <20150413143934.7FBFA60F0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0aef2b719f17bddfe8afeaa4d38447975c192f50
Commit:        0aef2b719f17bddfe8afeaa4d38447975c192f50
Parent:        0457224febdf1eb3ddc66369d39808a6f2d6ec26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 13 16:30:36 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 13 16:38:32 2015 +0200

tests: log parallel debug.log usage as problem

---
 test/lib/lvm-wrapper.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/lib/lvm-wrapper.sh b/test/lib/lvm-wrapper.sh
index cbc60d3..5840175 100644
--- a/test/lib/lvm-wrapper.sh
+++ b/test/lib/lvm-wrapper.sh
@@ -39,7 +39,10 @@ case "$CMD" in
 esac
 
 # Capture parallel users of debug.log file
-test -z "$(fuser debug.log 2>/dev/null)" || { echo "Test suite problem: \"debug.log\" is still in use!" >&2 ; return 1 ; }
+test -z "$(fuser debug.log 2>/dev/null)" || {
+	echo "TEST WARNING: \"debug.log\" is still in use while running $CMD $@" >&2
+	fuser -v debug.log >&2
+}
 
 # the exec is important, because otherwise fatal signals inside "not" go unnoticed
 if test -n "$abs_top_builddir"; then


