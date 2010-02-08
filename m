From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 8 Feb 2010 08:46:05 -0500
Subject: Suppress locking initialisation failure messages when --ignorelockingfailure is used
In-Reply-To: <4B701284.1030606@redhat.com>
References: <4B700EDC.7020505@redhat.com>
 <4B701284.1030606@redhat.com>
Message-ID: <20100208134605.GA16433@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 08 2010 at  8:32am -0500,
Milan Broz <mbroz@redhat.com> wrote:

> 
> On 02/08/2010 02:17 PM, Peter Rajnoha wrote:
> > We should not show error messages about locking initialisation failures when it is expected
> > and --ignorelockingfailure option is used (rhbz #561938).
> 
> > 
> > diff --git a/lib/locking/locking.c b/lib/locking/locking.c
> > index 54e5e25..db70433 100644
> > --- a/lib/locking/locking.c
> > +++ b/lib/locking/locking.c
> > @@ -237,7 +237,8 @@ int init_locking(int type, struct cmd_context *cmd)
> >  				 _blocking_supported ? "" : "Non-blocking ");
> >  
> >  		if (!init_file_locking(&_locking, cmd)) {
> > -			log_error("File-based locking initialisation failed.");
> > +			if (!ignorelockingfailure())
> > +				log_error("File-based locking initialisation failed.");
> 
> I do not like this patch at all.
> 
> "Ignore locking failure" does not mean "Do not print error when locking failed" IMHO.
> 
> I thought that dracut use rw root. So something changed again and
> remounts it to read-only again?

Dracut is rw but we (dracut's lvm hooks) impose read-only locking
through dracut's lvm.conf.  This was done so no metadata updates could
occur within the initramfs environment.

Mike


