From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 14 May 2009 14:56:56 -0400
Subject: lvconvert error when converting a linear to a mirror
Message-ID: <1242327416.3943.82.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I keep hitting the below error path when using lvconvert on a linear
volume that is spread across multiple PVs.

	/*
         * FIXME This check used to precede mirror->mirror conversion
	 * but didn't affect mirror->linear or linear->mirror. I do
	 * not understand what is its intention, in fact.
	 */
	if (dm_list_size(&lv->segments) != 1) {
		log_error("Logical volume %s has multiple "
			  "mirror segments.", lv->name);
		return 0;
	}

I created the linear volume by using PE ranges as follows:
# tools/lvm lvcreate -L 64M -n lv1 vg1 /dev/loop0:0-3 /dev/loop1:0-7 /dev/loop2:0-3

The lvconvert command I'm using is:
# tools/lvm lvconvert -m1 vg1/lv1 
  Logical volume lv1 has multiple mirror segments.

I'm not that familiar with lvconvert code, but looking through it
quickly, it looks like it should handle this case ok.  I removed the
above check and the mirror seemed to be created fine.  Is this check
there for some other reason though?  The comment above indicates it is
not clear to at least one other person.  If we are checking mirror
segments, perhaps we should add in a lv->MIRRORED flag check as well?

NOTE: I hit this as a side issue so I don't want to get sidetracked
indefinitely but figured it was worth a mention.



