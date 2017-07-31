From: Germano Percossi <germano.percossi@citrix.com>
Date: Mon, 31 Jul 2017 10:01:18 +0100
Subject: Batch/queue LVM operations
In-Reply-To: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
References: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
Message-ID: <fcfc34d4-eb7e-ce89-b83f-39d4fff56cbb@citrix.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Not sure if it an option for you but the Python bindings
allow you to instantiate a VG object that will hold the
lock and then issue all the commands you want before
flushing the metadata at the very end.

Cheers,
Germano

On 07/28/2017 08:22 PM, Eric Wheeler wrote:
> Hello,
> 
> Is there an option to batch LVM operations?  
> 
> For example, I would like to delete 100 thin snapshots without updating 
> the vgmeta 100 times.
> 
> Same thing with lvcreate, lvresize, etc.  
> 
> If would be neat if `lvm`'s readline prompt could take multiple commands 
> via stdin and commit them once, even at the expense of longer lock times.
> 
> Is there already support for this in some form?
> 
> 
> --
> Eric Wheeler
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 


