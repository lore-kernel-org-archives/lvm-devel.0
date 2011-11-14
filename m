From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Nov 2011 16:12:56 -0500
Subject: [PATCH 0/5] Check for resized smaller devices, v1, rhbz753914
Message-ID: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Addresses https://bugzilla.redhat.com/show_bug.cgi?id=753914

This patchset adds a check if a device has been resized since
being added to LVM's control.  The background of this patchset
was customer case where the devices had been resized, but it
was not detected by LVM until they tried to do an 'lvcreate'
and got the cryptic "reload ioctl failed".

Start by adding a _check_pv_sizes() function which goes through
all PVs in a VG and verifies whether the current device size is
smaller than the recorded size of the PV.

Next, call _check_pv_sizes() from vg_read_internal() and flag
a warning.  We flag a warning here instead of failing to allow
for a repair function to be added later.

Also call _check_pv_sizes() from vg_validate().  This will catch
things like a pvcreate being done, and then later the device size
changes and you try adding it to the VG.  For now, flag this as
an error and don't allow metadata updates if a PV like this is
detected.  We could relax this and just do a warning for now.

Finally, add a nightly test function, resize_dev, to assist in
testing this, as well as a specific t-pv-resized.sh test which
demonstrates vgextend failing when a PV gets sized smaller.

Further patches could include adding to 'pvck' and/or 'vgck' the
ability to repair (provided no LVs would be affected, for any
resized device, call 'pvresize --setphysicalvolumesize' using
the current device size).

Ran against nightly tests with no failures, some warnings:
Testing with locking_type 1
## 91 tests 62:01 : 71 OK, 6 warnings, 0 failures; 14 skipped


