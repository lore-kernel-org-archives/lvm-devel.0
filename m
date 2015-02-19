From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 19 Feb 2015 17:34:50 +0000 (UTC)
Subject: master - doc: explanation of caching foreign VGs
Message-ID: <20150219173450.8128D60FA9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c6faaab4321ff91672ad818c47b8120d2b14180
Commit:        0c6faaab4321ff91672ad818c47b8120d2b14180
Parent:        97e3e84c2ca8678630ee8a45cb5e3cc2949c607b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 19 11:33:23 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 19 11:33:23 2015 -0600

doc: explanation of caching foreign VGs

---
 doc/caching_foreign_vgs.txt |   86 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/doc/caching_foreign_vgs.txt b/doc/caching_foreign_vgs.txt
new file mode 100644
index 0000000..12ffeca
--- /dev/null
+++ b/doc/caching_foreign_vgs.txt
@@ -0,0 +1,86 @@
+Q: Why should lvmetad cache foreign VGs?
+A: It's the most useful behavior in the "steady state".
+
+How to arrive at that conclusion.
+Four code configurations to consider, each in two different circumstances.
+
+configurations:
+
+1. lvm not using lvmetad
+2. lvm using lvmetad and lvmlockd
+3. lvm using lvmetad, and lvmetad does not cache foreign VGs
+   (Not currently implemented.)
+4. lvm using lvmetad, and lvmetad caches foreign VGs
+
+circumstances:
+
+A. steady state: PVs are not added or removed to/from foreign VGs
+B. transient state: PVs are added or removed to/from foreign VGs
+
+combinations:
+
+1.A. A PV is correctly shown in the foreign VG.
+1.B. A PV is correctly shown in the foreign VG.
+
+The most accurate representation, at the cost of always scanning disks.
+
+
+2.A. A PV is correctly shown in the foreign VG.
+2.B. A PV is correctly shown in the foreign VG.
+
+The most accurate representation, at the cost of using lvmlockd.
+
+
+3.A. A PV in a foreign VG is shown as unused.
+3.B. A PV in a foreign VG is shown as unused.
+
+If lvmetad ignores foreign VGs and does not cache them, the PVs in the
+foreign VGs appear to be unused.  This largely defeats the purpose of
+system_id, which is meant to treat VGs/PVs as foreign instead of free
+(albeit imperfectly, see below.)
+
+
+4.A. A PV is correctly shown in the foreign VG.
+4.B. A PV is not correctly shown in the foreign VG.
+
+This avoids the cost of always scanning disks, and avoids the cost of
+using lvmlockd.  The steady state 4.A. is an improvement over the steady
+state 3.A.  When the steady state is the common case, this is a big
+advantage.  When the steady state is *not* the common case, the foreign VG
+concept is not as useful (if shared devices are this dynamic, lvmlockd
+should be considered.)
+
+The limitations related to the transient state 4.B. are explained in
+lvmsystemid(7), along with how to handle it.  The specific inaccuracies
+possible in 4.B. are:
+
+. PV is shown as belonging to a foreign VG, but is actually unused.
+. PV is shown as unused, but actually belongs to a foreign VG.
+
+To resolve the inaccuracies in the transient state (4.B.), and return the
+system to an accurate steady state (4.A.), the disks need to be scanned,
+which updates lvmetad.  The scanning/updating is a manual step, i.e.
+running 'pvscan --cache', which by definition scans disks and updates
+lvmetad.
+
+--
+
+The --foreign command line option for report/display commands
+(vgs/lvs/pvs/vgdisplay/lvdisplay/pvdisplay) is not directly related to
+whether or not lvmetad caches foreign VGs.
+
+By default, foreign VGs are silently ignored and not printed by these
+commands.  However, when the --foreign option is used, these commands do
+produce output about foreign VGs.
+
+(When --foreign is not used, and the command specifically requests a
+foreign VG by name, an error is produced about not accessing foreign VGs,
+and the foreign VG is not displayed.)
+
+The decision to report/display foreign VGs or not is independent of
+whether lvmetad is caching those VGs.  When lvmetad is caching the foreign
+VG, a report/display command run with --foreign will scan disks to read
+the foreign VG and give the most up to date version of it (the copy of the
+foreign VG in lvmetad may be out of date due to changes to the VG by the
+foreign host.)
+


