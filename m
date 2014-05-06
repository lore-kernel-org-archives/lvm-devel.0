From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 06 May 2014 09:54:19 +0200
Subject: [PATCH] Better clean-up of pvmove failures in a cluster
In-Reply-To: <1399325884.1503.5.camel@f16>
References: <1399325884.1503.5.camel@f16>
Message-ID: <5368952B.6040404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 5.5.2014 23:38, Jonathan Brassow napsal(a):
> Hi,
>
> I don't see any reason why the following patch would be bad, but I'd
> like to hear from others first.  In essence, I'm just trying to improve
> the error code path.  This seems to improve things for pvmove when a
> node in the cluster is not running 'cmirrord' as it should.  However, it
> doesn't clean everything up when attempting to create a full cluster
> mirror LV.  So there might still be some work left after this.

I've already tried to add some initial recovery support for error path.

If you take a look into the upstream libdm-deptee code - there is already
dnode->activated  list for recovery path - which track just newly introduced
devices.

The problem is however much more complicated - it should work as transaction,
since multiple device may get changed - and all changes should be
reverted properly.

>
>   brassow
>
> activation:  Remove empty DM devices when table fails to load.

There is postprocessing routine which should cleanup any left
empty entries in the table.

I'm currently working on more generic solution.

Zdenek


