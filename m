From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 21 Feb 2017 08:44:00 +0000 (UTC)
Subject: master - tests: some debug code
Message-ID: <20170221084400.2653D60D3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1c1ce2739ed40d02ae2d41cb9e9de54d0948967c
Commit:        1c1ce2739ed40d02ae2d41cb9e9de54d0948967c
Parent:        2a65e2d49e9056bfe291f291c70f1ba9ec72e2e7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 21 09:40:21 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 21 09:40:21 2017 +0100

tests: some debug code

Checking if --deferred would make it any faster - but it's as slow
as without this new optional flag anyway (4.10).
---
 test/lib/aux.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 10f6f92..5108a52 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -406,8 +406,11 @@ teardown_devs_prefixed() {
 
 	# Remove devices, start with closed (sorted by open count)
 	# Run 'dmsetup remove' in parallel
-	rm -f REMOVE_FAILED
 	local need_udev_wait=0
+	rm -f REMOVE_FAILED
+	#local listdevs=( $(dm_info name,open --sort open,name | grep "$prefix.*:0") )
+	#dmsetup remove --deferred ${listdevs[@]%%:0} || touch REMOVE_FAILED
+
 	init_udev_transaction
 	for dm in $(dm_info name --sort open,name | grep "$prefix"); do
 		dmsetup remove "$dm" &>/dev/null || touch REMOVE_FAILED &


