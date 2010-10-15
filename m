From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 15 Oct 2010 10:18:49 -0400
Subject: [PATCH 11/14] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <877hhnwu0b.fsf@twilight.int.mornfall.net.>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-12-git-send-email-dwysocha@redhat.com>
	<4CB41EF8.9010706@redhat.com>
	<877hhnwu0b.fsf@twilight.int.mornfall.net.>
Message-ID: <1287152329.27666.2.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2010-10-12 at 13:05 +0200, Petr Rockai wrote:
> Zdenek Kabelac <zkabelac@redhat.com> writes:
> >> +	struct lvm_property_type prop;
> >> +
> >> +	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
> >
> > Hmmm why doing a copy here instead of passing/assigning  'name' ptr somewhere?
> 
> Because lvm_property_type says: char id[LVM_PROPERTY_NAME_LEN];
> 
> Yours,
>    Petr.
> 

Thanks both of you for the feedback.  I am reworking this based on all
your comments and will re-post soon.


