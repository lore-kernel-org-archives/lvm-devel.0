From: Heinz Mauelshagen <heinzm@redhat.com>
Date: Wed, 10 Mar 2010 19:24:45 +0100
Subject: vgchange.c gets dmeventd monitoring activation wrong
In-Reply-To: <1268244506.3074.92.camel@o>
References: <1268243003.3074.62.camel@o>  <1268244506.3074.92.camel@o>
Message-ID: <1268245485.3074.102.camel@o>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Got the setting in case "--monitor {y|n}" got provided wrong.
See next patch below.


On Wed, 2010-03-10 at 19:08 +0100, Heinz Mauelshagen wrote:
> Next version rejecting both monitoring flags being provided.
> 
> On Wed, 2010-03-10 at 18:43 +0100, Heinz Mauelshagen wrote:
> > Updating to Fedora 12 kernel 2.6.32.9-67.fc12.x86_64 I was left
> > with no root device.
> > 
> > Reason was, that we don't get dmeventd device monitoring activation
> > (deactivation in this case rather) right, hence causing dlopen on
> > libdevemapper-event DSO(s) via the dmeventd call chain.
> > 
> > The DSOs are intentionally not part of the initramfs for obvious
> > reasons, which should be respected by the fact, that we call "vgchange
> > --monitor n" from dracut's lvm_scan script.
> > 
> > This patch is a proposal to fix the dmeventd activation handling via the
> > 
> > "--ignoremonitoring" and the "--monitor {y|n}"
> > 
> > options and is not tested yet.
> > 
> > It give precedence to the "--ignoremonitoring" option over the other
> > one, which makes more sense IMO and needs a vgchange(8) manual change to
> > reflect this.
> > Of course we should better raise a command line error if both are given,
> > which is subject to future discussion.

Signed-off-by: Heinz Mauelshagen <heinzm@redhat.com>
---
 LVM2.2.02.53/tools/{vgchange.c.orig => vgchange.c} |   23 ++++++++++++++++---
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git LVM2.2.02.53/tools/vgchange.c.orig LVM2.2.02.53/tools/vgchange.c
index 95b0b48..eb29fe4 100644
--- LVM2.2.02.53/tools/vgchange.c.orig
+++ LVM2.2.02.53/tools/vgchange.c
@@ -494,16 +494,31 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 			   struct volume_group *vg,
 			   void *handle __attribute((unused)))
 {
-	int r = ECMD_FAILED;
+	int dmeventd_mode, r = ECMD_FAILED;
 
 	if (vg_is_exported(vg)) {
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}
 
-	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
-					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
-					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
+	if (arg_count(cmd, ignoremonitoring_ARG) &&
+	    arg_count(cmd, monitor_ARG)) {
+		log_error("Can't specify both monitoring flags");
+		return ECMD_FAILED;
+	}
+
+	/* Check conditions to activate dmeventd montoring. */
+	if (is_static())
+		dmeventd_mode = DMEVENTD_MONITOR_IGNORE;
+	else if (arg_count(cmd, ignoremonitoring_ARG))
+		dmeventd_mode = DMEVENTD_MONITOR_IGNORE;
+	else if (arg_count(cmd, monitor_ARG))
+		dmeventd_mode = arg_int_value(cmd, monitor_ARG,
+					      DEFAULT_DMEVENTD_MONITOR);
+	else
+		dmeventd_mode = DEFAULT_DMEVENTD_MONITOR;
+		
+	init_dmeventd_monitor(dmeventd_mode);
 
 	if (arg_count(cmd, available_ARG))
 		r = _vgchange_available(cmd, vg);



