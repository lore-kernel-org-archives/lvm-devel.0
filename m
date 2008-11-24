From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 23 Nov 2008 22:59:42 -0500
Subject: [PATCH] (6/11) re-introduce vg_read
In-Reply-To: <87abcm3qi3.fsf@eriador.mornfall.net>
References: <87abcm3qi3.fsf@eriador.mornfall.net>
Message-ID: <1227499182.6608.20.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-10-30 at 19:08 +0100, Petr Rockai wrote:
> Hi,
> 
> this patch gets us back a function called vg_read, but this time it
> also does
> locking -- by default it grabs a read lock, as vg_read_for_update
> should be
> used when write lock is desired.
> 
> Yours,
>    Petr.
> 

It is a little confusing have a vg_read_for_update() (only intended for
WRITE) and a generic vg_read() (that allows both READ/WRITE) in the same
API.  Should we have "vg_read_for_update()" (WRITE) and
vg_read_for_query()" (READ) or something like that?


