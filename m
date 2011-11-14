From: James Le Cuirot <chewi@aura-online.co.uk>
Date: Mon, 14 Nov 2011 00:53:31 +0000
Subject: Fixing other lvm2create_initrd issues
Message-ID: <20111114005331.70e86028@symphony.aura-online.co.uk>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

Thank you for accepting my previous patch that fixed the path to
MAKEDEV on Gentoo. I had hoped that the script would then simply work
but I have since found many more issues. I hadn't noticed that Gentoo
already patches for a couple of them.

 - /sys is not mounted. This has probably been required for ages. Does
   anyone still use this script!?

 - Gentoo can be configured to install a static version of lvm as
   lvm.static. This is preferred over the dynamic version. cpio copies
   files with exactly the same path so a symlink is also created called
   lvm. Obviously this is Gentoo-specific but it's only two extra
   lines. :)

There were more issues besides these two.

 - In the "debian" case, /dev/MAKEDEV is now simply a symlink
   to /bin/true. You can install the makedev package though and the
   same script is now located at /sbin/MAKEDEV.

 - In the "gentoo" case, MAKEDEV is called without the -d option. This
   causes nodes to created in /dev instead.

 - In the "redhat" case, $BASICDEVICES $BLOCKDEVICES aren't given as
   arguments even though it allows you to specify them. In fact, the
   command fails if you don't.

 - The RedHat/Gentoo MAKEDEV is naive in that if you specify sda, not
   only will it create sda1 through to sda15 but it will also create
   sdaa1 through to sdaz15. That's a LOT of extra nodes. This is not
   this script's fault and it's not a problem in itself but it does
   contribute towards the inode problem below.

 - Neither MAKEDEV knows how to create vdx nodes. This makes it
   somewhat useless for virtualized environments. Again, this is not
   this script's fault but it is an important point and I suspect we
   will never see another release of MAKEDEV.

 - In the "redhat" case, the option -m 2 is given. This would render
   the script useless in the majority of cases. Users are advised to
   make their volume groups span several partitions and many will use
   extended partitions starting at 6 rather than 1. I suspect the
   reason this was added was because of the inode problem below.

 - Even with almost all of the above fixed, the script still fails,
   complaining that there is no space left on the device. This stumped
   me for a while because there clearly was space but eventually I
   realised it was due to the filesystem running out of inodes. On
   Gentoo, with the default options, around 2200 nodes are created as
   well as around 300 symlinks for BusyBox. Only around 1900 inodes
   were being allocated. I don't fully understand the implications and
   I don't know what the definition is for the maximum number of inodes
   on a given device but you can pass the -N option to mke2fs to
   request a specific number. Under the current setup, we can't
   determine the number of inodes required in advance but 3000 seems
   sufficient.

Obviously this script hasn't seen a lot of love lately. I'm guessing
this is due to the existence of Debian's initramfs-tools and Fedora's
mkinitrd. Gentoo has genkernel but it seems most users don't bother
with an initrd at all or cook up their own script instead. I think it
is important to have a distribution-agnostic script that does the bare
minimum so I have taken the time to fix almost all of the above.

However, I had to consider whether trying to fix MAKEDEV was the right
approach given that it has been practically abandoned since udev has
become firmly established. While looking into the possibility of
putting udev on the initrd, I stumbled across devtmpfs. This has been
around since 2.6.32 but had somehow escaped my attention until now. If
you enable the option to automatically mount it then you can simply
skip the whole MAKEDEV mess altogether and everything just works. I
could add a "--makedev devtmpfs" option or we could just ditch the
MAKEDEV code entirely. Given that this script seems to be used very
little these days, I think there would be little harm in requiring
2.6.32 as a minimum. Failing that, there's also BusyBox's mdev. What
do you think?

Also, was there any particular reason for copying Bash across? I think
BusyBox's shell is sufficient to execute the init script?

Regards,
James


