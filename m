From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:02:51 +0000 (UTC)
Subject: dev-mornfall-lvmcache - udev: fire pvscan --cache properly on CHANGE event for MD devices
Message-ID: <20130605120251.2B6B960993@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ac217d408470dcecb69b83d9cbf7a254747fa5b
Commit:        2ac217d408470dcecb69b83d9cbf7a254747fa5b
Parent:        baf9ef2047675279c72f27abeb2c328f5de2c78d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri May 3 13:20:07 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 3 13:55:53 2013 +0200

udev: fire pvscan --cache properly on CHANGE event for MD devices

Commit 756bcabbfe297688ba240a880bc2b55265ad33f0 restricted the
situations at which the LVM autoactivation fires - only on ADD
event for devices other than DM. However, this caused a problem
for MD devices...

MD devices are activated in a very similar way as DM devices:
the MD dev is created on first appeareance of MD array member
(ADD event) and stays *inactive* until the array is complete.
Just then the MD dev turns to active state and this is reported
to userspace by CHANGE event.

Unfortunately, we can't differentiate between the CHANGE event
coming from udev trigger/WATCH rule and CHANGE event coming from
the transition to active state - MD would need to add similar logic
we already use to detect this in DM world. For now, we just have
to enable pvscan --cache on *all* CHANGE events for MD so the
autoactivation of the LVM volumes on top of MD works.

A downside of this is that a spurious CHANGE event for MD dev
can cause the LVM volumes on top of it to be automatically activated.
However, one should not open/change the device underneath until
the device above in the stack is removed! So this situation should
only happen if one opens the MD dev for read-write by mistake
(and hence firing the CHANGE event because of the WATCH udev rule),
or if calling udev trigger manually for the MD dev.

(No WHATS_NEW here as this fixes the commit mentioned
above and which has not been released yet.)
---
 udev/69-dm-lvm-metad.rules.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/udev/69-dm-lvm-metad.rules.in b/udev/69-dm-lvm-metad.rules.in
index 66c58b3..a0e48a1 100644
--- a/udev/69-dm-lvm-metad.rules.in
+++ b/udev/69-dm-lvm-metad.rules.in
@@ -21,6 +21,7 @@ SUBSYSTEM!="block", GOTO="lvm_end"
 ENV{ID_FS_TYPE}!="LVM2_member|LVM1_member", GOTO="lvm_end"
 
 ACTION=="remove", GOTO="lvm_scan"
+ACTION=="change", KERNEL=="md[0-9]*", GOTO="lvm_scan"
 
 # If the PV is not a dm device, scan only after device addition (ADD event)
 KERNEL!="dm-[0-9]*", ACTION!="add", GOTO="lvm_end"


