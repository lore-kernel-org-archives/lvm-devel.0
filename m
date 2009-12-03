From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 03 Dec 2009 15:59:49 -0500
Subject: [PATCH] Print error if VG already exist.
In-Reply-To: <87r5rb24vm.fsf@twilight.int.mornfall.net.>
References: <1259850701-32101-1-git-send-email-mbroz@redhat.com>
	<87r5rb24vm.fsf@twilight.int.mornfall.net.>
Message-ID: <1259873989.2283.22.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2009-12-03 at 21:13 +0100, Petr Rockai wrote:
> Milan Broz <mbroz@redhat.com> writes:
> > This test have to be moved because of new vg read error handling.
> 
> > @@ -55,8 +55,13 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
> >  
> >  	/* Create the new VG */
> >  	vg = vg_create(cmd, vp_new.vg_name);
> > -	if (vg_read_error(vg))
> > -		goto_bad;
> > +	if (vg_read_error(vg)) {
> > +		if (vg_read_error(vg) == FAILED_EXIST)
> > +			log_error("A volume group called %s already exists.", vp_new.vg_name);
> > +		else
> > +			log_error("Can't get lock for %s", vp_new.vg_name);
> > +		goto bad;
> > +	}
> 
> This is suspicious. In vg_create:
> 
> 	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
> 		log_error("A volume group called '%s' already exists.", vg_name);
> 		unlock_and_release_vg(cmd, vg, vg_name);
> 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
> 	}
> 
> So the code you are adding should not be needed, at least not for the
> EXIST case.
> 
> Hmm. Ok, I see that the code is actually broken, since what fails is
> already vg_lock_newname. I'd argue that it should be vg_lock_newname
> that should be printing this, not vgcreate. Like this:
> 
> diff -u -p -r1.299 metadata.c
> --- lib/metadata/metadata.c	24 Nov 2009 22:55:56 -0000	1.299
> +++ lib/metadata/metadata.c	3 Dec 2009 20:11:56 -0000
> @@ -3507,6 +3507,7 @@ uint32_t vg_lock_newname(struct cmd_cont
>  
>  	/* Found vgname so cannot reserve. */
>  	unlock_vg(cmd, vgname);
> +	log_error("A volume group called '%s' already exists.", vg_name);
>  	return FAILED_EXIST;
>  }
> 

Unfortunately this will add extraneous messages / errors to some vgsplit
operations as a check for existence is not always a command error.  Plus
vg_lock_newname only returns codes in the other paths and it would be
good to stay consistent (log_error() in all error paths or none of them
and let caller decide).


