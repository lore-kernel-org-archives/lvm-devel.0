From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 29 Jan 2010 16:37:50 -0500
Subject: [PATCH 0/12]: Add infrastructure for metadata balancing.
Message-ID: <1264801082-28132-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset is a second round of the metadata balancing support.
It adds the infrastructure to set a bit inside the mda header on
a per-PV basis, control it from pvchange, and display the number
of mdas with this bit set on a particular PV or VG.

The disable/enable is implemented at the low level by taking advantage
of the 'filler' field in the mda_header structure on disk.  Normally
this is written to 0, but I propose we change this 32-bit field to
a 'flags' field and then define one flag that is a MDA disable.
Much of the patchset deals with propagating the disable through the
various LVM layers, and attempts to do this in a way that is true to
the existing abstractions.

This code should now work for non-orphan PVs as well as orphans.
Note that this patchset does not actually act on the bit to ignore
mdas with the bit set.  This should be fairly easy and will come
in future patches.

Applies cleanly on upstream:
commit 5584f2ae4621b03dc890c6e1a9028eb8add259a1
Author: Jonathan Earl Brassow <jbrassow@redhat.com>
Date:   Wed Jan 27 22:28:05 2010 +0000

    Was using dm_list_iterate_items when I should have been using
    *_safe.  This had the effect of segfaulting the log daemon when
    converting a mirror from one log type to another.
    
    Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>




