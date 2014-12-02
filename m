From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 02 Dec 2014 20:16:00 +0100
Subject: [PATCH] dmsetup: Set exit code to 1 if remove_all fails to remove all devices
In-Reply-To: <20141202175825.GA8489@wunner.de>
References: <20141202175825.GA8489@wunner.de>
Message-ID: <547E0FF0.70605@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 2.12.2014 v 18:58 Lukas Wunner napsal(a):
> There are scripts out there which expect "dmsetup remove_all" to
> not exit with 0 if some devices couldn't be removed, e.g. dracut:
> https://git.kernel.org/cgit/boot/dracut/dracut.git/tree/modules.d/90dm/dm-shutdown.sh
>
> Up until now the exit code of "dmsetup remove_all" is only non-zero
> if the call to ioctl() fails, causing _do_dm_ioctl() to return NULL
> instead of a struct dm_ioctl*.
>

 From man page:
--

Attempts  to  remove all device definitions i.e. reset the driver.  This also 
runs mknodes afterwards.  Use with care!  Open devices cannot be removed, but 
adding --force will replace the table with one that fails all I/O. --deferred 
will enable  deferred  removal of  open devices - the device will be removed 
when the last user closes it.  The deferred removal feature is supported since 
version 4.27.0 of the device-mapper driver available in upstream kernel 
version 3.13.

--

It really is meant to remove only not opened devices.

 > 
https://git.kernel.org/cgit/boot/dracut/dracut.git/tree/modules.d/90dm/dm-shutdown.sh

I'm afraid you need that script.

Moreover  'remove_all' is rather 'developer's' feature - it should never be be 
used 'randomly'  by a script.

So IMHO if some public script tries to use it - the script is IMHO broken.
You really are not supposed to randomly turn off device - only if you really 
know what you are doing (it's very similar to put in there  rm -rf....)

Zdenek


