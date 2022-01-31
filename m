From: Kai Lüke <kai@kinvolk.io>
Date: Mon, 31 Jan 2022 17:22:31 +0100
Subject: [PATCH] systemd: Set RemainAfterExit=yes for oneshot service
Message-ID: <CAL6HQvHE08_Su1KhVy_MKzRrHNcjDpnqp94YMvZx6n2i2ofjdg@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Kai L?ke <kai@kinvolk.io>

The lvm2-activation(-early).service was triggered multiple times which
if done too quickly leads to a failure like this:
  systemd[1]: Finished Activation of LVM2 logical volumes.
  systemd[1]: lvm2-activation-early.service: Start request repeated too quickly.
  systemd[1]: lvm2-activation-early.service: Failed with result
'start-limit-hit'.
Set RemainAfterExit=yes as done for the other oneshot services to
prevent the unit from running multiple times in a row and hitting the
restart limit.
---
 scripts/lvm2_activation_generator_systemd_red_hat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c
b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 0f4ac8da2..1884b45ad 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -160,7 +160,7 @@ static int generate_unit(struct generator *gen, int unit)
     fputs("ExecStart=" LVM_PATH " vgchange -aay", f);
     if (gen->cfg.sysinit_needed)
         fputs(" --sysinit", f);
-    fputs("\nType=oneshot\n", f);
+    fputs("\nType=oneshot\nRemainAfterExit=yes\n", f);

     if (fclose(f) < 0) {
         _error("Failed to write unit file %s: %m.\n", unit_name);
-- 
2.26.2



