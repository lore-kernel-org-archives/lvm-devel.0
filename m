From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 25 Feb 2009 13:13:41 -0600
Subject: LVM2 Disk Layout (on-disk data-structures)
In-Reply-To: <1f8f1b050902120922m5f22835ew715cf0d093440646@mail.gmail.com>
References: <1f8f1b050902120922m5f22835ew715cf0d093440646@mail.gmail.com>
Message-ID: <B0342446-3DF3-49BB-99B0-324DE09A6FED@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It is text based.  You can see examples in /etc/lvm/archive or /etc/ 
lvm/backup.

  brassow

On Feb 12, 2009, at 11:22 AM, David A. Barrett wrote:

> Does anyone know about where I can find
> documentation of layout of information for
> LVM2 on the disk?
>
> I need to write code to parse the data
> directly from the low-level disc image.
>
> I need to do some data recovery operations
> on multiple logical volumes in two volume groups
> on two physical volumes (each a raid5).
>
> Redhat's fedora 10 installation DVD overwrote
> the partition table and a new lvm on every single
> accessable device immediately after asking for
> my keyboard type (without confirmation).
>
> d dot barrett at asgard dot com.
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


