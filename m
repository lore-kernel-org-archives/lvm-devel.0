From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 17 Feb 2010 11:26:51 -0500
Subject: Hide merging snapshots from "lvs" command.
In-Reply-To: <87ocjnzwqk.fsf@twilight.int.mornfall.net.>
References: <1254432375-5880-1-git-send-email-snitzer@redhat.com>
	<87ocjnzwqk.fsf@twilight.int.mornfall.net.>
Message-ID: <20100217162650.GA23563@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 17 2010 at 10:51am -0500,
Petr Rockai <prockai@redhat.com> wrote:

> Hi,
> 
> Mike Snitzer <snitzer@redhat.com> writes:
> > Hide merging snapshots from "lvs" command. The prefix "snapshot" is reserved
> > and names with this prefix cannot be created by the user, so this change is
> > safe.
> >
> > Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> > Reviewed-by: Mike Snitzer <snitzer@redhat.com>
> >
> > ---
> >  tools/toollib.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > Index: lvm2/tools/toollib.c
> > ===================================================================
> > --- lvm2.orig/tools/toollib.c
> > +++ lvm2/tools/toollib.c
> > @@ -119,7 +119,8 @@ int process_each_lv_in_vg(struct cmd_con
> >  	}
> >  
> >  	dm_list_iterate_items(lvl, &vg->lvs) {
> > -		if (lvl->lv->status & SNAPSHOT)
> > +		/* Names starting with "snapshot" are reserved */
> > +		if (!strncmp(lvl->lv->name, "snapshot", strlen("snapshot")))
> >  			continue;
> >  
> >  		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))
> 
> This seems to have fallen through the cracks. Please check in if still
> relevant (the patch is not present in current CVS as far as I can tell).

It isn't needed, I eliminated the rename of the merging snapshot LV name
to 'snapshotX' as it proved unnecessary/undesirable.

The merging snapshot is hidden (!lv_is_visible()); lvs -a will display
it though:

# lvconvert -b --merge test/testlv1_snap
  Merging of volume testlv1_snap started.
# lvs
  LV      VG   Attr   LSize Origin Snap%  Move Log Copy%  Convert
  testlv1 test Owi-a- 4.00g         13.37                        
# lvs -a
  LV             VG   Attr   LSize Origin  Snap%  Move Log Copy%
  Convert
  testlv1        test Owi-a- 4.00g          10.59                        
  [testlv1_snap] test Swi--- 1.00g testlv1                               

Thanks for following up though!

Mike


