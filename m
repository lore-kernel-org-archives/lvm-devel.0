From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 10 Feb 2009 18:14:43 +0000
Subject: [PATCH] Fix segfault when using vgsplit in stacked environment
In-Reply-To: <498FE109.6000103@redhat.com>
References: <498FE109.6000103@redhat.com>
Message-ID: <20090210181443.GB7582@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 09, 2009 at 08:53:45AM +0100, Peter Rajnoha wrote:
> this is a small patch for segmentation fault in vgsplit while using 
> stacked VGs (rh bz 481793). Segfault is caused by null dereference in 
> 'pv_uses_vg' function that is called to check if a PV uses VG somewhere 
> in its construction. In stacked environment, when the LV/VG from lower 
> layer is disabled, the PV constructed above does not exist as well and 

I don't think the code should be getting as far as it does in that
situation.

It is meaningless to call pv_uses_vg() if the PV does not exist.
And the function currently returns 0 if the answer is unknown - it'll
get even more confusing if it returns 0 for some types of 'unknown'
and 1 for other types!

Alasdair
-- 
agk at redhat.com


