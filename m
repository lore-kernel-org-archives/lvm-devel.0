From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:34 +0100
Subject: [PATCH 10/15] Testing: Lower mem usage of inconsistent mda test
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <32b987e95905f0f0f5f26fe76f4aa55cb6b176a4.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Smaller size of devices speedups this test.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/t-inconsistent-metadata.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/t-inconsistent-metadata.sh b/test/t-inconsistent-metadata.sh
index 4dcc766..ce920be 100644
--- a/test/t-inconsistent-metadata.sh
+++ b/test/t-inconsistent-metadata.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux prepare_vg 3
+aux prepare_vg 3 12
 
 lvcreate -m 1 -l 1 -n mirror $vg
 lvcreate -l 1 -n resized $vg
-- 
1.7.3.5


