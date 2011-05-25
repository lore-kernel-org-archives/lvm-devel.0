From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 25 May 2011 21:43:13 -0000
Subject: LVM2/doc udev_assembly.txt
Message-ID: <20110525214313.28573.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-05-25 21:43:13

Added files:
	doc            : udev_assembly.txt 

Log message:
	First draft of a document describing how we will automatically and
	incrementally assemble (possibly multi-component, like LVM) storage devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/udev_assembly.txt.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/doc/udev_assembly.txt,v  -->  standard output
revision 1.1
--- LVM2/doc/udev_assembly.txt
+++ -	2011-05-25 21:43:13.316460000 +0000
@@ -0,0 +1,83 @@
+Automatic device assembly by udev
+=================================
+
+We want to asynchronously assemble and activate devices as their components
+become available. Eventually, the complete storage stack should be covered,
+including: multipath, cryptsetup, LVM, mdadm. Each of these can be addressed
+more or less separately.
+
+The general plan of action is to simply provide udev rules for each of the
+device "type": for MD component devices, PVs, LUKS/crypto volumes and for
+multipathed SCSI devices. There's no compelling reason to have a daemon do these
+things: all systems that actually need to assemble multiple devices into a
+single entity already either support incremental assembly or will do so shortly.
+
+Whenever in this document we talk about udev rules, these may include helper
+programs that implement a multi-step process. In many cases, it can be expected
+that the functionality can be implemented in couple lines of shell (or couple
+hundred of C).
+
+Multipath
+---------
+
+For multipath, we will need to rely on SCSI IDs for now, until we have a better
+scheme of things, since multipath devices can't be identified until the second
+path appears, and unfortunately we need to decide whether a device is multipath
+when the *first* path appears. Anyway, the multipath folks need to sort this
+out, but it shouldn't bee too hard. Just bring up multipathing on anything that
+appears and is set up for multipathing.
+
+LVM
+---
+
+For LVM, the crucial piece of the puzzle is lvmetad, which allows us to build up
+VGs from PVs as they appear, and at the same time collect information on what is
+already available. A command, pvscan --lvmetad is expected to be used to
+implement udev rules. It is relatively easy to make this command print out a
+list of VGs (and possibly LVs) that have been made available by adding any
+particular device to the set of visible devices. In othe words, udev says "hey,
+/dev/sdb just appeared", calls pvscan --lvmetad, which talks to lvmetad, which
+says "cool, that makes vg0 complete". Pvscan takes this info and prints it out,
+and the udev rule can then somehow decide whether anything needs to be done
+about this "vg0". Presumably a table of devices that need to be activated
+automatically is made available somewhere in /etc (probably just a simple list
+of volume groups or logical volumes, given by name or UUID, globbing
+possible). The udev rule can then consult this file.
+
+Cryptsetup
+----------
+
+This may be the trickiest of the lot: the obvious hurdle here is that crypto
+volumes need to somehow obtain a key (passphrase, physical token or such),
+meaning there is interactivity involved. On the upside, dm-crypt is a 1:1
+system: one encrypted device results in one decrypted device, so no assembly or
+notification needs to be done. While interactivity is a challenge, there are at
+least partial solutions around. (TODO: Milan should probably elaborate here.)
+
+(For LUKS devices, these can probably be detected automatically. I suppose that
+non-LUKS devices can be looked up in crypttab by the rule, to decide what is the
+appropriate action to take.)
+
+MD
+--
+
+Fortunately, MD (namely mdadm) already comes with a mechanism for incremental
+assembly (mdadm -I or such). We can assume that this fits with the rest of stack
+nicely.
+
+
+Filesystem &c. discovery
+========================
+
+Considering other requirements that exist for storage systems (namely
+large-scale storage deployments), it is absolutely not feasible to have the
+system hunt automatically for filesystems based on their UUIDs. In a number of
+cases, this could mean activating tens of thousands of volumes. On small
+systems, asking for all volumes to be brought up automatically is probably the
+best route anyway, and once all storage devices are activated, scanning for
+filesystems is no different from today.
+
+In effect, no action is required on this count: only filesystems that are
+available on already active devices can be mounted by their UUID. Activating
+volumes by naming a filesystem UUID is useless, since to read the UUID the
+volume needs to be active first.


