From: Milan P. Gandhi <mgandhi@redhat.com>
Date: Thu, 23 Nov 2017 15:07:26 +0530
Subject: [PATCH] vgexport man page update
Message-ID: <4492b4f1-6b5b-ce0a-bed3-d5280601d6c4@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There were queries raised by couple of users about what is a significance
of using vgexport after deactivating the volume group using vgchange -an
during VG, PV migrations from one system to other. But the man page was
not having more detailed information of benefit of using vgexport after
de-activating the volume group.

This patch adds some more information to the man page of vgexport to
provide more insights about how doing vgexport before a volume group
migration could help to avoid accidental access to the VG and benefit of
using vgexport after using vgchange -an.

Signed-off-by: Milan P. Gandhi <mgandhi@redhat.com>
---
 man/vgexport.8_des | 42 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 41 insertions(+), 1 deletion(-)

diff --git a/man/vgexport.8_des b/man/vgexport.8_des
index 66d3af3..dd6eacc 100644
--- a/man/vgexport.8_des
+++ b/man/vgexport.8_des
@@ -2,7 +2,47 @@ vgexport makes inactive VGs unknown to the system. In this state, all the
 PVs in the VG can be moved to a different system, from which
 \fBvgimport\fP(8) can then be run.
 
-Most LVM tools ignore exported VGs.
+Most LVM tools ignore exported VGs. Once the volume group is in exported
+state, any accidental attempt to activate the volume group or lvm volumes
+present in it would fail with an error.
+
+Benefit of using vgexport:
+
+While migrating the physical volumes, volume groups from one system to
+another, once the volume group is de-activated, there is still a risk
+that any scheduled backup jobs, automation scripts, or applications which
+are configured to use specific lvm volume/volume group may try to access
+the volume group when it is in de-activated state. It may also try to
+activate the volume group. And if the volume group accidentally gets
+activated during migration process, then it could lead to lvm, filesystem
+metadata corruption.
+
+To avoid any chances of above risk, user could export the volume group
+from system before a migration. It would prevent any further access or
+changes in the volume group.
+
+For example, an attempt to re-activate the volume group or lvm volumes in
+exported vg would fail with below error:
+.br
+.B # vgchange -ay testvg
+  Volume group "testvg" is exported
+.br
+.B # lvchange -ay testvg/testlv
+  Volume group testvg is exported
+
+Any accidental changes e.g. removal of PV from VG also fails with similar
+error:
+.br
+.B # vgreduce testvg /dev/mapper/mpatha
+  Volume group testvg is exported
+  Cannot process volume group testvg
+  Failed to find physical volume "/dev/mapper/mpatha".
+
+Once the volume group is exported from system, it would be available on
+any system only after re-importing it. Thus it would add an additional
+layer of security for volume group when it is being migrated from one
+system to other. It would prevent the volume group from activation or
+any accidental changes.
 
 vgexport clears the VG system ID, and vgimport sets the VG system ID to
 match the host running vgimport (if the host has a system ID).
-- 
2.4.3


