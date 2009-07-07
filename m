From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 07 Jul 2009 09:11:54 -0400
Subject: [PATCH] Remove LOCK_KEEP and READ_CHECK_EXISTENCE from vgsplit.
In-Reply-To: <4A530EF2.9040705@redhat.com>
References: <1246940664-14890-1-git-send-email-dwysocha@redhat.com>
	<1246940664-14890-2-git-send-email-dwysocha@redhat.com>
	<4A530EF2.9040705@redhat.com>
Message-ID: <1246972314.2450.11.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2009-07-07 at 11:01 +0200, Milan Broz wrote:
> Dave Wysochanski wrote:
> > diff --git a/tools/vgsplit.c b/tools/vgsplit.c
> > index 9cd90b8..0dc5bc4 100644
> > --- a/tools/vgsplit.c
> > +++ b/tools/vgsplit.c
> > @@ -342,11 +342,12 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
> >  		existing_vg = 1;
> >  		vg_to = vg_read_for_update(cmd, vg_name_to, NULL,
> >  					   READ_REQUIRE_RESIZEABLE |
> > -					   LOCK_NONBLOCKING | LOCK_KEEP |
> > -					   READ_CHECK_EXISTENCE);
> > +					   LOCK_NONBLOCKING);
> >  
> > -		if (vg_read_error(vg_to))
> > -			goto_bad;
> > +		if (vg_read_error(vg_to)) {
> 
> 	but vg_name_to is locked by vg_lock_newname() previously?
> 	so unlock_and_release here?
> 

No - if vg_lock_newname() returns any failure code, it releases the
lock.  In this case it is FAILED_EXIST.


> 	also now code missing stack; (note goto_bad before)
> 

Right - good catch.


> > +			vg_release(vg_to);
> > +			goto bad2;
> > +		}
> >  
> 
> 
> Milan
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0001-Remove-LOCK_KEEP-and-READ_CHECK_EXISTENCE-from-vgspl.patch
Type: text/x-patch
Size: 1676 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090707/261d7dbd/attachment.bin>
