From: Bryn M. Reeves <bmr@redhat.com>
Date: Wed, 25 Feb 2009 19:23:44 +0000
Subject: LVM2 Disk Layout (on-disk data-structures)
In-Reply-To: <1f8f1b050902120922m5f22835ew715cf0d093440646@mail.gmail.com>
References: <1f8f1b050902120922m5f22835ew715cf0d093440646@mail.gmail.com>
Message-ID: <49A59AC0.5080305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

David A. Barrett wrote:
> Does anyone know about where I can find documentation of layout of 
> information for LVM2 on the disk?
> 
> I need to write code to parse the data directly from the low-level 
> disc image.

There are better ways to do this. As Jon points out, the LVM2 metadata
is plain text. You can rip it out of the raw devices with dd if
necessary and then tidy it up in an editor.

You'll then want to look into vgcfgrestore.

If you didn't have a backup of your partition tables then you may want
to look at parted's rescue command.

> Redhat's fedora 10 installation DVD overwrote the partition table 
> and a new lvm on every single accessable device immediately after 
> asking for my keyboard type (without confirmation).

I'd file a bug if you can reproduce this.

Regards,
Bryn.


