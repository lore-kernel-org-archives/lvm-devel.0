From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 12 Feb 2009 10:03:28 +0100
Subject: [PATCH] Fix segfault when using vgsplit in stacked environment
In-Reply-To: <20090210181443.GB7582@agk.fab.redhat.com>
References: <498FE109.6000103@redhat.com>
	<20090210181443.GB7582@agk.fab.redhat.com>
Message-ID: <4993E5E0.4060004@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> It is meaningless to call pv_uses_vg() if the PV does not exist.

Well, it's some kind of an exception, so I thought it would be
better to check it right here than all the other places outside
the function.

> And the function currently returns 0 if the answer is unknown - it'll
> get even more confusing if it returns 0 for some types of 'unknown'
> and 1 for other types!

Hmm, isn't it the opposite way? Looking at the dev_manager_device_uses_vg
function that is called from pv_uses_vg and returs its value,
dev_manager_device_uses_vg should return 1 if uncertain. So I relied on
this at that time... I return 1 when checking for NULL value of pv->dev,
because we can't decide if PV uses VG in this situation, too.

Peter


