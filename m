From: Petr Rockai <prockai@redhat.com>
Date: Wed, 04 Aug 2010 17:51:46 +0200
Subject: [PATCH] Never scan internal LVM devices.
Message-ID: <878w4mnzot.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch disables scanning for any LVM-created internal
devices, such as mirror images, mirror logs, snapshot COW areas etc.

There are two reasons for this: First, scanning these devices can
disrupt more complex operations (primarily lvconvert) involving
deactivation of these internal devices. See BZs 596453, 606931 and
607316.

Second that even if such a device contains a PV label (or an MDA), it
should never be used by LVM as a PV. Since these logical volumes are
never visible to the user (disregarding any bugs in LVM) and they cannot
be created by the user, they always exist as a part of a composite
logical volume.

Even if a PV was stacked in an LV, and this LV was composite (so it is
using some internal LVs as its components), it is desirable that this
*and only* this composite LV is seen by LVM as a PV. If the PV label or
MDA is propagated into the component LVs (such as mimages) and these are
found during a scan, this would lead to the PV being found multiple
times which is certainly undesirable. Cf. the situation with MD
component devices, which is analogous.

For all I can tell, this patch would fix all the above-mentioned BZs,
which are all high-priority test blockers.

Yours,
   Petr.

PS: There are other options to address the disruption issue that is
causing all the above bugzillas. Nevertheless, all other options seem to
be too complex to implement and would run a high risk of regressions in
unrelated areas of functionality -- we have discussed this last week
with Alasdair. I believe the proposed patch is relatively simple and
does not introduce any bad behaviours (nor eliminates any desirable
behaviours).

-------------- next part --------------
A non-text attachment was scrubbed...
Name: never-scan-internal-devices.diff
Type: text/x-diff
Size: 3010 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100804/09657755/attachment.bin>
