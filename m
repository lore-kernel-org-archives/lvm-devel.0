From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Nov 2016 16:00:08 +0000 (UTC)
Subject: master - tests: do not set zero interval in aux lvm.conf
Message-ID: <20161111160008.DDB3B601A6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b38564b8dc8a1e26f1937158dc7fc2d7c0b0804c
Commit:        b38564b8dc8a1e26f1937158dc7fc2d7c0b0804c
Parent:        de3d054f7803bad12e395cb0bd099c0c9c396668
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 11 15:57:00 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 11 16:58:20 2016 +0100

tests: do not set zero interval in aux lvm.conf

0 interval leads as of now to a busy loop with lvmetad and command.

Avoid testing this patological case.

TODO: Code should possibly translate zero interval into some small
sleep. With lvmpolld it's already 1/10s
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7187975..e4c3780 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1063,7 +1063,7 @@ generate_config() {
             cat > "$config_values" <<-EOF
 activation/checks = 1
 activation/monitoring = 0
-activation/polling_interval = 0
+activation/polling_interval = 1
 activation/retry_deactivation = 1
 activation/snapshot_autoextend_percent = 50
 activation/snapshot_autoextend_threshold = 50


