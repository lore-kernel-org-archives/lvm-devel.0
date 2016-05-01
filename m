From: Michael Chapman <mike@very.puzzling.org>
Date: Sun,  1 May 2016 16:08:18 +1000
Subject: [PATCH] signals: fix off-by-one when saving whether SIGINT was masked
Message-ID: <1462082898-20385-1-git-send-email-mike@very.puzzling.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

sigint_allow saves whether SIGINT was masked in the _oldmasked array,
however an off-by-one in the calculation of the array index leads to the
wrong signal mask possibly being restored in sigint_restore.

This problem was discovered when the user attempted to use Ctrl+C to
abort a snapshot creation. The scenario can be recreated in GDB by
having it raise the signal immediately after the origin volume's
mappings have been suspended, e.g. when _lv_suspend_lv returns:

  (gdb) handle SIGINT nostop noprint pass
  SIGINT is used by the debugger.
  Are you sure you want to change it? (y or n) y
  Signal        Stop    Print   Pass to program Description
  SIGINT        No      No      Yes             Interrupt

  (gdb) b _lv_suspend_lv
  Breakpoint 1 at 0x56bc0: file activate/activate.c, line 1273.

  (gdb) r -s -L 20G -n y /dev/example/x
  Starting program: /sbin/lvcreate -s -L 20G -n y /dev/example/x

  Breakpoint 1, _lv_suspend_lv (...)
      at activate/activate.c:1273
  1273  {

  (gdb) finish
  Run till exit from #0  _lv_suspend_lv (...) at activate/activate.c:1273

    Suspending example-x (253:20) with filesystem sync with device flush
    Suspending example-x-real (253:21) with filesystem sync with device flush

  1938                  if (!_lv_suspend_lv(ondisk_lv, laopts, lockfs, flush_required)) {
  Value returned is $1 = 1

  (gdb) signal SIGINT
  Continuing with signal SIGINT.

  Program terminated with signal SIGINT, Interrupt.
  The program no longer exists.

This leaves the mappings suspended:

  # dmsetup info | grep -B1 SUSPENDED
  Name:              example-x
  State:             SUSPENDED
  --
  Name:              example-x-real
  State:             SUSPENDED

With this fix the signal remains masked until the snapshot LV has been
fully created:

  ...
  (gdb) finish
  Run till exit from #0  _lv_suspend_lv (...) at activate/activate.c:1273

    Suspending example-x (253:20) with filesystem sync with device flush
    Suspending example-x-real (253:21) with filesystem sync with device flush

  1938                  if (!_lv_suspend_lv(ondisk_lv, laopts, lockfs, flush_required)) {
  Value returned is $1 = 1

  (gdb) signal SIGINT
  Continuing with signal SIGINT.

    Logical volume "y" created.

  Program terminated with signal SIGINT, Interrupt.
  The program no longer exists.
---

Please keep me CCed on any correspondence as I am not subscribed to this list.

 lib/misc/lvm-signal.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index 7e78407..30bdc01 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -85,7 +85,7 @@ void sigint_allow(void)
 	if (sigprocmask(0, NULL, &sigs))
 		log_sys_debug("sigprocmask", "");
 
-	if ((_oldmasked[_handler_installed] = sigismember(&sigs, SIGINT))) {
+	if ((_oldmasked[_handler_installed - 1] = sigismember(&sigs, SIGINT))) {
 		sigdelset(&sigs, SIGINT);
 		if (sigprocmask(SIG_SETMASK, &sigs, NULL))
 			log_sys_debug("sigprocmask", "SIG_SETMASK");
-- 
2.5.5


