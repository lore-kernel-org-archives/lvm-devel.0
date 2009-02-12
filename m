From: David A. Barrett <david.barrett@asgard.com>
Date: Thu, 12 Feb 2009 12:22:44 -0500
Subject: LVM2 Disk Layout (on-disk data-structures)
Message-ID: <1f8f1b050902120922m5f22835ew715cf0d093440646@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Does anyone know about where I can find
documentation of layout of information for
LVM2 on the disk?

I need to write code to parse the data
directly from the low-level disc image.

I need to do some data recovery operations
on multiple logical volumes in two volume groups
on two physical volumes (each a raid5).

Redhat's fedora 10 installation DVD overwrote
the partition table and a new lvm on every single
accessable device immediately after asking for
my keyboard type (without confirmation).

d dot barrett at asgard dot com.


