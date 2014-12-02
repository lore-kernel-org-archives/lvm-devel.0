From: Lukas Wunner <lukas@wunner.de>
Date: Tue, 2 Dec 2014 22:00:45 +0100
Subject: [PATCH] dmsetup: Set exit code to 1 if remove_all fails to remove all devices
In-Reply-To: <547E0FF0.70605@redhat.com>
References: <20141202175825.GA8489@wunner.de>
 <547E0FF0.70605@redhat.com>
Message-ID: <20141202210045.GA8939@wunner.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

On Tue, Dec 02, 2014 at 08:16:00PM +0100, Zdenek Kabelac wrote:
> It really is meant to remove only not opened devices.

Sorry but that's not the point.

The interpretation of a program's exit status by the Shell is inverse
to the semantics in C. An exit status of 0 denotes success, a non-zero
exit status denotes failure.

The point is that, as evidenced by the dracut shutdown script I mentioned,
people expect the exit status of "dmsetup remove_all" to be non-zero if
the program failed to remove all devices. It's perfectly okay if it failed
to remove all devices. No need to remove devices that are still open.

But the program should *tell* the user that some devices could not be
closed (at the very least by returning with a non-zero exit status).

Right now the exit status of "dmsetup remove_all" is always 0, thus
pretending success.

As for the dracut shutdown script allegedly being broken: That script
was written by Harald Hoyer who works for the same company as you do
and is shipped with RHEL as well as Fedora. Just saying...

To provide some context: Dracut has a number of shutdown scripts that
are called round-robin until all succeed. This is useful for complex
LVM setups, e.g. a device mapper target layered on top of ZFS, with the
ZFS pool itself being backed by another device mapper target. To properly
untangle this, the dm-shutdown script should close the top-layered
device mapper target, next a zfs-shutdown script will export the zpool,
and finally another invocation of the dm-shutdown script will close
the bottom-layered device mapper target.

For this to work, the exit status of "dmsetup remove_all" must be
non-zero on failure, otherwise the dm-shutdown script cannot determine
whether it's work is done.

Therefore, please consider merging this patch.

Kind regards,

Lukas


