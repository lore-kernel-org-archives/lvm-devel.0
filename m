From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 15:46:30 -0500
Subject: master - scripts: avoid voiding write result
Message-ID: <201812212046.wBLKkUbe021358@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4577c427a76c6a337b7812f9da7700c2c8beb89
Commit:        a4577c427a76c6a337b7812f9da7700c2c8beb89
Parent:        a3fe6195521a58c93d7158028c7ab62da14d4ddd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 11:19:25 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 21:42:30 2018 +0100

scripts: avoid voiding write result

Gcc doesn't want to ignore write() return code.
---
 .../lvm2_activation_generator_systemd_red_hat.c    |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 0e6c05a..b44c8f0 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -69,7 +69,8 @@ static void _error(const char *format, ...)
 		return;
 
 	/* The n+31: +30 for "<n>lvm2-activation-generator: " prefix and +1 for '\0' suffix */
-	(void) write(_kmsg_fd, message, n + 31);
+	if (write(_kmsg_fd, message, n + 31) < 0)
+		_error("Failed to write activation message %s: %m.\n", message);
 }
 
 //----------------------------------------------------------------


