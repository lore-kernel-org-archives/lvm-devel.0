From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:32 +0100
Subject: [PATCH 08/15] Testing: Accelerate mirror tests
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <8256a3ee62a2971c5695fbbb0765b06e0a71dbc9.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Instead of recreation whole device set for each test round,
just cleanup created LVs to empty VG.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-lvconvert-mirror-basic.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/t-lvconvert-mirror-basic.sh b/test/t-lvconvert-mirror-basic.sh
index d2d43e5..413e6f2 100644
--- a/test/t-lvconvert-mirror-basic.sh
+++ b/test/t-lvconvert-mirror-basic.sh
@@ -77,8 +77,6 @@ test_lvconvert()
 		max_log_count=$start_log_count
 	fi
 
-	aux prepare_vg 5
-
 	if [ $start_count -gt 0 ]; then
 		# Are there extra devices for the log or do we overlap
 		if [ $(($start_count_p1 + $start_log_count)) -gt ${#dev_array[@]} ]; then
@@ -123,7 +121,7 @@ test_lvconvert()
 	fi
 }
 
-aux prepare_vg 5
+aux prepare_vg 5 16
 
 test_many() {
 	i=$1
@@ -135,7 +133,9 @@ test_many() {
 				: "Testing mirror conversion -m$i/$k -> -m$j/$l"
 				: ----------------------------------------------------
 				test_lvconvert $i $k $j $l 0
+				lvremove -ff $vg
 				test_lvconvert $i $k $j $l 1
+				lvremove -ff $vg
 			done
 		done
 	done
-- 
1.7.3.5


