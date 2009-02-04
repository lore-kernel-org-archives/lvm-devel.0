From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 04 Feb 2009 09:57:51 -0500
Subject: [PATCH 03/13] Move vg_t, lv_t, and pv_t from metadata-exported.h into lvm2.h
In-Reply-To: <87ljso776x.fsf@eriador.mornfall.net>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<87ljso776x.fsf@eriador.mornfall.net>
Message-ID: <1233759472.4048.16.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Tue, 2009-02-03 at 00:25 +0100, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> > ---
> >  lib/lvm2.h                       |    9 +++++++++
> >  lib/metadata/metadata-exported.h |    8 +-------
> >  2 files changed, 10 insertions(+), 7 deletions(-)
> >
> > diff --git a/lib/lvm2.h b/lib/lvm2.h
> > index f348035..bfa1852 100644
> > --- a/lib/lvm2.h
> > +++ b/lib/lvm2.h
> > @@ -60,4 +60,13 @@ void lvm_destroy(lvm_handle_t libh);
> >   */
> >  int lvm_reload_config(lvm_handle_t libh);
> >  
> > +struct volume_group;
> > +typedef struct volume_group vg_t;
> > +
> > +struct physical_volume;
> > +typedef struct physical_volume pv_t;
> > +
> > +struct logical_volume;
> > +typedef struct logical_volume lv_t;
> Did you mean to make all of those pointers? Or is the plan to expose the actual
> structures instead of just handles? (I don't know, I'm just asking.)
> 
> I see you use vg_t * later on. Maybe thats' because we want to make the fact
> that these are pointers explicit? Just thinking aloud...
> 

The plan is not to expose the structs, just needed to declare the
handles.


