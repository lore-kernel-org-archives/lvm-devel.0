From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed, 14 Aug 2013 14:04:28 +0000 (UTC)
Subject: master - test: Fix false positives due to open devices
Message-ID: <20130814140428.E512C60B37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=732e609fe2e337fa7f4c2b3308d0bc6187269947
Commit:        732e609fe2e337fa7f4c2b3308d0bc6187269947
Parent:        82d83a01ce2cac77fec2e9b763061fbfb5f01ce8
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Aug 14 15:57:52 2013 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Aug 14 16:04:01 2013 +0200

test: Fix false positives due to open devices

Something is rather randomly keeping devices open. As it is a known udev
feature, waiting for transaction may (or may not) help.
---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d61f17d..36de6e5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -345,6 +345,7 @@ prepare_devs() {
 disable_dev() {
 	local dev
 
+	udev_wait
 	init_udev_transaction
 	for dev in "$@"; do
 		maj=$(($(stat --printf=0x%t "$dev")))


