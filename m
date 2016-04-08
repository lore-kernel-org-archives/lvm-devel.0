From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Fri,  8 Apr 2016 14:26:54 +0000 (UTC)
Subject: master - test: Fix testing of installed lvmdbusd
Message-ID: <20160408142654.B1DAF60F42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6768997e192e26aaf091b6ed2700a3391f178b5
Commit:        e6768997e192e26aaf091b6ed2700a3391f178b5
Parent:        ed0c779bd120e7c36cb7f100df3c6edc98e8cc52
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Apr 1 09:28:31 2016 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Apr 8 16:26:25 2016 +0200

test: Fix testing of installed lvmdbusd

If lvmdbusd is missing expression triggers ERR trap instead of skipping
the test.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index c8985ed..3a44ae6 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -321,7 +321,7 @@ prepare_lvmdbusd() {
 		# Setup the python path so we can run
 		export PYTHONPATH=$abs_top_builddir/daemons
 	else
-		daemon="$(which lvmdbusd)"
+		daemon="$(which lvmdbusd || :)"
 	fi
 	[[ -n $daemon && -x $daemon ]] || skip "The daemon is missing"
 


