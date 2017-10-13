From: David Teigland <teigland@redhat.com>
Date: Fri, 13 Oct 2017 10:32:55 -0500
Subject: [RFC] lvmetad_is_disabled: check config before connecting to socket
In-Reply-To: <20171013090842.28186-1-t.lamprecht@proxmox.com>
References: <20171013090842.28186-1-t.lamprecht@proxmox.com>
Message-ID: <20171013153255.GA3940@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 13, 2017 at 11:08:42AM +0200, Thomas Lamprecht wrote:
> Else, lvmetad always gets started due to systemds socket auto
> activation when executing, for example:
>  # pvscan --cache
> as pvscan uses lvmetad_is_disabled to check if metad is disabled
> before connecting. 

> An alternative approach would be to just guard the lvmetad_is_disabled
> call in tools/pvscan.c : 412 with the config check - and thus address
> the FIXME mentioned there.
> Would be maybe the less intrusive version?

When lvm.conf has use_lvmetad=0, 'pvscan --cache' should not try to
connect to lvmetad, it should return here:

https://sourceware.org/git/?p=lvm2.git;a=blob;f=tools/pvscan.c;h=6581990f8afeb17f4c7f82c6f6b59fe2ed0b990b;hb=HEAD#l323

so I'm not sure it would get to line 412.

This was a little complicated to get working just right in every case, so
I wouldn't be surprised if it's still off somewhere.  There may be some
place where we should call lvmetad_used() prior to calling
lvmetad_is_disabled.  I'm not seeing in your message where exactly
lvmetad_is_disabled is being called for you.

Dave


