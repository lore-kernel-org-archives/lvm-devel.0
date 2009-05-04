From: Milan Broz <mbroz@redhat.com>
Date: Mon, 04 May 2009 22:13:48 +0200
Subject: [PATCH] Zero pvmove mirror count during initialization of device manager
Message-ID: <49FF4C7C.9080007@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zero pvmove mirror count during initialization of device manager.

(Otherwise there is uninitialized value.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/dev_manager.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 1083fcd..8f068d3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -455,6 +455,7 @@ struct dev_manager *dev_manager_create(struct cmd_context *cmd,
 		goto_bad;
 
 	dm->target_state = NULL;
+	dm->pvmove_mirror_count = 0u;
 
 	return dm;
 



