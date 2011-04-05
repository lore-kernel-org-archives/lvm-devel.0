From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 5 Apr 2011 11:56:28 -0400
Subject: snapshot in shared disk environment
In-Reply-To: <4D9AED98.1080900@ce.jp.nec.com>
References: <4D9AED98.1080900@ce.jp.nec.com>
Message-ID: <20110405155628.GC20046@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 05 2011 at  6:23am -0400,
Jun'ichi Nomura <j-nomura@ce.jp.nec.com> wrote:

> Hi,
> 
> Is it possible or is there on-going work to use snapshot in shared disk
> environment?
> 
> 
> In virtualization context, snapshotting is useful for quickly
> creating a guest image from a template disk image.
> (Fast creation and space efficiency with a cost of runtime performance)
> 
> LVM snapshot can be used for such a purpose, but there is a problem
> if we are in shared disk environment:
>   a) Clustered snapshot is not yet supported.
>   b) Origin and snapshots are activated/deactivated as a whole set.
>      We can't individually activate/deactivate different snapshots on
>      different nodes.
> 
> a) might be ok.
> A snapshot is accessed on a host at a time, not simultaneously on multiple
> hosts. Also the origin is read-only.
> So snapshot itself need not be cluster aware, I think.
> If there are thousands of nodes sharing the disk, but only one of them
> accesses the snapshot, clustered snapshot seems overkill.
> 
> I wonder whether we could relax the restriction in b) and allow individual
> activation of snapshots.
> Then, we can use snapshots in shared disk environment without clustered
> snapshot support?

Jon Brassow has worked on exclussive activation that allows snapshots to
be activated on a specific machine.  Please see lvm2.git commit
1ce9f8621bce7baa815145b7de8bd3ffca14420a

Mike


