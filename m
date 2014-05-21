From: dongmao zhang <dmzhang@suse.com>
Date: Wed, 21 May 2014 15:21:46 +0800
Subject: [PATCH] Mark the generated service file avaliable to be accessed
Message-ID: <1400656906-14751-1-git-send-email-dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'journalctl -b' reports this:
May 17 08:21:00 test systemd[1]: Configuration file
/run/systemd/generator/lvm2-activation-early.service is marked
world-inaccessible. This has no effect as configuration data is
accessible via
APIs without restrictions. Proceeding anyway.

So, set the mask to 022 for all the generators
---
 scripts/lvm2_activation_generator_systemd_red_hat.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index e39f901..6a003f5 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -170,6 +170,7 @@ int main(int argc, char *argv[])
 {
 	const char *dir;
 	int r = EXIT_SUCCESS;
+	mode_t old_mask;
 
 	kmsg_fd = open(KMSG_DEV_PATH, O_WRONLY|O_NOCTTY);
 
@@ -184,10 +185,13 @@ int main(int argc, char *argv[])
 
 	dir = argv[1];
 
+	/* mark lvm2-activation.*.service as world-accessible */
+	old_mask = umask(0022);
 	if (!generate_unit(dir, UNIT_EARLY) ||
 	    !generate_unit(dir, UNIT_MAIN) ||
 	    !generate_unit(dir, UNIT_NET))
 		r = EXIT_FAILURE;
+	umask(old_mask);
 out:
 	if (r)
 		kmsg(LOG_ERR, "LVM: Activation generator failed.\n");
-- 
1.8.4.5


