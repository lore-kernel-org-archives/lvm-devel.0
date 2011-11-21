From: James Le Cuirot <chewi@aura-online.co.uk>
Date: Mon, 21 Nov 2011 16:14:37 +0000
Subject: Fixing other lvm2create_initrd issues
In-Reply-To: <20111114005331.70e86028@symphony.aura-online.co.uk>
References: <20111114005331.70e86028@symphony.aura-online.co.uk>
Message-ID: <20111121161437.12f8eefa@symphony.aura-online.co.uk>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 14 Nov 2011 00:53:31 +0000
James Le Cuirot <chewi@aura-online.co.uk> wrote:

> Obviously this script hasn't seen a lot of love lately. I'm guessing
> this is due to the existence of Debian's initramfs-tools and Fedora's
> mkinitrd. Gentoo has genkernel but it seems most users don't bother
> with an initrd at all or cook up their own script instead. I think it
> is important to have a distribution-agnostic script that does the bare
> minimum so I have taken the time to fix almost all of the above.
> 
> However, I had to consider whether trying to fix MAKEDEV was the right
> approach given that it has been practically abandoned since udev has
> become firmly established. While looking into the possibility of
> putting udev on the initrd, I stumbled across devtmpfs. This has been
> around since 2.6.32 but had somehow escaped my attention until now. If
> you enable the option to automatically mount it then you can simply
> skip the whole MAKEDEV mess altogether and everything just works. I
> could add a "--makedev devtmpfs" option or we could just ditch the
> MAKEDEV code entirely. Given that this script seems to be used very
> little these days, I think there would be little harm in requiring
> 2.6.32 as a minimum. Failing that, there's also BusyBox's mdev. What
> do you think?

It looks like nobody cares? I'm leaning more towards BusyBox's mdev now
or perhaps some combination of the two. The MAKEDEV stuff would be
removed. Can I safely assume that if I do this work, you will accept the
patch?

James


