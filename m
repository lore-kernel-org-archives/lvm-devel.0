From: David Teigland <teigland@redhat.com>
Date: Fri, 29 Sep 2017 08:42:44 -0500
Subject: lvmlockd: "lvm_global" lockspace cannot be closed normally
In-Reply-To: <31b56a90-9c21-6b7c-881b-1fa04741885d@suse.com>
References: <31b56a90-9c21-6b7c-881b-1fa04741885d@suse.com>
Message-ID: <20170929134244.GA12617@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Sep 29, 2017 at 08:57:57PM +0800, Eric Ren wrote:
> Hi David,
> 
> I encountered this problem pretty often when I play with lvmlockd.
> "lvm_global" will stay on the system. It can be closed if using `dlm_tool
> leave lvm_global`.
> But, the dlm_tool command will hang there.

Currently the best way to handle this is to run 'lvmlockctl -S' which
stops all dlm lockspaces that lvm isn't using.  It's effectively the same
as 'vgchange --lockstop', but won't miss the global lockspace.

IIRC the vgchange issue is that stopping the global lockspace is an effect
of stopping the last VG lockspace, but sometimes vgchange finds no VGs to
stop.  I'll have another look at making vgchange --lockstop do it right.

Dave


