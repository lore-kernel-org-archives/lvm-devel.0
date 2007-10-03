From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 3 Oct 2007 18:09:38 +0100
Subject: Re: LVM2/tools/fsadm Makefile.in
In-Reply-To: <87fy0s2qhk.fsf@rho.meyering.net>
References: <20071003094658.15588.qmail@sourceware.org>
	<20071003095830.GH18444@agk.fab.redhat.com>
	<87fy0s2qhk.fsf@rho.meyering.net>
Message-ID: <20071003170937.GK18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Yes, that's a better workaround for now, but still not satisfactory in
the long term - inline functions are awkward to debug with current tools
so we try to avoid using them.

Alasdair
-- 
agk at redhat.com


