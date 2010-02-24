From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 24 Feb 2010 09:02:58 -0500
Subject: [PATCH 1/2] Always query device by uuid only.
In-Reply-To: <4B8521A7.6090803@redhat.com>
References: <1266932816-5621-1-git-send-email-mbroz@redhat.com>
	<20100223203902.GA31973@redhat.com> <4B8511AB.3080305@redhat.com>
	<4B8513D9.5060107@redhat.com> <4B8521A7.6090803@redhat.com>
Message-ID: <20100224140258.GC4219@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 24 2010 at  7:55am -0500,
Milan Broz <mbroz@redhat.com> wrote:

> 
> > sigh. Either I am idiot or split of mknodes and info dm calls
> > in _info_run is confusing (or both).
> >
> >   
> I would prefer something like this (on top of my previous 2 patches):
> 
> Separate mknodes to dev_manager_mknodes function.
> 
> All info calls uses now uuid only.
> 
> Remove confusing with_mknodes paramater.
> 
> Move all nodes handling logic inside dev_manager.

Cleans things up nicely, thanks.

Acked-by: Mike Snitzer <snitzer@redhat.com>


