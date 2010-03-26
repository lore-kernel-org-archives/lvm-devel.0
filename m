From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 26 Mar 2010 18:31:39 +0000
Subject: [PATCH] Remove vgname check from _find_vg_rlocn and just return the rlocn slot.
In-Reply-To: <1269625126-18152-1-git-send-email-dwysocha@redhat.com>
References: <1269620108.2508.3.camel@f10-node1>
	<1269625126-18152-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20100326183139.GS5259@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Mar 26, 2010 at 01:38:46PM -0400, Dave Wysochanski wrote:
> Unclear what the purpose of this check was/is.  Removing it allows for easier
> refactoring, fixes at least one bug, and at least breaks no tests.  If it
> covers and important case, we should add a comment and/or testcase.
 
The on-disk layout supports multiple mdas for different VGs stored on the same
disk.  But at the moment we only use one.
[Create a test case: PV with 2 mdas, and different vgname in each...current
code should ignore the 2nd one, maybe overwriting it with copy of first, I'm
not sure.]

> -	/* FIXME Loop through rlocns two-at-a-time.  List null-terminated. */

> -	/* FIXME Ignore if checksum incorrect!!! */

FIXME removed, so does the patch now validate the checksum?

I think the vgname validation is still needed on almost all occasions.
Only the 'tell me which VG is in this mda' case doesn't want it.

Alasdair


