From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 29 Oct 2010 16:56:23 -0400
Subject: Patch for fsadm bz 64146
In-Reply-To: <20101029204456.GB26687@redhat.com>
References: <4CCB2668.8020809@redhat.com> <20101029204456.GB26687@redhat.com>
Message-ID: <20101029205623.GD26687@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 29 2010 at  4:44pm -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Fri, Oct 29 2010 at  3:54pm -0400,
> Zdenek Kabelac <zkabelac@redhat.com> wrote:
> 
> > -	detect_mounted && error "Cannot fsck device \"$VOLUME\", filesystem is mounted on $MOUNTED"
> > +	if detect_mounted ; then
> > +		verbose "Skipping fsck device \"$VOLUME\" as filesystem is mounted on $MOUNTED";
> 
> I think the verbose message should be:
> "Skipping fsck for device \"$VOLUME\" as filesystem is mounted on $MOUNTED"

"for" could be replaced with "on" or "of" too. ;)

Mike


