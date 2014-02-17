From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Feb 2014 21:26:40 +0000 (UTC)
Subject: master - tests: add short delay
Message-ID: <20140217212640.5468460C84@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8eedb18c73f81de8682649afd21c996883c33e76
Commit:        8eedb18c73f81de8682649afd21c996883c33e76
Parent:        9974136b907962438079e4c634541f97d1f9fd61
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 15 13:02:41 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 17 22:25:53 2014 +0100

tests: add short delay

Give some extra delay so the file will be opened.
---
 test/shell/snapshot-usage.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 9e6a14f..14a87c0 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -55,6 +55,9 @@ trap 'cleanup_tail' EXIT
 sleep 30 < $DM_DEV_DIR/$vg1/$lv1 &
 SLEEP_PID=$!
 
+# give some short time to lock file above
+sleep 0.1
+
 # Opened virtual snapshot device is not removable
 # it should retry device removal for a few seconds
 not lvremove -f $vg1/$lv1


