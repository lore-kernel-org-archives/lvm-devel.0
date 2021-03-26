From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 26 Mar 2021 12:18:02 +0000 (GMT)
Subject: main - tests: add basic validation of running services
Message-ID: <20210326121802.317523858024@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85fae836c09daf457f3f8f14e3eae2179cfd2ffa
Commit:        85fae836c09daf457f3f8f14e3eae2179cfd2ffa
Parent:        9bcc76b63c14566e5ced09ac18129e1c9a98e8e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 26 11:13:56 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 26 11:13:56 2021 +0100

tests: add basic validation of running services

For determinist test results lvm2/dm service shall not be present
and running in the system as it may randomize test results.

In case they are found present, this test ends with warning (not failure).
---
 test/shell/000-basic.sh | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/test/shell/000-basic.sh b/test/shell/000-basic.sh
index 1e511d1f0..a7b80c72b 100644
--- a/test/shell/000-basic.sh
+++ b/test/shell/000-basic.sh
@@ -34,3 +34,15 @@ get_devs
 # ensure we do not crash on a bug in config file
 aux lvmconf 'log/prefix = 1""'
 not lvs "${DEVICES[@]}"
+
+# validate testing machine with its services is in expected state and will not interfere with tests
+if systemctl -a >out 2>/dev/null ; then
+	for i in dm-event lvm2-lvmpolld lvm2-monitor ; do
+	echo $i
+		grep $i out | not grep -v masked || {
+			cat out
+			should not echo "Present unmasked $i service/socket may randomize testing results!"
+			echo "+++++ Stop & Mask with systemctl +++++"
+		}
+	done
+fi


