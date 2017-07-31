From: Bryn M. Reeves <bmr@redhat.com>
Date: Mon, 31 Jul 2017 13:16:42 +0100
Subject: Batch/queue LVM operations
In-Reply-To: <32ff399c-7a79-5beb-abd5-d5dbad1486db@redhat.com>
References: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
	<32ff399c-7a79-5beb-abd5-d5dbad1486db@redhat.com>
Message-ID: <20170731121641.GA22625@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jul 28, 2017 at 09:43:50PM +0200, Zdenek Kabelac wrote:
> Dne 28.7.2017 v 21:22 Eric Wheeler napsal(a):
> > Hello,
> > 
> > Is there an option to batch LVM operations?
> > 
> > For example, I would like to delete 100 thin snapshots without updating
> > the vgmeta 100 times.
> 
> You could possibly use --select feature to handle all removals with
> just one lvremove command.

Couldn't you also feed a sequence of commands to the lvm shell ('lvm')?

Iiirc that also does (or did) some caching of state between subsequent
invocations in the same shell?

Regards,
Bryn.
 


