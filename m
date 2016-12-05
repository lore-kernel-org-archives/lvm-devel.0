From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:34 +0000 (UTC)
Subject: master - tests: apostrof
Message-ID: <20161205161534.C6A8B60528@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f6ade4b0d5901bb01bcbdfdb926823415a01703
Commit:        3f6ade4b0d5901bb01bcbdfdb926823415a01703
Parent:        022d3af06853ba4e627e098ac04ef1a8f9806edc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 28 17:36:43 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:12:42 2016 +0100

tests: apostrof

---
 test/lib/aux.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index e4c3780..7f3c84a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -322,9 +322,9 @@ prepare_lvmdbusd() {
 		# Setup the python path so we can run
 		export PYTHONPATH=$abs_top_builddir/daemons
 	else
-		daemon="$(which lvmdbusd || :)"
+		daemon=$(which lvmdbusd || :)
 	fi
-	[[ -n $daemon && -x $daemon ]] || skip "The daemon is missing"
+	[[ -n "$daemon" && -x "$daemon" ]] || skip "The daemon is missing"
 	which python3 >/dev/null || skip "Missing python3"
 
 	python3 -c "import pyudev, dbus, gi.repository" || skip "Missing python modules"


