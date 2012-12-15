From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 15 Dec 2012 22:34:47 +0100
Subject: master - python-lvm: Make second lv.snapshot() argument optional
In-Reply-To: <20121214221108.E6D52137F@hosted02.fedoraproject.org>
References: <20121214221108.E6D52137F@hosted02.fedoraproject.org>
Message-ID: <50CCECF7.8000809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.12.2012 23:11, Andy Grover napsal(a):
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0958905b1bc0a59d34a4092377bae7c59f424181
> Commit:        0958905b1bc0a59d34a4092377bae7c59f424181
> Parent:        0e3093979e901384aecb22e08d83b5acb2ef12c1
> Author:        Andy Grover <agrover@redhat.com>
> AuthorDate:    Fri Dec 14 14:10:41 2012 -0800
> Committer:     Andy Grover <agrover@redhat.com>
> CommitterDate: Fri Dec 14 14:10:41 2012 -0800
>
> python-lvm: Make second lv.snapshot() argument optional
>
> If no size is given, size defaults to 0, which in lvm_lv_snapshot will
> allocate extents equal to the original LV be allocated for the new
> snapshot.
>


Possibly not the ideal solution here.

1) we have some clash with command line 'API'
    user creates snapshot of thin volume
       - without giving size he get thin volume snaphost.
         lvcreate -s
       - with size specified he gets 'old' snapshot
         (snapshot outside of the pool)
         lvcreate -s -l|-L

2) using same size of origin is not enough to cover
    i.e. full rewrite of origin device - you need some
    'extra' size to store snapshot's metadata (remapping blocks)

Zdenek


