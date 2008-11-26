From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 25 Nov 2008 23:42:55 -0500
Subject: _vg_read() - meaning of consistent when PVs are missing in a VG
Message-ID: <1227674575.8335.83.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr, with your recent changes, is the below to be expected?
Should _vg_read() return 'consistent = 0' if the VG has missing PVs?  If
so, what is the meaning of 'consistent' now upon return from the
function?  Does it mean "no LVs have missing PVs?"

I wrote a little program to use the latest vg_read() APIs and was
suprised when I called vg_read_for_update(cmd, vgname, NULL, 0) with a
missing PV and got 'consistent = 1' on return, and vg_read_error()
returned no error.  How will the app writer detect this if he wants to
then lvcreate on the VG?  Are we missing an API or error condition?

Specifically I'm talking about after this commit:
commit 95d43e17b390e532628dc8ab58cf1d377b71ef2b
Author: Alasdair Kergon <agk@redhat.com>
Date:   Fri Sep 19 06:42:00 2008 +0000

    Improve the way VGs with PVs missing are handled so manual
intervention is required in fewer circumstances.  (mornfall)



/* Caller sets consistent to 1 if it's safe for vg_read_internal to correct
 * inconsistent metadata on disk (i.e. the VG write lock is held).
 * This guarantees only consistent metadata is returned.
 * If consistent is 0, caller must check whether consistent == 1 on return
 * and take appropriate action if it isn't (e.g. abort; get write lock
 * and call vg_read_internal again).
 *
 * If precommitted is set, use precommitted metadata if present.
 *
 * Either of vgname or vgid may be NULL.
 */
static struct volume_group *_vg_read(struct cmd_context *cmd,
				     const char *vgname,
				     const char *vgid,
				     int *consistent, unsigned precommitted)
{
	struct format_instance *fid;
	const struct format_type *fmt;
	struct volume_group *vg, *correct_vg = NULL;
	struct metadata_area *mda;
	struct lvmcache_info *info;
	int inconsistent = 0;
	int inconsistent_vgid = 0;
	int inconsistent_pvs = 0;
	unsigned use_precommitted = precommitted;
	struct dm_list *pvids;
	struct pv_list *pvl, *pvl2;
	struct dm_list all_pvs;
	char uuid[64] __attribute((aligned(8)));

	if (is_orphan_vg(vgname)) {
		if (use_precommitted) {
			log_error("Internal error: vg_read_internal requires vgname "
				  "with pre-commit.");
			return NULL;
		}
		*consistent = 1;
		return _vg_read_orphans(cmd, vgname);
	}

	if ((correct_vg = lvmcache_get_vg(vgid, precommitted))) {
		if (vg_missing_pv_count(correct_vg)) {
			log_verbose("There are %d physical volumes missing.",
				    vg_missing_pv_count(correct_vg));
			_vg_mark_partial_lvs(correct_vg);
/*
 * NOTE: ===> We're not returning *consistent = 0 with missing PVs, so
 * the meaning of consistent is unclear.
 */
		}
		*consistent = 1;
		return correct_vg;
	}




