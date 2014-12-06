From: Lukas Wunner <lukas@wunner.de>
Date: Sat, 6 Dec 2014 22:25:19 +0100
Subject: [PATCH] dmsetup: Set exit code to 1 if remove_all fails to remove all devices
In-Reply-To: <547E2B3D.9050200@redhat.com>
References: <20141202175825.GA8489@wunner.de> <547E0FF0.70605@redhat.com>
	<20141202210045.GA8939@wunner.de> <547E2B3D.9050200@redhat.com>
Message-ID: <20141206212519.GA11165@wunner.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

On Tue, Dec 02, 2014 at 10:12:29PM +0100, Zdenek Kabelac wrote:
> remove_all - means to remove all CLOSED (unused) devices.
> It should return 'fail' if there is failure during command execution
> (i.e. mem alloc fail)  - but it will not report error if there
> are left devices.

The blkdeactivate.sh script (which you've suggested) uses "dmsetup remove".

It turns out that "dmsetup remove" does fail with a non-zero exit status
if one tries to remove a device which is still in use. On the other hand,
as stated before "dmsetup remove_all" does *not* fail with a non-zero exit
status if it couldn't remove all devices.

So the behaviour of dmsetup is inconsistent. That precisely is fixed
by the proposed patch. I find it bewildering that you call this a
"valid and expected behaviour" even though it is inconsistent.

I went ahead and changed the dracut shutdown script to loop over all
devices and call "dmsetup remove" on each of them. When testing it
I discovered that calling "dmsetup remove" on an (unused) crypt device
causes the system to hang on shutdown. Perhaps the ioctl() is blocking?
Should crypt devices only be removed with cryptsetup, not with
"dmsetup remove"?

Kernel 3.14.15, LVM2 2.02.109


> I'm just 100% sure that usage of 'remove_all' is not a generally usable
> feature - it's purely mean for developers to help then cleanup
> dm tables - it's not meant to be used by  'scripts' to cleanup user devices
> and return errors if there are some device left - it's plain miss-use.

That is not documented in the manpage. The manpage merely says:
"Use with care!"

I propose that the manpage be amended so as to prevent others from
"miss-using" this command, as your colleague Harald Hoyer apparently
did.


Kind regards,

Lukas


