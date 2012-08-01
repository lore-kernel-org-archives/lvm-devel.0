From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  1 Aug 2012 06:59:42 +0000 (UTC)
Subject: master - systemd: O_CLOEXEC not needed in activation generator
Message-ID: <20120801065942.399D31376@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e309586aebec5ab034c89536620c0b102b8a366c
Commit:        e309586aebec5ab034c89536620c0b102b8a366c
Parent:        c6cc871df845ea4c810122a59606c3c593d15772
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 1 08:57:12 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 1 08:57:12 2012 +0200

systemd: O_CLOEXEC not needed in activation generator

O_CLOEXEC not actually needed, this is just a simple program,
it is not supposed to fork/exec anywhere and anytime in the future.
---
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 9921004..85420b8 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -144,7 +144,7 @@ int main(int argc, char *argv[])
 	const char *dir;
 	int r = EXIT_SUCCESS;
 
-	kmsg_fd = open(KMSG_DEV_PATH, O_WRONLY|O_NOCTTY|O_CLOEXEC);
+	kmsg_fd = open(KMSG_DEV_PATH, O_WRONLY|O_NOCTTY);
 
 	if (argc > 1 && argc != 4) {
 		kmsg("LVM: Activation generator takes three or no arguments.\n");


