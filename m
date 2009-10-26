From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Oct 2009 20:58:46 +0000
Subject: [PATCH 0 of 2] LVM: Split mirror capability
In-Reply-To: <1255468842.16495.21.camel@hydrogen.msp.redhat.com>
References: <1255468842.16495.21.camel@hydrogen.msp.redhat.com>
Message-ID: <20091026205846.GG25303@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Based on the first proposal, things do seem to fit together nice
and simply.

On Tue, Oct 13, 2009 at 04:20:42PM -0500, Jon Brassow wrote:
> [root at bp-01 ~]# lvconvert -m1 --split vg/lv /dev/sdc1

(1) One lvconvert cmd can only split a mirror into two pieces.

Starting with a 2-way mirror:

lvconvert -m1 -n lvcopy --retainas copy vg/lv lv_mimage1

Splits off lv_mimage1, promotes it to a visible LV and renames it 'lvcopy'.

Starting with a 3-way mirror, it would split off a 2-way mirror (which you
could split further if you wished).

Without -n it would rename it to lv_msplit_N where N is the next unused digit
and msplit is *not* a reserved name.

lvconvert -m1 --retainas unsynced vg/lv lv_mimage1

promotes lv_mimage1 to a read-only visible LV & renames it to
lv_mimage1_unsynced (still a reserved name - you cannot rename it while
in this state).  You can now lvremove it, or further use

lvconvert --retainas copy vg/lv_mimage1

to split it properly, rename it and make it writeable (unless the mirror
is itself readonly).


Alasdair


