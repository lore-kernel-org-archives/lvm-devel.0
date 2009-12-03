From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 3 Dec 2009 18:45:56 -0500
Subject: Re: Update a few more uint64_t's related to the 64-bit status change.
In-Reply-To: <1259882816-25310-1-git-send-email-dwysocha@redhat.com>
References: <1259882816-25310-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20091203234555.GA12543@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 03 2009 at  6:26pm -0500,
Dave Wysochanski <dwysocha@redhat.com> wrote:

> At this point they probably do not matter but going forward they
> may - depends on future patches for replicator, etc.  I think
> these probably got missed because they were 'flags' so I changed
> the name to 'status' to be consistent.  So the on-disk
> things 'flags' and the in structure 'status' (bits).
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Ah, thanks Dave!

Acked-by: Mike Snitzer <snitzer@redhat.com>


