From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Nov 2013 16:11:18 +0100
Subject: more complex example_cmdlib.c ?
In-Reply-To: <52935E70.6060705@mglug.de>
References: <52935E70.6060705@mglug.de>
Message-ID: <52936896.8040905@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.11.2013 15:28, Oliver Rath napsal(a):
> Hi list,
>
> Im looking for examples using lvm in c (or c++) Code. I realized, that
> there is a really terse example in lvm/doc/example_cmdlib.c.
>
> Is it possible to include a more complex example for doing the
> lvm2-tasks like vgcreate, lvcreate incl. using thinpools, making thin
> snaps etc. ?
>
> Btw, this would be useful for the python-example, too.
>
>

Maybe look at  test subdir  - there  are some API tests and
also some python scripts which are trying to exercise some
supported pieces.

NOTE: this API is being seen as experimental - so it's quite away for having 
the same usability as a native lvm2 command line.

Zdenek



