From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:55:40 +0100
Subject: [PATCH 1/6] Cleanup gcc warning: function declaration isn't a prototype
In-Reply-To: <cover.1265812946.git.zkabelac@redhat.com>
References: <cover.1265812946.git.zkabelac@redhat.com>
Message-ID: <3b6d2f241a4307c09918dd51db9e0fa0424718ad.1265812946.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvmcmdline.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 85d6ce3..4881d54 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -912,7 +912,7 @@ static void _apply_settings(struct cmd_context *cmd)
 	cmd->handles_missing_pvs = 0;
 }
 
-static void _set_udev_checking()
+static void _set_udev_checking(void)
 {
 	const char *e;
 
-- 
1.6.6.1


