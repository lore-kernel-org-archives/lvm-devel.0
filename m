From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Dec 2013 13:09:03 +0000 (UTC)
Subject: master - tests: hide expected error message
Message-ID: <20131217130903.BFD3A60FD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=904a02335ffe831dfedc32d074f5b659189aaa76
Commit:        904a02335ffe831dfedc32d074f5b659189aaa76
Parent:        fd73b2b7b92a2bb1d3ae3d6c4d2eb5eef78594c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 17 13:55:19 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 17 14:08:54 2013 +0100

tests: hide expected error message

Test typically enables disabled device - so it mostly expects
error target will be reloaded here - thus hide confusing message.
---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2256fce..92385c8 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -392,7 +392,7 @@ enable_dev() {
 	init_udev_transaction
 	for dev in "$@"; do
 		local name=$(echo "$dev" | sed -e 's,.*/,,')
-		dmsetup create -u "TEST-$name" "$name" "$name.table" || \
+		dmsetup create -u "TEST-$name" "$name" "$name.table" 2>/dev/null || \
 			dmsetup load "$name" "$name.table"
 		# using device name (since device path does not exists yes with udev)
 		dmsetup resume "$name"


