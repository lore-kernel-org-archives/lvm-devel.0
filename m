From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 13 Oct 2012 17:22:07 +0000 (UTC)
Subject: master - cleanup: add gcc printf __attribute__
Message-ID: <20121013172207.798B233CE@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c7ab99843837bd9099ea502c8a34c05fad495c3
Commit:        7c7ab99843837bd9099ea502c8a34c05fad495c3
Parent:        feea5003cc0af2647f45a46d7b1d449a2f75e99b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 13 19:14:41 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 13 19:14:41 2012 +0200

cleanup: add gcc printf __attribute__

---
 .../lvm2_activation_generator_systemd_red_hat.c    |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index b8d1cfc..dfd6fc4 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -34,6 +34,7 @@ static char target_path[PATH_MAX];
 static char message[PATH_MAX];
 static int kmsg_fd = -1;
 
+__attribute__ ((format(printf, 1, 2)))
 static void kmsg(const char *format, ...)
 {
 	va_list ap;


