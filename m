From: txemi <txemitron@gmail.com>
Date: Fri, 1 Mar 2013 13:53:25 +0100
Subject: "N.B. The moving of mirrors, snapshots and their origins is not yet supported"
Message-ID: <CAKQoJUZFa4JPBxWcLAeST+YNGyTbZCiQT+MJqYvw0oiEF0-StA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi, I found this on pvmove manual:

"N.B. The moving of mirrors, snapshots and their origins is not yet supported"

I am interested in this because of a situation I need to manage. I
have not found information on this, last comments on internet were
ancient (2006) and did not find any ticket on bug tracking system
about it to track. Neither did I find a workaround to achieve this.
Even if I rebuild mirror with lvchange I cannot choose pvs manually.

The problem I am trying to afford:

I have a volume group with five disks. Some data is important so I use
a mirrored lv for it. I also have a lv to store backups of this
important data. Actually lvm choosed same pv for bakcup lv and one of
the mirror pvs. I would prefer mirror using different pvs than backups
as everything is related to the same data I want to protect, using
three pvs in total. I prefer moving mirror than backups because used
pv is very big and suitable for historic backups. I thought It would
be easy to move away mirror from this pv using pvmove but I found it
is not supported since long ago and I did not find news about it.

Thanks,
txemi.


