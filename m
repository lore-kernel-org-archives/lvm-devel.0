From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 13 Oct 2006 14:13:49 +0100
Subject: Re: [PATCH] for bz 210511 & 203983
In-Reply-To: <452F635E.2060809@redhat.com>
References: <452F635E.2060809@redhat.com>
Message-ID: <20061013131348.GI17654@agk.surrey.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 13, 2006 at 10:58:54AM +0100, Patrick Caulfield wrote:
> It seems that vgsplit was not propogating the CLUSTERED flag onto the new VG.

Yes; vgsplit has a lot of bugs in it at the moment.
That's not the only flag that isn't propogated correctly.

Alasdair
-- 
agk at redhat.com


