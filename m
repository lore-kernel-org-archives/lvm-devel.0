From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 11 Dec 2008 22:39:35 -0500
Subject: [PATCH] Renamed create_toolcontext function to _create_context and added sys_dir as argument, new functions create_librarycontext and create_toolcontext.
In-Reply-To: <20081212010433.GT24785@agk.fab.redhat.com>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
	<1229013822-10809-2-git-send-email-twoerner@redhat.com>
	<20081212010433.GT24785@agk.fab.redhat.com>
Message-ID: <1229053175.20795.49.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Fri, 2008-12-12 at 01:04 +0000, Alasdair G Kergon wrote:
> > +/* Library Entry point */
> > +struct cmd_context *create_librarycontext(const char *sys_dir)
> > +{
> > +	return _create_context(NULL, 0, 1, sys_dir);
> > +}
> 
> > +/* Tool Entry point */
> > +struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
> > +				       unsigned is_long_lived)
> > +{
> > +	return _create_context(the_args, is_static, is_long_lived, NULL);
> > +}
> 
> Please don't separate these.  All tools will use the same library interface -
> there is to be nothing privileged about the existing tools in the tools dir or
> anaconda - they will both share the same interface.  So work out where those
> parameters should live.
> 

If we don't separate tool from library init, then we make generic
callers of the library incur the penalty for the tools (e.g. explicitly
setting args = NULL, etc).  Or is there an alternative?

Going with the object theme, and along the lines of what Thomas (and
maybe others) have suggested for pvcreate, perhaps a 'struct
lvm_lib_obj' that gets created with default values (such as args ==
NULL) and you have to explicitly set what you want before passing in the
lib_config object to create_toolcontext?  Passing NULL there of course
gives you default values as well.  Would that be a more acceptable
direction?


