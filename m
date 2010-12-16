From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:12 +0100
Subject: [PATCH 04/20] Remove wrong cast to (char*)
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <84c785966181f3aa1e3c14839bf3e8e4cf23b60f.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 liblvm/lvm_base.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index f8e1004..9e1a8ec 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -61,7 +61,7 @@ lvm_t lvm_init(const char *system_dir)
 	 * archive() call.  Possible example:
 	 * cmd_line = "lvm_vg_create: vg1\nlvm_vg_extend vg1 /dev/sda1\n"
 	 */
-	cmd->cmd_line = (char *)"liblvm";
+	cmd->cmd_line = "liblvm";
 
 	return (lvm_t) cmd;
 }
-- 
1.7.3.3


