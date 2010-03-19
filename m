From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 19 Mar 2010 19:44:18 -0400
Subject: Don't allow resizing of internal logical volumes
In-Reply-To: <Pine.LNX.4.64.1003191823570.7833@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1003181950140.29893@hs20-bc2-1.build.redhat.com>
	<20100319200807.GC7345@redhat.com>
	<Pine.LNX.4.64.1003191823570.7833@hs20-bc2-1.build.redhat.com>
Message-ID: <20100319234417.GB31274@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Mar 19 2010 at  6:27pm -0400,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> 
> 
> On Fri, 19 Mar 2010, Mike Snitzer wrote:
> 
> > On Thu, Mar 18 2010 at  7:53pm -0400,
> > Mikulas Patocka <mpatocka@redhat.com> wrote:
> > > Don't allow resizing of internal logical volumes.
> > > 
> > > This patch prevents lvresize from being able to resize internal LVs: mirror
> > > legs (*_mimage_*), mirror log (*_mlog), snapshot placeholder LVs (snapshot*)
> > > and others. Resizing these would leads to unexpected metadata and sometimes
> > > crashes (in case of growing snapshot*).
> > > 
> > > Note that test for VISIBLE_LV is not sufficient because snapshot0 volumes
> > > have the VISIBLE_LV flag set. So we test the name instead of the flags.
> > 
> > OK, but snapshotX volumes are part of the LVM2 snapshot "fiction".  They
> > never get exposed to the end user (even with lvs -a).  Only the user
> > facing snapshot LV name gets exposed:
> > # lvs test/snapshot0
> >   One or more specified logical volume(s) not found.
> > # lvs test/testlv1_snap
> >   LV           VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
> >   testlv1_snap test swi-a- 4.00g testlv1                               
> > 
> > As such we shouldn't have to worry about the user attempting to resize
> > the hidden snapshotX volume.  Am I still missing something?
> 
> If you do lvresize vgs/snapshot0, it allows it. If you extend it, it 
> crashes. Try it. snapshotX isn't visible enen with "a", but for lvresize 
> it exists.

I didn't realize that, OK.

> > diff --git a/tools/lvresize.c b/tools/lvresize.c
> > index 849fd2e..f08be60 100644
> > --- a/tools/lvresize.c
> > +++ b/tools/lvresize.c
> > @@ -323,6 +323,11 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
> >  
> >  	lv = lvl->lv;
> >  
> > +	if (!lv_is_visible(lv) && !lv_is_accessible_hidden(lv)) {
> > +		log_error("Can't resize internal logical volume %s", lv->name);
> > +		return ECMD_FAILED;
> > +	}
> > +
> >  	if (lv->status & LOCKED) {
> >  		log_error("Can't resize locked LV %s", lv->name);
> >  		return ECMD_FAILED;
> > 
> 
> OK. It is cleaner than my patch that checks the name, so commit it (except 
> !lv_is_accessible_hidden(lv), because that has to wait until we commit 
> shared snapshots).
> 
> I tested it and it refuses "snapshotX" volumes.

But as you said above: "snapshot0 volumes have the VISIBLE_LV flag set."

That said, I do see that in practice the existing lvm2 code does reject
resizing "snapshot" type snapshot0 using !lv_is_visible(lv).  I'll have
a closer look to understand that.

But when I tried it with the "multisnapshot" type snapshot0 (w/
multisnap enabled LVM2 2.02.63 from my people page + the above patch)
lvresize allowed it and then crashed in _setup_alloced_segment():

# lvresize -L 5.0G test/snapshot0
  Extending logical volume snapshot0 to 5.00 GiB
Segmentation fault (core dumped)

(gdb) bt
#0  0x00000000004520ea in _setup_alloced_segment (region_size=<value optimized out>, aa=<value optimized out>, segtype=<value optimized out>, 
    stripe_size=<value optimized out>, area_count=<value optimized out>, status=<value optimized out>, lv=<value optimized out>) at metadata/lv_manip.c:690
#1  _setup_alloced_segments (region_size=<value optimized out>, aa=<value optimized out>, segtype=<value optimized out>, stripe_size=<value optimized out>, 
    area_count=<value optimized out>, status=<value optimized out>, lv=<value optimized out>) at metadata/lv_manip.c:727
#2  lv_add_segment (region_size=<value optimized out>, aa=<value optimized out>, segtype=<value optimized out>, stripe_size=<value optimized out>, 
    area_count=<value optimized out>, status=<value optimized out>, lv=<value optimized out>) at metadata/lv_manip.c:1387
#3  0x000000000045498a in lv_extend (lv=0xe66878, segtype=0xe40770, stripes=<value optimized out>, stripe_size=<value optimized out>, mirrors=0, extents=256, 
    mirrored_pv=<value optimized out>, mirrored_pe=<value optimized out>, status=<value optimized out>, allocatable_pvs=<value optimized out>, 
    alloc=<value optimized out>) at metadata/lv_manip.c:1638
#4  0x000000000041d9ea in _lvresize (lp=<value optimized out>, vg=<value optimized out>, cmd=<value optimized out>) at lvresize.c:629
#5  lvresize (lp=<value optimized out>, vg=<value optimized out>, cmd=<value optimized out>) at lvresize.c:702
#6  0x0000000000418550 in lvm_run_command (cmd=0xdd5fe0, argc=1, argv=0x7fff3bc2c1a8) at lvmcmdline.c:1071
#7  0x000000000041ab20 in lvm2_main (argc=4, argv=0x7fff3bc2c190) at lvmcmdline.c:1423
#8  0x000000335341eb1d in __libc_start_main () from /lib64/libc.so.6
#9  0x000000000040f089 in _start ()
(gdb) l
685             uint32_t s, extents, area_multiple;
686             struct lv_segment *seg;
687
688             area_multiple = calc_area_multiple(segtype, area_count);
689
690             if (!(seg = alloc_lv_segment(lv->vg->cmd->mem, segtype, lv,
691                                          lv->le_count,
692                                          aa[0].len * area_multiple,
693                                          status, stripe_size, NULL,
694                                          area_count,

Mike


