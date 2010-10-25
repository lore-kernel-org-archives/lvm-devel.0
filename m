From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 12:23:19 +0100
Subject: [PATCH 16/30] Fix void* pointer arithmetic
In-Reply-To: <4CC56731.1070600@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<b27d551f464cef87fdbf52580c9b74607e500793.1287994530.git.zkabelac@redhat.com>
	<87fwvu60ai.wl%ejt@redhat.com> <4CC56731.1070600@redhat.com>
Message-ID: <87r5fe4iu0.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 13:17:05 +0200,
Zdenek Kabelac wrote:
> 
> Dne 25.10.2010 12:20, ejt at redhat.com napsal(a):
> > At Mon, 25 Oct 2010 10:24:23 +0200,
> > Zdenek Kabelac wrote:
> >>
> >>
> >> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> > 
> > Nack.  No explanation.  eg, Are we deprecating the void pointer arithmetic gcc extension?
> 
> void* arithmetic is IMHO bad practice and we should avoid it's usage.
> char* clearly defines 1byte - I'd prefer to use standard C whenever we can.
> (And gcc can show this as warning - so why not fixing it)

Ack


