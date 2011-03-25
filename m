From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Mar 2011 22:57:45 +0100
Subject: [PATCH 1/3] Fix mem
In-Reply-To: <cover.1301089240.git.zkabelac@redhat.com>
References: <cover.1301089240.git.zkabelac@redhat.com>
Message-ID: <e943c109d457bd2cc89c836ae810ec9b8c7bb8f3.1301089240.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix release order when some data reference are moved
between pools - as data are move 'from -> to'
we just need to ensure 'from' pool will be released
as the last.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/vgmerge.c |    6 ++++--
 tools/vgsplit.c |    6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/tools/vgmerge.c b/tools/vgmerge.c
index adb00a0..e4431be 100644
--- a/tools/vgmerge.c
+++ b/tools/vgmerge.c
@@ -155,8 +155,10 @@ bad:
 		unlock_and_free_vg(cmd, vg_to, vg_name_to);
 		unlock_and_free_vg(cmd, vg_from, vg_name_from);
 	} else {
-		unlock_and_free_vg(cmd, vg_from, vg_name_from);
-		unlock_and_free_vg(cmd, vg_to, vg_name_to);
+		unlock_vg(cmd, vg_name_from);
+		unlock_vg(cmd, vg_name_to);
+		free_vg(vg_to);
+		free_vg(vg_from);
 	}
 	return r;
 }
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index b97db97..f30c335 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -491,8 +491,10 @@ bad:
 		unlock_and_free_vg(cmd, vg_to, vg_name_to);
 		unlock_and_free_vg(cmd, vg_from, vg_name_from);
 	} else {
-		unlock_and_free_vg(cmd, vg_from, vg_name_from);
-		unlock_and_free_vg(cmd, vg_to, vg_name_to);
+		unlock_vg(cmd, vg_name_from);
+		unlock_vg(cmd, vg_name_to);
+		free_vg(vg_to);
+		free_vg(vg_from);
 	}
 	return r;
 }
-- 
1.7.4.1


