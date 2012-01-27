From: Stuart D Gathman <stuart@bmsi.com>
Date: Fri, 27 Jan 2012 12:51:41 -0500
Subject: [linux-lvm] New LVM2 release 2.02.89: Thinly-provisioned logical volumes
In-Reply-To: <20120127025701.GB16767@agk-dp.fab.redhat.com>
References: <20120127025701.GB16767@agk-dp.fab.redhat.com>
Message-ID: <4F22E42D.5050401@bmsi.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Long ago, Nostradamus foresaw that on 01/26/2012 09:57 PM, Alasdair G
Kergon would write:
> The basic idea
> --------------
> You create a logical volume known as the "thin pool" to hold the disk
> space you want to use inside your volume group.
>
> Then you create "thin" logical volumes which share the space in that pool.
>
> lvs and lvdisplay will tell you "how full" your pool is.
>
What is the purpose?  Does it allow snapshots that share space like in
Zumastor?  Do all the thin LVs start with a preconfigured image which
can then be modified?  (Can be done with snapshots - updating the
snapshots, but not the master, is efficient.  Presumably this way all
the snapshots can share space.)


