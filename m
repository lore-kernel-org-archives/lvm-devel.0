From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 23 Feb 2010 13:21:39 -0500
Subject: [PATCH 6/8] Add lvm_vg_get_tags(), lvm_vg_add_tag(), and lvm_vg_remove_tag().
In-Reply-To: <4B7D02C9.3000307@redhat.com>
References: <1266427744-30327-1-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-2-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-3-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-4-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-5-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-6-git-send-email-dwysocha@redhat.com>
	<1266427744-30327-7-git-send-email-dwysocha@redhat.com>
	<4B7D02C9.3000307@redhat.com>
Message-ID: <1266949299.2496.4.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2010-02-18 at 10:05 +0100, Zdenek Kabelac wrote:
> > @@ -159,10 +159,10 @@ typedef struct lvm_pv_list {
> >   * Lists of these structures are returned by lvm_list_vg_names and
> >   * lvm_list_vg_uuids.
> >   */
> > -struct lvm_str_list {
> > +typedef struct lvm_str_list {
> >  	struct dm_list list;
> >  	const char *str;
> > -};
> > +} lvm_str_list_t;
> >
> 
> 
> Looks quite similar to 'struct str_list' from lib/datastruct/lvm-types.h ?
> Are we going to replace old one with new version ?
> 

As per some IRC conversations, at this point I think we need to
duplicate the structures.  In the future we may change to some other
scheme for handling strings but for now this is it.  The lvm_str_list
has been in lvm2app.h for a while now and other functions use it.


> >  /**
> > + * Add/remove a tag to/from a VG.
> > + *
> > + * These functions require calling lvm_vg_write to commit the change to disk.
> > + * After successfully adding/removing a tag, use lvm_vg_write to commit the
> > + * new VG to disk.  Upon failure, retry the operation or release the VG handle
> > + * with lvm_vg_close.
> > + *
> > + * \param   vg
> > + * VG handle obtained from lvm_vg_create or lvm_vg_open.
> > + *
> > + * \param   tag
> > + * Tag to add/remove to/from VG.
> > + *
> > + * \return
> > + * 0 (success) or -1 (failure).
> > + */
> > +int lvm_vg_add_tag(vg_t vg, const char *tag);
> > +int lvm_vg_remove_tag(vg_t vg, const char *tag);
> 
> I assume doxygen will generate comment only for the lvm_vg_add_tag()
> and lvm_vg_remove_tag() would be without any comment ?
> 

Actually doxygen handles this strangely so I'm fixing this as well as a
lot of the other doxygen tags as a result of the documentation updates.
Another patch will be soon coming.


Thanks for the feedback.


