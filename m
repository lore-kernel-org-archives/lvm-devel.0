From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 16 Sep 2011 13:07:58 +0100
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
In-Reply-To: <20110913151342.26443.qmail@sourceware.org>
References: <20110913151342.26443.qmail@sourceware.org>
Message-ID: <20110916120758.GB16890@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 13, 2011 at 03:13:42PM -0000, prajnoha at sourceware.org wrote:
> 	Let's use this until we have a proper solution.

That patch is unsuitable for general release and needs to be reverted in my
opinion.

There is a fallacy in assuming that the udev problem is the only reason for the
detected failure and then installing the defensive action on unaffected code
paths.  There are cases in which repeating the remove ioctl will make no
difference and the code will continue to see EBUSY and an enforced 5 second
delay risks causing some people new problems.  But with just a little more
effort, you can obtain the best of both worlds.


Please update the patch to address the following points:

1. Currently the ioctl buffer contents are 'undefined' when the ioctl returns
an error.  I'm not happy to assume the buffer will always be unchanged if
there's an error - it should be repopulated before reuse.  (This basically
means I want the repeat loop in a higher layer of the code, or a new flag
defining...
  - Hmmm.  Mikulas - Have we just broken the BUFFER_FULL logic with
dm-ioctl-forbid-multiple-device-specifiers.patch?  Might have to revert
that kernel patch or update it only to complain if the multiple
specifiers don't all point to the same device...)

2. The repeat must be made conditional, so it only occurs in potential problem
cases i.e. filter out as many 'OK' cases as you possibly can.
- if udev is not involved (which we already know from other variables) skip
this code (easy)
- consider any other easy tests that can narrow the filtering

3. 'dmsetup remove' must not use the new behaviour by default, or you risk
affecting some people's existing scripts adversely.  Add a new cmdline switch
to enable this.  I do not think it should be enabled by default.  Keep sight of
the fact that the cases you're trying to improve involve specific *sequences*
of commands run in quick succession and there are no grounds for removing
functionality from dmsetup/libdevmapper by denying users the ability to run
individual ioctls and allowing them to handle the failures as *they* see fit.

4. We can't rule out unanticipated side-effects on the lvm2 side either,
so, while enabled by default when udev is in use, it must still be possible to
turn off the feature at run time, using an lvm.conf setting.

5. I've seen no empirical evidence yet to justify the selection of the number
of retries and the sleep time.  E.g. Please provide some base data on the length
of a typical delay/number of repeated attempts caused by a common problematic
udev rule firing to back up the numbers chosen, and consider whether 'one size
fits all' is suitable or if it needs to be tunable (is 5 seconds long enough on
a slow and loaded system?), or could it itself be triggered by something else?

Alasdair


