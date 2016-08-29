From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 20:28:59 +0000 (UTC)
Subject: master - test/lib/aux.sh: Remove incorrect comment
Message-ID: <20160829202859.ACE4F60F09@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=756f51eac8f42c85f091ebbc4dc8bb2f1569a38e
Commit:        756f51eac8f42c85f091ebbc4dc8bb2f1569a38e
Parent:        7c386bf4d44121afdaebbbe03569155d1f5f7569
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 14:29:12 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 15:26:56 2016 -0500

test/lib/aux.sh: Remove incorrect comment

The dbus service needs to use the system bus.  The test environment does
not allow work with session bus environment.
---
 test/lib/aux.sh |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 26b4ec1..7dffdcb 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -329,7 +329,6 @@ prepare_lvmdbusd() {
 	which python3 >/dev/null || skip "Missing python3"
 	python3 -c "import pyudev, dbus, gi.repository" || skip "Missing python modules"
 
-        # TODO: Tests should use session bus instead of system bus
 	# Copy the needed file to run on the system bus if it doesn't
 	# already exist
 	if [ ! -f /etc/dbus-1/system.d/com.redhat.lvmdbus1.conf ]; then


