From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 27 Jul 2009 16:01:48 -0400
Subject: [PATCH] Update return code for lvm_config_reload.
In-Reply-To: <1248724909-20369-5-git-send-email-dwysocha@redhat.com>
References: <1248724909-20369-1-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-2-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-3-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-4-git-send-email-dwysocha@redhat.com>
	<1248724909-20369-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1248724909-20369-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 liblvm/lvm_base.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
index 33d8395..5003b0a 100644
--- a/liblvm/lvm_base.c
+++ b/liblvm/lvm_base.c
@@ -67,7 +67,7 @@ void lvm_destroy(lvm_t libh)
 int lvm_config_reload(lvm_t libh)
 {
 	/* FIXME: re-init locking needed here? */
-	if (refresh_toolcontext((struct cmd_context *)libh))
+	if (!refresh_toolcontext((struct cmd_context *)libh))
 		return -1;
 	return 0;
 }
-- 
1.6.0.6


