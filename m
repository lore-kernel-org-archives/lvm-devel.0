From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 01 Sep 2011 16:23:32 +0200
Subject: [PATCH] Clear up the confusing "precommit(ed)" terminology
In-Reply-To: <18801.4269028374$1314817116@news.gmane.org>
References: <18801.4269028374$1314817116@news.gmane.org>
Message-ID: <4E5F9564.4060205@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 31.8.2011 20:57, Petr Rockai napsal(a):
> Hi,
> 
> we have discussed the current use of "precommit" and "precommitted"
> terminology as related to LVM metadata with Alasdair, and arrived at the
> following conclusion:
> 
> The *state* of the metadata, what was most of the time called
> "precommitted" (and sometimes "precommit") is changed to "tentative".
> 
> The *act* of writing the "precommitted" (i.e. tentative) metadata, which
> has been called "precommit" is now more explicitly part of vg_write (the
> *action* of precommitting only existed as part of metadata_area_ops and
> was called vg_precommit). To reflect the two-phase nature of vg_write
> with multiple MDAs, I have renamed vg_write in metadata_area_ops to
> vg_write_phase1 and vg_precommit to vg_write_phase2. Other suggestions
> have been made, for now I picked phase1/phase2 because it is the easiest
> to track down and rename to any other combination of names.
> 
> The current (proposed) terminology therefore is:
> - the metadata after vg_write, but before vg_commit is "tentative"
> - the metadata after vg_write *and* vg_commit is "committed"
> 
> There is no user-visible state between not-yet-written and tentative
> (even though vg_write is internally a 2-phase operation, this is not
> exposed in the metadata layer API).
> 
> I am attaching 2 diffs, the first is the changes I did manually, the
> second is these changes with
> 
> find -name \*.\[hc\] | xargs sed -i.orig -e 's,precommitted,tentative,g;s,PRECOMMIT\(TED\)\?,TENTATIVE,g;s,pre-committed,tentative,g;'
> 
> on top (you can use interdiff to see just the diff produced by sed).
> 
> Yours,
>   Petr
> 
> 
> 
> tentative_manual.diff
>ntext *fidtc = (struct text_fid_context *) fid->private;
> @@ -575,7 +575,7 @@ static int _vg_write_raw(struct format_i
>  	int r = 0;
>         uint64_t new_wrap = 0, old_wrap = 0, new_end;
>  	int found = 0;
> -	int noprecommit = 0;
> +	int notentative = 0;
>  
>  	/* Ignore any mda on a PV outside the VG. vgsplit relies on this */
>  	dm_list_iterate_items(pvl, &vg->pvs) {
> @@ -595,7 +595,7 @@ static int _vg_write_raw(struct format_i
>  		goto_out;
>  
>  	rlocn = _find_vg_rlocn(&mdac->area, mdah,
> -			vg->old_name ? vg->old_name : vg->name, &noprecommit);
> +			vg->old_name ? vg->old_name : vg->name, &notentative);
>  	mdac->rlocn.offset = _next_rlocn_offset(rlocn, mdah);


I'm certainly not an English linguist expert here - but "notentative" looks
even more weird.

For my understanding precommit made more sense then tentative  - I'm not
objecting the idea of cleaning it - but this term makes it even more
confusing.  If we are going to use  2-phase commit - I'd use term
phase1/phase2 here.

Zdenek


