From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 02 Dec 2014 22:12:29 +0100
Subject: [PATCH] dmsetup: Set exit code to 1 if remove_all fails to remove all devices
In-Reply-To: <20141202210045.GA8939@wunner.de>
References: <20141202175825.GA8489@wunner.de> <547E0FF0.70605@redhat.com>
	<20141202210045.GA8939@wunner.de>
Message-ID: <547E2B3D.9050200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 2.12.2014 v 22:00 Lukas Wunner napsal(a):
> Hi,
>
> On Tue, Dec 02, 2014 at 08:16:00PM +0100, Zdenek Kabelac wrote:
>> It really is meant to remove only not opened devices.
>
> Sorry but that's not the point.
>
> The interpretation of a program's exit status by the Shell is inverse
> to the semantics in C. An exit status of 0 denotes success, a non-zero
> exit status denotes failure.
>

remove_all - means to remove all CLOSED (unused) devices.

It should return 'fail' if there is failure during command execution
(i.e. mem alloc fail)  - but it will not report error if there
are left devices.

> The point is that, as evidenced by the dracut shutdown script I mentioned,
> people expect the exit status of "dmsetup remove_all" to be non-zero if
> the program failed to remove all devices. It's perfectly okay if it failed
> to remove all devices. No need to remove devices that are still open.
>
> But the program should *tell* the user that some devices could not be
> closed (at the very least by returning with a non-zero exit status).
>
> Right now the exit status of "dmsetup remove_all" is always 0, thus
> pretending success.

Exit status of current dmsetup is OK and it's matching documented behaviour. 
If you want a different one - write a wrapper script - just don't propose to 
break existing valid and expected behaviour because of some script.

> As for the dracut shutdown script allegedly being broken: That script
> was written by Harald Hoyer who works for the same company as you do
> and is shipped with RHEL as well as Fedora. Just saying...

So please open BZ if you think there is one for dracut package.
I'm sure it will be properly resolved.

I'm just 100% sure that usage of 'remove_all' is not a generally usable
feature - it's purely mean for developers to help then cleanup
dm tables - it's not meant to be used by  'scripts' to cleanup user devices 
and return errors if there are some device left - it's plain miss-use.


> To provide some context: Dracut has a number of shutdown scripts that
> are called round-robin until all succeed. This is useful for complex
> LVM setups, e.g. a device mapper target layered on top of ZFS, with the
> ZFS pool itself being backed by another device mapper target. To properly
> untangle this, the dm-shutdown script should close the top-layered
> device mapper target, next a zfs-shutdown script will export the zpool,
> and finally another invocation of the dm-shutdown script will close
> the bottom-layered device mapper target.
>

lvm2 provides   blkdeactive.sh script to take down LVs.


> For this to work, the exit status of "dmsetup remove_all" must be
> non-zero on failure, otherwise the dm-shutdown script cannot determine
> whether it's work is done.

Nope - as said 'dmsetup' years stable API will not change because of dracut 
script -  fix the script and detect there are still devices in table - it's 
one line fix in dracut script.


Regards

Zdenek


