From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:57 +0000 (UTC)
Subject: master - test/lib/aux.sh: Remove '--udev' for lvmdbusd start
Message-ID: <20160829202857.8DFB8601E9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c386bf4d44121afdaebbbe03569155d1f5f7569
Commit:        7c386bf4d44121afdaebbbe03569155d1f5f7569
Parent:        70d4e2e8d50a1d095b2ba1a4286fdcaeb8aa321e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 14:28:12 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:56 2016 -0500

test/lib/aux.sh: Remove '--udev' for lvmdbusd start

The service will start up with udev monitoring and disable it if lvm
starts calling ExternalEvent.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 726cfe3..26b4ec1 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -337,7 +337,7 @@ prepare_lvmdbusd() {
 	fi
 
 	echo "preparing lvmdbusd..."
-	"$daemon" --debug --udev > debug.log_LVMDBUSD_out 2>&1 &
+	"$daemon" --debug  > debug.log_LVMDBUSD_out 2>&1 &
 	local pid=$!
 
 	sleep 1


