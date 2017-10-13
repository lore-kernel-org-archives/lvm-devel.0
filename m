From: David Teigland <teigland@redhat.com>
Date: Fri, 13 Oct 2017 10:39:38 -0500
Subject: [RFC] lvmetad_is_disabled: check config before connecting to socket
In-Reply-To: <0db6e3d2-4255-297f-46e0-72e729ee5da7@redhat.com>
References: <20171013090842.28186-1-t.lamprecht@proxmox.com>
	<0db6e3d2-4255-297f-46e0-72e729ee5da7@redhat.com>
Message-ID: <20171013153938.GB3940@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 13, 2017 at 12:06:49PM +0200, Zdenek Kabelac wrote:

> The reason why is checked the presence for active service when lvmetad is
> disable is - we have to print warning that  lvmetad is there, but command is
> not going to use it/update it....

That happens here:

https://sourceware.org/git/?p=lvm2.git;a=blob;f=lib/commands/toolcontext.c;h=39b300a78bbceda9f5092604be54e04f6f457584;hb=HEAD#l1706

and does not involve connecting to lvmetad.

Dave


