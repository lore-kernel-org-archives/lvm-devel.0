From: dwysocha@redhat.com <dwysocha@redhat.com>
Date: Mon, 24 Mar 2008 16:23:43 -0400
Subject: [PATCH vgsplit 0/4] bz#251990: Move logical volume from one VG to another
Message-ID: <20080324202343.627758622@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following patches update vgsplit to allow LVs on the cmdline.

Original vgsplit code only allowed PVs on the cmdline, and would fail with
an error message in many cases indicating that the split could not occur
because it would violate an internal LVM rule of splitting a LV across a
volume group.

This code enhances vgsplit in the following ways:
1) Allow LVs on the commandline.  This should be very useful as the user does
not have to figure out which PVs to move.
2) Figures out underlying dependencies and queries the user if more volumes
would be moved than specified on the commandline.  This seemed to be a natural
progression once LVs were considered.  There are many scenarios where moving
one LV would result in moving other LVs/PVs as a result of the internal LVM
rules where an LV/PV must be contained within a single VG.
3) No longer fails with error messages indicating we can't split a PV/LV
across volume groups

The following patches should also allow a simple fix to another bz:
https://bugzilla.redhat.com/show_bug.cgi?id=252041
"vgsplit an active VG where the split involves only inactive LVs"

I am not entirely happy with the code and there are some shortcomings but I
figured it is close enough to post.  Comments welcome.

-- 


