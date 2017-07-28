From: Eric Wheeler <lvm-devel@lists.ewheeler.net>
Date: Fri, 28 Jul 2017 19:22:33 +0000 (UTC)
Subject: Batch/queue LVM operations
Message-ID: <alpine.LRH.2.11.1707281919050.9683@mail.ewheeler.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

Is there an option to batch LVM operations?  

For example, I would like to delete 100 thin snapshots without updating 
the vgmeta 100 times.

Same thing with lvcreate, lvresize, etc.  

If would be neat if `lvm`'s readline prompt could take multiple commands 
via stdin and commit them once, even at the expense of longer lock times.

Is there already support for this in some form?


--
Eric Wheeler


