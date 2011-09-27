From: Lukas Czerner <lczerner@redhat.com>
Date: Tue, 27 Sep 2011 15:42:41 +0200
Subject: [PATCH v3 08/18] fsadm: Remove unnecessary modification of PATH variable
In-Reply-To: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
Message-ID: <1317130971-24173-9-git-send-email-lczerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

User (or the system) should be set properly so there is no need to
modify PATH variable. It also prevent us from setting appropriate PATH
before calling the fsadm.

Signed-off-by: Lukas Czerner <lczerner@redhat.com>
---
 scripts/fsadm.sh |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 2d5c6f9..a1044f7 100755
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -37,9 +37,6 @@
 
 TOOL=$(basename "$0")
 
-_SAVEPATH=$PATH
-PATH=/sbin:/usr/sbin:/bin:/usr/sbin:$PATH
-
 # utilities
 TUNE_EXT=tune2fs
 RESIZE_EXT=resize2fs
-- 
1.7.4.4


