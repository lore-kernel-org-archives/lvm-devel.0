From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 25 Jun 2010 07:29:25 -0400
Subject: lvm2app library question about attributes and policies
In-Reply-To: <201006241539.57382.benscott@nwlink.com>
References: <201006241539.57382.benscott@nwlink.com>
Message-ID: <1277465365.2472.3.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2010-06-24 at 15:39 -0700, ben scott wrote:
> Looking at lvm2app.h I  don't see anything about attributes such as resizable 
> or read only. I also didn't see anything about allocation policy like anywhere 
> or contiguous. 
> 
> Is there any plan to add these. Thank you.
> 

Yes.  I have on my TODO list to resubmit a generic attribute patchset,
which should provide access to any field in pvs/vgs/lvs.


