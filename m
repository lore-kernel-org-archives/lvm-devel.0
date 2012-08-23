From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:39 +0000 (UTC)
Subject: master - cleanup: ignore write/close output
Message-ID: <20120823124239.0A318A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8ad1f3e3a280b8cf3ca219dd6a6f3313b8be8d8
Commit:        c8ad1f3e3a280b8cf3ca219dd6a6f3313b8be8d8
Parent:        93f36fb77f595f67602cd9b39bb696e802545546
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 17 00:48:28 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:37 2012 +0200

cleanup: ignore write/close output

Intentionaly ignore write and close errors.
---
 .../lvm2_activation_generator_systemd_red_hat.c    |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 85420b8..9fcee20 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -46,7 +46,7 @@ static void kmsg(const char *format, ...)
 	if (kmsg_fd < 0 || (n < 0 || ((unsigned) n + 1 > sizeof(message))))
 		return;
 
-	write(kmsg_fd, message, n + 1);
+	(void) write(kmsg_fd, message, n + 1);
 }
 
 static int lvm_uses_lvmetad(void)
@@ -164,6 +164,6 @@ int main(int argc, char *argv[])
 out:
 	kmsg("LVM: Activation generator %s.\n", r ? "failed" : "successfully completed");
 	if (kmsg_fd != -1)
-		close(kmsg_fd);
+		(void) close(kmsg_fd);
 	return r;
 }


